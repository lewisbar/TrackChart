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
    var topics: [TopicCellModel] { didSet { updateTopicList(topics.map { $0.id }) } }
    private let updateTopicList: ([UUID]) -> Void

    init(topics: [Topic], updateTopicList: @escaping ([UUID]) -> Void) {
        self.topics = topics.map(TopicCellModel.init)
        self.updateTopicList = updateTopicList
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

    @Test func onChangeOfTopics_sendUpdate() {
        let topic1 = topic(name: "a topic", entries: [5, 6], unsubmittedValue: 4)
        let topic2 = topic(name: "another topic", entries: [-12, 0], unsubmittedValue: 0)
        let topic3 = topic(name: "a third topic", entries: [0], unsubmittedValue: -1)
        var capturedIDList: [UUID]?
        let sut = makeSUT(topics: [topic1, topic2, topic3], updateTopicList: { capturedIDList = $0 })
        let newList = [topic3, topic1]

        sut.topics = newList.map(TopicCellModel.init)

        #expect(capturedIDList == newList.map(\.id))
    }

    // MARK: - Helpers

    private func makeSUT(topics: [Topic] = [], updateTopicList: @escaping ([UUID]) -> Void = { _ in }) -> TopicListViewModel {
        let sut = TopicListViewModel(topics: topics, updateTopicList: updateTopicList)
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
