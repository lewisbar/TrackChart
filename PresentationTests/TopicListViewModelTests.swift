//
//  TopicListViewModelTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 14.10.25.
//

import Testing
import Presentation
import Domain

class TopicListViewModelTests {
    @Test func init_setsCellModels() {
        let topic1 = topic(name: "a topic", values: [5, 6], unsubmittedValue: 4)
        let topic2 = topic(name: "another topic", values: [-12, 0], unsubmittedValue: 0)

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

    @Test func onChangeOfTopics_sendsUpdate() {
        let topic1 = topic(name: "a topic", values: [5, 6], unsubmittedValue: 4)
        let topic2 = topic(name: "another topic", values: [-12, 0], unsubmittedValue: 0)
        let topic3 = topic(name: "a third topic", values: [0], unsubmittedValue: -1)
        var capturedIDList: [UUID]?
        let sut = makeSUT(topics: [topic1, topic2, topic3], updateTopicList: { capturedIDList = $0 })
        let newList = [topic3, topic1]

        sut.topics = newList.map(TopicCellModel.init)

        #expect(capturedIDList == newList.map(\.id))
    }

    @Test func didSetTopics_ifNothingHasChanged_doesNotSendUpdate() {
        let topic1 = topic(name: "a topic", values: [5, 6], unsubmittedValue: 4)
        let topic2 = topic(name: "another topic", values: [-12, 0], unsubmittedValue: 0)
        let topic3 = topic(name: "a third topic", values: [0], unsubmittedValue: -1)
        var capturedIDList: [UUID]?
        let originalList = [topic1, topic2, topic3]
        let sut = makeSUT(topics: originalList, updateTopicList: { capturedIDList = $0 })

        sut.topics = originalList.map(TopicCellModel.init)

        #expect(capturedIDList == nil)
    }

    @Test func updateFromStore() {
        let topic1 = topic(name: "a topic", values: [5, 6], unsubmittedValue: 4)
        let topic2 = topic(name: "another topic", values: [-12, 0], unsubmittedValue: 0)
        let topic3 = topic(name: "a third topic", values: [0], unsubmittedValue: -1)
        let topic4 = topic(name: "a fourth topic", values: [-5], unsubmittedValue: 3)
        let changedTopic1 = topic(id: topic1.id, name: "new name", values: [4], unsubmittedValue: 1000)
        let originalList = [topic1, topic3, topic4]
        var capturedIDList: [UUID]?
        let sut = makeSUT(topics: originalList, updateTopicList: { capturedIDList = $0 })

        let changedTopicList = [topic2, changedTopic1, topic4]
        sut.updateFromStore(topics: changedTopicList)

        #expect(sut.topics == changedTopicList.map(TopicCellModel.init))
        #expect(capturedIDList == nil)
    }

    // MARK: - Helpers

    private func makeSUT(topics: [Topic] = [], updateTopicList: @escaping ([UUID]) -> Void = { _ in }) -> TopicListViewModel {
        let sut = TopicListViewModel(topics: topics, updateTopicList: updateTopicList)
        weakSUT = sut
        return sut
    }

    private func topic(id: UUID = UUID(), name: String = "a topic", values: [Int] = [.random(in: -2...10)], unsubmittedValue: Int = 0) -> Topic {
        Topic(id: id, name: name, entries: entries(from: values), unsubmittedValue: Double(unsubmittedValue))
    }

    private func entries(from values: [Int]) -> [Entry] {
        values.map {
            Entry(value: Double($0), timestamp: Date().advanced(by: -100))
        }
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
