//
//  AppModelTests.swift
//  TrackChartiOSTests
//
//  Created by LennartWisbar on 23.09.25.
//

import Testing
import TrackChartiOS
import Domain
import Persistence

@Observable
class AppModel {
    private let store: TopicStore
    let navigator: Navigator
    var alertMessage = (title: "Error", message: "Please try again later. If the error persists, don't hesitate to contact support.")
    var isAlertViewPresented = false
    var topicCellModels = [TopicCellModel]() {
        didSet { updateStoreWithDeletedAndReorderedCellModels() }
    }
    init(store: TopicStore, navigator: Navigator) {
        self.store = store
        self.navigator = navigator
        loadTopics()
    }
    func navigate(to topic: Topic) {
        navigator.showDetail(for: NavigationTopic(from: topic))
    }
    func navigateBack() {
        navigator.goBack()
    }

    func rename(_ topic: Topic, to newName: String) {
        do { try store.rename(topic, to: newName) } catch { handle(error) }
        topicCellModels = store.topics.map(TopicCellModel.init)
    }

    private func updateStoreWithDeletedAndReorderedCellModels() {
        let updatedIDs = topicCellModels.map(\.id)

        store.topics.forEach { topic in
            if !updatedIDs.contains(topic.id) {
                do { try store.remove(topic) } catch { handle(error) }
            }
        }

        let reorderedTopics = updatedIDs.compactMap { store.topic(for: $0) }
        do { try store.reorder(to: reorderedTopics) } catch { handle(error) }
    }

    private func loadTopics() {
        do { try store.load() } catch { handle(error) }
        topicCellModels = store.topics.map(TopicCellModel.init)
    }

    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }
}

class AppModelTests {
    @Test func init_loadsTopicsAndMapsThemToCellModels() {
        let topic = topic()
        let (sut, store, _) = makeSUT(withResult: .success([topic]))

        #expect(store.loadCalls == 1)
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

    @Test func navigateToTopicBackAndForth() {
        let topic1 = topic()
        let navTopic1 = NavigationTopic(from: topic1)
        let topic2 = topic()
        let navTopic2 = NavigationTopic(from: topic2)
        let (sut, _, navigator) = makeSUT()

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

    // MARK: - Helpers

    private func makeSUT(withResult storeResult: Result<[Topic], Error> = .success([])) -> (sut: AppModel, store: TopicStoreSpy, navigator: Navigator) {
        let store = TopicStoreSpy(with: storeResult)
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

    private func topic(id: UUID = UUID(), name: String = "a topic", entries: [Int] = [.random(in: -2...10)]) -> Topic {
        Topic(id: id, name: name, entries: entries)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}

private class TopicStoreSpy: TopicStore {
    private(set) var topics = [Topic]()
    private(set) var topicsToLoad = [Topic]()
    private(set) var error: Error?
    private(set) var topicForIDCalls = [UUID]()
    private(set) var loadCalls = 0
    private(set) var addCalls = [Topic]()
    private(set) var updateCalls = [Topic]()
    private(set) var reorderCalls = [[Topic]]()
    private(set) var removeCalls = [Topic]()
    private(set) var submitCalls = [(value: Int, topic: Topic)]()
    private(set) var removeLastValueCalls = [Topic]()
    private(set) var changeNameCalls = [(topic: Topic, newName: String)]()

    init(with result: Result<[Topic], Error>) {
        switch result {
        case let .success(topics): self.topicsToLoad = topics
        case let .failure(error): self.error = error
        }
    }

    func topic(for id: UUID) -> Topic? {
        topicForIDCalls.append(id)
        return topics.first(where: { $0.id == id })
    }

    func load() throws {
        loadCalls += 1
        try throwErrorIfSetupThisWay()
        topics = topicsToLoad
    }
    
    func add(_ topic: Topic) throws {
        addCalls.append(topic)
        try throwErrorIfSetupThisWay()
    }
    
    func update(_ topic: Topic) throws {
        updateCalls.append(topic)
        try throwErrorIfSetupThisWay()
    }
    
    func reorder(to newOrder: [Topic]) throws {
        reorderCalls.append(newOrder)
        try throwErrorIfSetupThisWay()
        topics = newOrder
    }
    
    func remove(_ topic: Topic) throws {
        removeCalls.append(topic)
        try throwErrorIfSetupThisWay()
        topics.removeAll(where: { $0.id == topic.id })
    }
    
    func submit(_ newValue: Int, to topic: Topic) throws {
        submitCalls.append((newValue, topic))
        try throwErrorIfSetupThisWay()
    }
    
    func removeLastValue(from topic: Topic) throws {
        removeCalls.append(topic)
        try throwErrorIfSetupThisWay()
    }
    
    func rename(_ topic: Topic, to newName: String) throws {
        changeNameCalls.append((topic, newName))

        try throwErrorIfSetupThisWay()

        if let index = topics.firstIndex(of: topic) {
            topics[index] = Topic(id: topic.id, name: newName, entries: topic.entries)
        }
    }

    private func throwErrorIfSetupThisWay() throws {
        if let error { throw error }
    }
}
