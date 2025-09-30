//
//  AppModelTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 23.09.25.
//

import Testing
import TrackChartiOS
import Domain

class AppModelTests {
    @Test func init_loadsTopicsAndMapsThemToCellModels() {
        let topic = topic()
        let (sut, _, _) = makeSUT(withResult: .success([topic]))

        #expect(sut.topicCellModels == [TopicCellModel(from: topic)])
    }

    @Test func loadingError_showsErrorMessage() {
        let error = anyNSError()
        let (sut, _, _) = makeSUT(withResult: .failure(error))

        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(sut.isAlertViewPresented)
        #expect(sut.topicCellModels == [])
    }

    @Test func updateStoreAutomaticallyAfterDeletionAndReordering() {
        let topic1 = topic(name: "topic1")
        let topic2 = topic(name: "topic2")
        let topic3 = topic(name: "topic3")
        let topic4 = topic(name: "topic4")
        let originalTopicList = [topic1, topic2, topic3, topic4]
        let (sut, store, _) = makeSUT(withResult: .success(originalTopicList))

        let modifiedTopicList = [topic3, topic4, topic1]
        sut.topicCellModels = modifiedTopicList.map(TopicCellModel.init)

        #expect(store.topics == modifiedTopicList)
    }

    @Test func renameTopic_alsoUpdatesStore() {
        let topic = topic(name: "old name")
        let newName = "new name"
        let (sut, store, _) = makeSUT(withResult: .success([topic]))

        sut.rename(topic, to: newName)

        let expectedTopic = Topic(id: topic.id, name: newName, entries: topic.entries)
        #expect(sut.topicCellModels == [TopicCellModel(from: expectedTopic)])
        #expect(store.topics == [expectedTopic])
    }

    @Test func submitValueToTopic_updatesStoreAndCellModels() {
        let originalTopic = topic(entries: [-1, 0])
        let newValue = 1
        let (sut, store, _) = makeSUT(withResult: .success([originalTopic]))

        sut.submit(newValue, to: originalTopic)

        let expectedTopic = topic(id: originalTopic.id, name: originalTopic.name, entries: originalTopic.entries + [newValue])
        #expect(sut.topicCellModels == [TopicCellModel(from: expectedTopic)])
        #expect(store.topics == [expectedTopic])
    }

    @Test func removeLastValueFromTopic_updatesStoreAndCellModels() {
        let originalTopic = topic(entries: [-1, 0, 1])
        let (sut, store, _) = makeSUT(withResult: .success([originalTopic]))

        sut.removeLastValue(from: originalTopic)

        let expectedTopic = topic(id: originalTopic.id, name: originalTopic.name, entries: originalTopic.entries.dropLast())
        #expect(sut.topicCellModels == [TopicCellModel(from: expectedTopic)])
        #expect(store.topics == [expectedTopic])
    }

    @Test func navigateToTopicBackAndForth() {
        let topic1 = topic()
        let navTopic1 = NavigationTopic(from: topic1)
        let topic2 = topic()
        let navTopic2 = NavigationTopic(from: topic2)
        let (sut, _, navigator) = makeSUT(withResult: .success([topic1, topic2]))

        sut.navigate(to: topic1)
        #expect(navigator.path == [navTopic1])

        sut.navigate(to: topic2)
        #expect(navigator.path == [navTopic1, navTopic2])

        sut.navigateBack()
        #expect(navigator.path == [navTopic1])

        sut.navigateBack()
        #expect(navigator.path == [])

        sut.navigate(to: topic2)
        #expect(navigator.path == [navTopic2])
    }

    @Test func navigateToTopicWithID() {
        let topic1 = topic()
        let navTopic1 = NavigationTopic(from: topic1)
        let topic2 = topic()
        let navTopic2 = NavigationTopic(from: topic2)
        let (sut, _, navigator) = makeSUT(withResult: .success([topic1, topic2]))

        sut.navigate(toTopicWithID: topic1.id)
        #expect(navigator.path == [navTopic1])

        sut.navigate(toTopicWithID: topic2.id)
        #expect(navigator.path == [navTopic1, navTopic2])

        sut.navigateBack()
        #expect(navigator.path == [navTopic1])

        sut.navigateBack()
        #expect(navigator.path == [])

        sut.navigate(toTopicWithID: topic2.id)
        #expect(navigator.path == [navTopic2])
    }

    @Test func navigateToNewTopic_createsAndNavigates() {
        let (sut, store, navigator) = makeSUT()
        #expect(navigator.path.count == 0)
        #expect(store.topics.count == 0)

        sut.navigateToNewTopic()

        #expect(navigator.path.count == 1)
        #expect(store.topics.count == 1)
    }

    @Test func isObservable() async throws {
        let originalTopic = topic(name: "old name")
        let (sut, _, _) = makeSUT(withResult: .success([originalTopic]))
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = sut.topicCellModels
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        sut.rename(originalTopic, to: "new name")

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after changing value")
    }

    // MARK: - Helpers

    private func makeSUT(withResult persistenceResult: Result<[Topic], Error> = .success([])) -> (sut: AppModel, store: TopicStore, navigator: Navigator) {
        let persistenceService = TopicPersistenceServiceStub(loadResult: persistenceResult)
        let store = TopicStore(persistenceService: persistenceService)
        let navigator = Navigator()
        let sut = AppModel(store: store, navigator: navigator)

        weakSUT = sut
        weakStore = store
        weakNavigator = navigator
        weakPersistenceService = persistenceService

        return (sut, store, navigator)
    }

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakStore == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakNavigator == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakPersistenceService == nil, "Instance should have been deallocated. Potential memory leak.")
    }

    private weak var weakSUT: AppModel?
    private weak var weakStore: TopicStore?
    private weak var weakNavigator: Navigator?
    private weak var weakPersistenceService: TopicPersistenceServiceStub?

    private func topic(id: UUID = UUID(), name: String = "a topic", entries: [Int] = [.random(in: -2...10)]) -> Topic {
        Topic(id: id, name: name, entries: entries)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}

private class TopicPersistenceServiceStub: TopicPersistenceService {
    private let loadResult: Result<[Topic], Error>

    init(loadResult: Result<[Topic], Error> = .success([])) {
        self.loadResult = loadResult
    }

    func load() throws -> [Topic] {
        try loadResult.get()
    }

    func create(_ topic: Topic) throws {}
    func update(_ topic: Topic) throws {}
    func delete(_ topic: Topic) throws {}
    func reorder(to newOrder: [Topic]) throws {}
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
