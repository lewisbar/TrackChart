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
    var alertMessage = (title: "Error", message: "Please try again later. If the error persists, don't hesitate to contact support.")
    var isAlertViewPresented = false
    var topicCellModels = [TopicCellModel]() {
        didSet {
            updateStoreWithDeletedAndReorderedCellModels()
        }
    }
    init(store: TopicStore) {
        self.store = store
        loadTopics()
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

struct AppModelTests {
    @Test func init_loadsTopicsAndMapsThemToCellModels() {
        let topic = Topic(id: UUID(), name: "a topic", entries: [3, 4, 5])
        let store = TopicStoreSpy(with: .success([topic]))
        let sut = AppModel(store: store)

        #expect(store.loadCalls == 1)
        #expect(sut.topicCellModels == [TopicCellModel(from: topic)])
    }

    @Test func loadingError_showsErrorMessage() {
        let error = anyNSError()
        let store = TopicStoreSpy(with: .failure(error))
        let sut = AppModel(store: store)

        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(sut.isAlertViewPresented)
        #expect(sut.topicCellModels == [])
    }

    @Test func updateStoreAutomaticallyAfterDeletionAndReordering() {
        let topic1 = Topic(id: UUID(), name: "topic1", entries: [3, 4, 5])
        let topic2 = Topic(id: UUID(), name: "topic2", entries: [-3, -4])
        let topic3 = Topic(id: UUID(), name: "topic3", entries: [3, 4, 5, 6])
        let topic4 = Topic(id: UUID(), name: "topic4", entries: [1, 2])
        let originalTopicList = [topic1, topic2, topic3, topic4]
        let store = TopicStoreSpy(with: .success(originalTopicList))
        let sut = AppModel(store: store)

        let modifiedTopicList = [topic3, topic4, topic1]
        sut.topicCellModels = modifiedTopicList.map(TopicCellModel.init)

        #expect(store.topics == modifiedTopicList)
    }

    @Test func renameTopic_alsoUpdatesStore() {
        let topic = Topic(id: UUID(), name: "topic1", entries: [3, 4, 5])
        let newName = "new name"
        let store = TopicStoreSpy(with: .success([topic]))
        let sut = AppModel(store: store)

        sut.rename(topic, to: newName)

        let expectedTopic = Topic(id: topic.id, name: newName, entries: topic.entries)
        #expect(sut.topicCellModels == [TopicCellModel(from: expectedTopic)])
        #expect(store.topics == [expectedTopic])
    }

    // MARK: - Helpers

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
