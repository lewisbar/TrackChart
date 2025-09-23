//
//  NavigatorTests.swift
//  TrackChartTests
//
//  Created by Lennart Wisbar on 20.09.25.
//

import Testing
import Foundation
import Domain

class NavigatorTests {
    @Test func init_startsWithHome() {
        let sut = makeSUT()
        #expect(sut.path.isEmpty)
    }

    @Test func showDetail_addsDetailToStack() {
        let sut = makeSUT()
        let topic = NavigationTopic(id: UUID(), name: "a topic", entries: [1, 3, 5])

        sut.showDetail(for: topic)

        #expect(sut.path == [topic])
    }

    @Test func showDetail_whenAlreadyOnDetail_addsAnotherDetailToStack() {
        let sut = makeSUT()
        let topic1 = NavigationTopic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = NavigationTopic(id: UUID(), name: "another topic", entries: [-1, -3])

        sut.showDetail(for: topic1)
        #expect(sut.path == [topic1])

        sut.showDetail(for: topic2)
        #expect(sut.path == [topic1, topic2])
    }

    @Test func showNewDetail_createsAndSavesNewTopic_andAddsDetailToStack() {
        var savedTopics = [Topic]()
        let sut = Navigator(saveTopic: { savedTopics.append($0) })

        sut.showNewDetail()

        #expect(savedTopics.count == 1)
        #expect(savedTopics.first?.name == "")
        #expect(savedTopics.first?.entries == [])
        #expect(sut.path.count == 1)
    }

    @Test func showNewDetail_whenAlreadyOnDetail_createsAndSavesNewTopic_andAddsDetailToStack() {
        var savedTopics = [Topic]()
        let sut = Navigator(saveTopic: { savedTopics.append($0) })
        sut.showDetail(for: NavigationTopic(id: UUID(), name: "a topic", entries: [1, 3, 5]))

        sut.showNewDetail()

        #expect(savedTopics.count == 1)
        #expect(savedTopics.first?.name == "")
        #expect(savedTopics.first?.entries == [])
        #expect(sut.path.count == 2)
    }

    @Test func goBack_removesDetailRepeatedly() {
        let sut = makeSUT()
        let topic1 = NavigationTopic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = NavigationTopic(id: UUID(), name: "another topic", entries: [-1, -3])
        sut.path = [topic1, topic2]

        sut.goBack()
        #expect(sut.path == [topic1])

        sut.goBack()
        #expect(sut.path == [])

        sut.goBack()
        #expect(sut.path == [])
    }

    @Test func isObservable() async throws {
        let sut = makeSUT()
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = sut.path
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        sut.showNewDetail()

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after adding topic to path")
        #expect(sut.path.count == 1)
    }

    // MARK: - Helpers

    private func makeSUT(saveTopic: @escaping (Topic) -> Void = { _ in }) -> Navigator {
        let sut = Navigator(saveTopic: saveTopic)
        weakSUT = sut
        return sut
    }

    private weak var weakSUT: Navigator?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
