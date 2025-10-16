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
        let (sut, store, _) = makeSUT(withTopics: [topic])

        #expect(store.loadCallCount == 0)
        #expect(sut.topicListModel.topics.isEmpty)
    }

    @Test func loadTopics_passesTopicsToListViewModel() {
        let topic = topic()
        let (sut, _, _) = makeSUT(withTopics: [topic])

        sut.loadTopics()

        #expect(sut.topicListModel.topics == [TopicCellModel(from: topic)])
    }

    @Test func loadingError_showsErrorMessage() {
        let error = anyNSError()
        let (sut, _ , _) = makeSUT(error: error)
        sut.loadTopics()

        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(sut.isAlertViewPresented)
        #expect(sut.topicListModel.topics.isEmpty)
    }

    @Test func dismissErrorMessage() {
        let error = anyNSError()
        let (sut, _, _) = makeSUT(error: error)
        sut.loadTopics()

        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(sut.isAlertViewPresented)
        #expect(sut.topicListModel.topics.isEmpty)

        sut.dismissAlert()

        #expect(sut.alertMessage == AppModel.defaultAlertMessage)
        #expect(!sut.isAlertViewPresented)
    }

    @Test func topicForID() {
        let topic = topic(name: "a topic")
        let (sut, _, _) = makeSUT(withTopics: [topic])
        sut.loadTopics()

        let receivedTopic = sut.topic(for: topic.id)

        #expect(receivedTopic == topic)
    }

    @Test func topicForNonExistentID_returnsNil() {
        let topic = topic(name: "a topic")
        let (sut, _, _) = makeSUT(withTopics: [topic])
        sut.loadTopics()

        let receivedTopic = sut.topic(for: UUID())

        #expect(receivedTopic == nil)
    }

    @Test func updateTopic() {
        let originalTopic = topic(name: "old name", values: [1, 2, 3], unsubmittedValue: -1)
        let (sut, _, _) = makeSUT(withTopics: [originalTopic])
        sut.loadTopics()
        let changedTopic = topic(id: originalTopic.id, name: "new name", values: [4, 5, 6], unsubmittedValue: 17)

        sut.update(changedTopic)

        #expect(sut.topic(for: originalTopic.id) == changedTopic)
        #expect(sut.topicListModel.topics == [TopicCellModel(from: changedTopic)])
    }

    @Test func updateTopic_onError_doesNotUpdate() {
        let originalTopic = topic(name: "old name", values: [1, 2, 3], unsubmittedValue: -1)
        let (sut, store, _) = makeSUT(withTopics: [originalTopic])
        sut.loadTopics()
        let changedTopic = topic(id: originalTopic.id, name: "new name", values: [4, 5, 6], unsubmittedValue: 17)
        let error = anyNSError()
        store.error = error

        sut.update(changedTopic)

        #expect(sut.topic(for: originalTopic.id) == originalTopic)
        #expect(sut.isAlertViewPresented)
        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(sut.topicListModel.topics == [TopicCellModel(from: originalTopic)])
    }

    @Test func updateStoreAutomaticallyAfterDeletionAndReordering() {
        let topic1 = topic(name: "topic1")
        let topic2 = topic(name: "topic2")
        let topic3 = topic(name: "topic3")
        let topic4 = topic(name: "topic4")
        let originalTopicList = [topic1, topic2, topic3, topic4]
        let (sut, store, _) = makeSUT(withTopics: originalTopicList)
        sut.loadTopics()

        let modifiedTopicList = [topic3, topic4, topic1]
        sut.topicListModel.topics = modifiedTopicList.map(TopicCellModel.init)

        #expect(store.topics == modifiedTopicList)
        #expect(store.removedTopics == [topic2])
    }

    @Test func updateStoreAutomaticallyAfterDeletionAndReordering_onError_recoverWithCurrentStoreState() {
        let topic1 = topic(name: "topic1")
        let topic2 = topic(name: "topic2")
        let topic3 = topic(name: "topic3")
        let topic4 = topic(name: "topic4")
        let originalTopicList = [topic1, topic2, topic3, topic4]
        let (sut, store, _) = makeSUT(withTopics: originalTopicList)
        sut.loadTopics()
        let error = anyNSError()
        store.reorderingError = error

        let modifiedTopicList = [topic3, topic4, topic1]
        sut.topicListModel.topics = modifiedTopicList.map(TopicCellModel.init)

        #expect(store.topics == originalTopicList)
        #expect(sut.topicListModel.topics == originalTopicList.map(TopicCellModel.init))
        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(sut.isAlertViewPresented)
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
        let (sut, store, navigator) = makeSUT()
        sut.loadTopics()
        store.error = error

        sut.navigateToNewTopic()

        #expect(sut.isAlertViewPresented)
        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(navigator.path.isEmpty)
        #expect(store.topics.isEmpty)
    }

    @Test func isObservable() async throws {
        let originalTopic = topic(name: "old name")
        let testComponents = makeSUT(withTopics: [originalTopic])
        let tracker = ObservationTracker()

        withObservationTracking {
            _ = testComponents.sut.path
        } onChange: {
            Task { await tracker.setTriggered() }
        }

        testComponents.sut.navigate(to: originalTopic)

        try await Task.sleep(for: .milliseconds(10))
        let triggered = await tracker.getTriggered()
        #expect(triggered, "Expected observation to be triggered after changing value")
    }

    // MARK: - Helpers

    private func makeSUT(withTopics topics: [Topic] = [], error: Error? = nil) -> (sut: AppModel, store: TopicStoreSpy, navigator: Navigator) {
        let store = TopicStoreSpy(topics: topics)
        store.error = error
        let navigator = Navigator()
        let sut = AppModel(store: store, navigator: navigator)

        weakSUT = sut
        weakStore = store
        weakNavigator = navigator

        return (sut, store, navigator)
    }

    deinit {
        #expect(weakSUT == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakStore == nil, "Instance should have been deallocated. Potential memory leak.")
        #expect(weakNavigator == nil, "Instance should have been deallocated. Potential memory leak.")
    }

    private weak var weakSUT: AppModel?
    private weak var weakStore: TopicStoreSpy?
    private weak var weakNavigator: Navigator?

    private func topic(id: UUID = UUID(), name: String = "a topic", values: [Int] = [.random(in: -2...10)], unsubmittedValue: Double = 0) -> Topic {
        Topic(id: id, name: name, entries: entries(from: values), unsubmittedValue: unsubmittedValue)
    }

    private func entries(from values: [Int]) -> [Entry] {
        values.map {
            Entry(value: Double($0), timestamp: Date().advanced(by: -100))
        }
    }

    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}

