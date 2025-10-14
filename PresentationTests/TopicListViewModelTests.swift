//
//  TopicListViewModelTests.swift
//  PresentationTests
//
//  Created by LennartWisbar on 14.10.25.
//

import Testing
import Presentation
import Domain

@Observable
class TopicListViewModel {
    var topics: [TopicCellModel]

    init(topics: [Topic]) {
        self.topics = topics.map(TopicCellModel.init)
    }
}

class TopicListViewModelTests {
    @Test func init_setsCellModels() {
        let topic1 = topic(name: "a topic", entries: [5, 6], unsubmittedValue: 4)
        let topic2 = topic(name: "another topic", entries: [-12, 0], unsubmittedValue: 0)

        let sut = makeSUT(topics: [topic1, topic2])

        #expect(sut.topics == [TopicCellModel(from: topic1), TopicCellModel(from: topic2)])
    }

    @Test func isObservable() async throws {
        let sut = makeSUT()
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = sut.topics
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        let newTopic = topic()
        sut.topics.append(TopicCellModel(from: newTopic))

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after adding value")
    }

    // MARK: - Helpers

    private func makeSUT(topics: [Topic] = []) -> TopicListViewModel {
        let sut = TopicListViewModel(topics: topics)
        weakSUT = sut
        return sut
    }

    private func topic(id: UUID = UUID(), name: String = "a topic", entries: [Int] = [.random(in: -2...10)], unsubmittedValue: Int = 0) -> Topic {
        Topic(id: id, name: name, entries: entries, unsubmittedValue: unsubmittedValue)
    }

    private weak var weakSUT: TopicListViewModel?

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
