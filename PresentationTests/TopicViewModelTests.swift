//
//  TopicViewModelTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 14.10.25.
//

import Testing
import Presentation
import Domain

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

    @Test func changeOfName_sendsUpdatedTopic() {
        let originalTopic = makeTopic(name: "old name")
        var capturedTopic: Topic?
        let sut = makeSUT(topic: originalTopic, updateTopic: { capturedTopic = $0 })
        let newName = "new name"

        sut.name = newName

        let expectedTopic = Topic(id: originalTopic.id, name: newName, entries: originalTopic.entries, unsubmittedValue: originalTopic.unsubmittedValue)
        #expect(capturedTopic == expectedTopic)
    }

    @Test func didSetName_ifNameHasNotChanged_doesNotSendUpdatedTopic() {
        let originalName = "old name"
        let originalTopic = makeTopic(name: originalName)
        var capturedTopic: Topic?
        let sut = makeSUT(topic: originalTopic, updateTopic: { capturedTopic = $0 })

        sut.name = originalName

        #expect(capturedTopic == nil)
    }

    @Test func changeOfEntries_sendsUpdatedTopic() {
        let originalTopic = makeTopic(entries: [19, 20])
        var capturedTopic: Topic?
        let sut = makeSUT(topic: originalTopic, updateTopic: { capturedTopic = $0 })
        let newEntries = [-100, 100, 1000]

        sut.entries = newEntries

        let expectedTopic = Topic(id: originalTopic.id, name: originalTopic.name, entries: newEntries, unsubmittedValue: originalTopic.unsubmittedValue)
        #expect(capturedTopic == expectedTopic)
    }

    @Test func changeOfUnsubmittedValue_sendsUpdatedTopic() {
        let originalTopic = makeTopic(unsubmittedValue: 0)
        var capturedTopic: Topic?
        let sut = makeSUT(topic: originalTopic, updateTopic: { capturedTopic = $0 })
        let newValue = 17

        sut.unsubmittedValue = newValue

        let expectedTopic = Topic(id: originalTopic.id, name: originalTopic.name, entries: originalTopic.entries, unsubmittedValue: newValue)
        #expect(capturedTopic == expectedTopic)
    }

    // MARK: - Helpers

    private func makeSUT(topic: Topic? = nil, updateTopic: @escaping (Topic) -> Void = { _ in }) -> TopicViewModel {
        let sut = TopicViewModel(topic: topic ?? makeTopic(), updateTopic: updateTopic)
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
