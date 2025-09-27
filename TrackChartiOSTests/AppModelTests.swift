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
    let store: TopicStore
    var alertMessage = (title: "Error", message: "Please try again later. If the error persists, don't hesitate to contact support.")
    var isAlertViewPresented = false
    var topicCellModels = [TopicCellModel]()
    init(store: TopicStore) {
        self.store = store
        loadTopics()
    }
    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }
    func updateStoreWithDeletedAndReorderedCellModels() {
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
}

struct AppModelTests {
    @Test func init_loadsTopics() {
        let topic = Topic(id: UUID(), name: "a topic", entries: [3, 4, 5])
        let persistenceService = TopicPersistenceServiceSpy()
        persistenceService.stub([topic])
        let store = TopicStore(persistenceService: persistenceService)
        let sut = AppModel(store: store)

        #expect(sut.topicCellModels == [TopicCellModel(from: topic)])
    }

    @Test func loadingError_showsErrorMessage() {
        let persistenceService = TopicPersistenceServiceSpy()
        let error = anyNSError()
        persistenceService.stub(error)
        let store = TopicStore(persistenceService: persistenceService)
        let sut = AppModel(store: store)

        #expect(sut.alertMessage == ("Error", error.localizedDescription))
        #expect(sut.isAlertViewPresented)
        #expect(sut.topicCellModels == [])
    }

    @Test func updateStoreAfterDeletionAndReordering() {
        let topic1 = Topic(id: UUID(), name: "topic1", entries: [3, 4, 5])
        let topic2 = Topic(id: UUID(), name: "topic2", entries: [-3, -4])
        let topic3 = Topic(id: UUID(), name: "topic3", entries: [3, 4, 5, 6])
        let topic4 = Topic(id: UUID(), name: "topic4", entries: [1, 2])
        let originalTopicList = [topic1, topic2, topic3, topic4]
        let persistenceService = TopicPersistenceServiceSpy()
        persistenceService.stub(originalTopicList)
        let store = TopicStore(persistenceService: persistenceService)
        let sut = AppModel(store: store)

        let modifiedTopicList = [topic3, topic4, topic1]
        sut.topicCellModels = modifiedTopicList.map(TopicCellModel.init)

        sut.updateStoreWithDeletedAndReorderedCellModels()

        #expect(sut.store.topics == modifiedTopicList, "Expected \(modifiedTopicList.map(\.name)), got \(sut.store.topics.map(\.name))")
    }

    // MARK: - Helpers

    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
}

private class TopicPersistenceServiceSpy: TopicPersistenceService {
    var createdTopics = [Topic]()
    var updatedTopics = [Topic]()
    var deletedTopics = [Topic]()
    var reorderedTopicLists = [[Topic]]()
    var loadCallCount = 0
    private(set) var stubbedResult = Result<[Topic], Error>.success([])

    func create(_ topic: Topic) {
        createdTopics.append(topic)
    }

    func update(_ topic: Topic) {
        updatedTopics.append(topic)
    }

    func delete(_ topic: Topic) {
        deletedTopics.append(topic)
    }

    func reorder(to newOrder: [Topic]) throws {
        reorderedTopicLists.append(newOrder)
    }

    func load() throws -> [Topic] {
        loadCallCount += 1
        return try stubbedResult.get()
    }

    func stub(_ topics: [Topic]) {
        stubbedResult = .success(topics)
    }

    func stub(_ error: Error) {
        stubbedResult = .failure(error)
    }
}