private class TopicStoreSpy: TopicStore {
    var topics: [Topic]
    var error: Error?
    var reorderingError: Error?

    init(topics: [Topic] = []) {
        self.topics = topics
    }

    private(set) var loadCallCount = 0
    func load() throws {
        try throwErrorIfPresent()
        loadCallCount += 1
    }

    private(set) var requestedIDs = [UUID]()
    func topic(for id: UUID) -> Topic? {
        requestedIDs.append(id)
        return topics.first(where: { $0.id == id })
    }

    private(set) var newOrders = [[Topic]]()
    func reorder(to newOrder: [Topic]) throws {
        try throwReorderingErrorIfPresent()
        topics = newOrder
        newOrders.append(newOrder)
    }

    private(set) var addedTopics = [Topic]()
    func add(_ topic: Topic) throws {
        try throwErrorIfPresent()
        topics.append(topic)
        addedTopics.append(topic)
    }

    private(set) var updatedTopics = [Topic]()
    func update(_ topic: Topic) throws {
        try throwErrorIfPresent()
        let index = topics.firstIndex(where: { $0.id == topic.id })!
        topics[index] = topic
        updatedTopics.append(topic)
    }

    private(set) var removedTopics = [Topic]()
    func remove(_ topic: Topic) throws {
        try throwErrorIfPresent()
        let index = topics.firstIndex(where: { $0.id == topic.id })!
        topics.remove(at: index)
        removedTopics.append(topic)
    }

    private func throwErrorIfPresent() throws {
        if let error { throw error }
    }

    private func throwReorderingErrorIfPresent() throws {
        if let reorderingError { throw reorderingError }
    }
}

private actor ObservationTracker {
    var triggered = false
    func setTriggered() { triggered = true }
    func getTriggered() -> Bool { triggered }
}
