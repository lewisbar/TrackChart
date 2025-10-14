//
//  TopicViewModelTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 14.10.25.
//

import Testing
import Domain

@Observable
class TopicViewModel {
    let id: UUID
    var name: String
    var entries: [Int]
    var unsubmittedValue: Int

    init(topic: Topic) {
        self.id = topic.id
        self.name = topic.name
        self.entries = topic.entries
        self.unsubmittedValue = topic.unsubmittedValue
    }
}

class TopicViewModelTests {
    @Test func init_setsInitialValues() {
        let topic = makeTopic()

        let sut = makeSUT(topic: topic)

        #expect(sut.id == topic.id)
        #expect(sut.name == topic.name)
        #expect(sut.entries == topic.entries)
        #expect(sut.unsubmittedValue == topic.unsubmittedValue)
    }

    @Test func isObservable() async throws {
        let sut = makeSUT()
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = sut.name
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        sut.name = "new name"

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after adding value")
    }

    // MARK: - Helpers

    private func makeSUT(topic: Topic? = nil) -> TopicViewModel {
        let sut = TopicViewModel(topic: topic ?? makeTopic())
        weakSUT = sut
        return sut
    }

    private func makeTopic(id: UUID = UUID(), name: String = "a topic", entries: [Int] = [-1, 2], unsubmittedValue: Int = 0) -> Topic {
        Topic(id: id, name: name, entries: entries, unsubmittedValue: unsubmittedValue)
    }

    private weak var weakSUT: TopicViewModel?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
