//
//  AppModelTests.swift
//
//  Created by Lennart Wisbar on 23.09.25.
//

import Testing
import Presentation
import Domain

class AppModelTests {
    @Test func init_doesNotLoadTopics() {
        let topic = topic()
        let testComponents = makeSUT(withTopics: [topic])

        #expect(testComponents.sut.topicCellModels == [])
    }

    @Test func loadTopics_loadsTopicsAndMapsThemToCellModels() {
        let topic = topic()
        let testComponents = makeSUT(withTopics: [topic])

        testComponents.sut.loadTopics()

        #expect(testComponents.sut.topicCellModels == [TopicCellModel(from: topic)])
    }

    @Test func loadingError_showsErrorMessage() {
        let error = anyNSError()
        let testComponents = makeSUT(error: error)
        testComponents.sut.loadTopics()

        #expect(testComponents.sut.alertMessage == ("Error", error.localizedDescription))
        #expect(testComponents.sut.isAlertViewPresented)
        #expect(testComponents.sut.topicCellModels == [])
    }

    @Test func dismissErrorMessage() {
        let error = anyNSError()
        let testComponents = makeSUT(error: error)
        testComponents.sut.loadTopics()

        #expect(testComponents.sut.alertMessage == ("Error", error.localizedDescription))
        #expect(testComponents.sut.isAlertViewPresented)
        #expect(testComponents.sut.topicCellModels == [])

        testComponents.sut.dismissAlert()

        #expect(testComponents.sut.alertMessage == AppModel.defaultAlertMessage)
        #expect(!testComponents.sut.isAlertViewPresented)
    }

    @Test func topicForID() {
        let topic = topic(name: "a topic")
        let testComponents = makeSUT(withTopics: [topic])
        testComponents.sut.loadTopics()

        let receivedTopic = testComponents.sut.topic(for: topic.id)

        #expect(receivedTopic == topic)
    }

    @Test func topicForNonExistentID_returnsNil() {
        let topic = topic(name: "a topic")
        let testComponents = makeSUT(withTopics: [topic])
        testComponents.sut.loadTopics()

        let receivedTopic = testComponents.sut.topic(for: UUID())

        #expect(receivedTopic == nil)
    }

    @Test func updateTopic() {
        let originalTopic = topic(name: "old name", entries: [1, 2, 3], unsubmittedValue: -1)
        let testComponents = makeSUT(withTopics: [originalTopic])
        testComponents.sut.loadTopics()
        let changedTopic = Topic(id: originalTopic.id, name: "new name", entries: [4, 5, 6], unsubmittedValue: 17)

        testComponents.sut.update(changedTopic)

        #expect(testComponents.sut.topic(for: originalTopic.id) == changedTopic)
        #expect(testComponents.sut.topicCellModels == [TopicCellModel(from: changedTopic)])
    }

    @Test func updateTopic_onError_doesNotUpdate() {
        let originalTopic = topic(name: "old name", entries: [1, 2, 3], unsubmittedValue: -1)
        let testComponents = makeSUT(withTopics: [originalTopic])
        testComponents.sut.loadTopics()
        let changedTopic = Topic(id: originalTopic.id, name: "new name", entries: [4, 5, 6], unsubmittedValue: 17)
        let error = anyNSError()
        testComponents.persistenceService.error = error

        testComponents.sut.update(changedTopic)

        #expect(testComponents.sut.topic(for: originalTopic.id) == originalTopic)
        #expect(testComponents.sut.isAlertViewPresented)
        #expect(testComponents.sut.alertMessage == ("Error", error.localizedDescription))
        #expect(testComponents.sut.topicCellModels == [TopicCellModel(from: originalTopic)])
    }

    @Test func updateStoreAutomaticallyAfterDeletionAndReordering() {
        let topic1 = topic(name: "topic1")
        let topic2 = topic(name: "topic2")
        let topic3 = topic(name: "topic3")
        let topic4 = topic(name: "topic4")
        let originalTopicList = [topic1, topic2, topic3, topic4]
        let testComponents = makeSUT(withTopics: originalTopicList)
        testComponents.sut.loadTopics()

        let modifiedTopicList = [topic3, topic4, topic1]
        testComponents.sut.topicCellModels = modifiedTopicList.map(TopicCellModel.init)

        #expect(testComponents.store.topics == modifiedTopicList)
    }

    @Test func updateStoreAutomaticallyAfterDeletionAndReordering_onError_recoverWithCurrentStoreState() {
        let topic1 = topic(name: "topic1")
        let topic2 = topic(name: "topic2")
        let topic3 = topic(name: "topic3")
        let topic4 = topic(name: "topic4")
        let originalTopicList = [topic1, topic2, topic3, topic4]
        let testComponents = makeSUT(withTopics: originalTopicList)
        testComponents.sut.loadTopics()
        let error = anyNSError()
        testComponents.persistenceService.error = error

        let modifiedTopicList = [topic3, topic4, topic1]
        testComponents.sut.topicCellModels = modifiedTopicList.map(TopicCellModel.init)

        #expect(testComponents.store.topics == originalTopicList)
        #expect(testComponents.sut.topicCellModels == originalTopicList.map(TopicCellModel.init))
        #expect(testComponents.sut.alertMessage == ("Error", error.localizedDescription))
        #expect(testComponents.sut.isAlertViewPresented)
    }

    @Test func navigateToTopicBackAndForth() {
        let topic1 = topic()
        let navTopic1 = NavigationTopic(from: topic1)
        let topic2 = topic()
        let navTopic2 = NavigationTopic(from: topic2)
        let testComponents = makeSUT(withTopics: [topic1, topic2])
        testComponents.sut.loadTopics()

        #expect(testComponents.navigator.path == [])
        #expect(testComponents.sut.path == [])

        testComponents.sut.navigate(to: topic1)
        #expect(testComponents.navigator.path == [navTopic1])
        #expect(testComponents.sut.path == [navTopic1])

        testComponents.sut.navigate(to: topic2)
        #expect(testComponents.navigator.path == [navTopic1, navTopic2])
        #expect(testComponents.sut.path == [navTopic1, navTopic2])

        testComponents.sut.navigateBack()
        #expect(testComponents.navigator.path == [navTopic1])
        #expect(testComponents.sut.path == [navTopic1])

        testComponents.sut.navigateBack()
        #expect(testComponents.navigator.path == [])
        #expect(testComponents.sut.path == [])

        testComponents.sut.navigate(to: topic2)
        #expect(testComponents.navigator.path == [navTopic2])
        #expect(testComponents.sut.path == [navTopic2])
    }

    @Test func navigateToTopicWithID() {
        let topic1 = topic()
        let navTopic1 = NavigationTopic(from: topic1)
        let topic2 = topic()
        let navTopic2 = NavigationTopic(from: topic2)
        let testComponents = makeSUT(withTopics: [topic1, topic2])
        testComponents.sut.loadTopics()

        #expect(testComponents.navigator.path == [])
        #expect(testComponents.sut.path == [])

        testComponents.sut.navigate(toTopicWithID: topic1.id)
        #expect(testComponents.navigator.path == [navTopic1])
        #expect(testComponents.sut.path == [navTopic1])

        testComponents.sut.navigate(toTopicWithID: topic2.id)
        #expect(testComponents.navigator.path == [navTopic1, navTopic2])
        #expect(testComponents.sut.path == [navTopic1, navTopic2])

        testComponents.sut.navigateBack()
        #expect(testComponents.navigator.path == [navTopic1])
        #expect(testComponents.sut.path == [navTopic1])

        testComponents.sut.navigateBack()
        #expect(testComponents.navigator.path == [])
        #expect(testComponents.sut.path == [])

        testComponents.sut.navigate(toTopicWithID: topic2.id)
        #expect(testComponents.navigator.path == [navTopic2])
        #expect(testComponents.sut.path == [navTopic2])
    }

    @Test func navigateToNewTopic_createsAndNavigates() {
        let testComponents = makeSUT()
        #expect(testComponents.navigator.path.count == 0)
        #expect(testComponents.store.topics.count == 0)
        testComponents.sut.loadTopics()

        testComponents.sut.navigateToNewTopic()

        #expect(testComponents.navigator.path.count == 1)
        #expect(testComponents.store.topics.count == 1)
    }

    @Test func navigateToNewTopic_onCreationError_showsError_andDoesNotCreateOrNavigate() {
        let error = anyNSError()
        let testComponents = makeSUT()
        testComponents.sut.loadTopics()
        testComponents.persistenceService.error = error

        testComponents.sut.navigateToNewTopic()

        #expect(testComponents.sut.isAlertViewPresented)
        #expect(testComponents.sut.alertMessage == ("Error", error.localizedDescription))
        #expect(testComponents.navigator.path.isEmpty)
        #expect(testComponents.store.topics.isEmpty)
    }

    @Test func isObservable() async throws {
        let originalTopic = topic(name: "old name")
        let testComponents = makeSUT(withTopics: [originalTopic])
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = testComponents.sut.topicCellModels
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        testComponents.sut.loadTopics()

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after changing value")
    }

    // MARK: - Helpers

    private func makeSUT(withTopics persistedTopics: [Topic] = [], error: Error? = nil) -> (sut: AppModel, store: TopicStore, navigator: Navigator, persistenceService: TopicPersistenceServiceStub) {
        let persistenceService = TopicPersistenceServiceStub(topics: persistedTopics, error: error)
        let store = TopicStore(persistenceService: persistenceService)
        let navigator = Navigator()
        let sut = AppModel(store: store, navigator: navigator)

        weakSUT = sut
        weakStore = store
        weakNavigator = navigator
        weakPersistenceService = persistenceService

        return (sut, store, navigator, persistenceService)
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

    private func topic(id: UUID = UUID(), name: String = "a topic", entries: [Int] = [.random(in: -2...10)], unsubmittedValue: Int = 0) -> Topic {
        Topic(id: id, name: name, entries: entries, unsubmittedValue: unsubmittedValue)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}

private class TopicPersistenceServiceStub: TopicPersistenceService {
    var topics: [Topic]
    var error: Error?

    init(topics: [Topic], error: Error?) {
        self.topics = topics
        self.error = error
    }

    func load() throws -> [Topic] {
        if let error { throw error }
        return topics
    }

    func create(_ topic: Topic) throws {
        if let error { throw error }
    }

    func update(_ topic: Topic) throws {
        if let error { throw error }
    }

    func delete(_ topic: Topic) throws {
        if let error { throw error }
    }

    func reorder(to newOrder: [Topic]) throws {
        if let error { throw error }
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
