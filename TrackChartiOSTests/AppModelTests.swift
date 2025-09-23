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
    var topicCellModels = [TopicCellModel]()
    init(store: TopicStore) {
        self.store = store
        loadTopics()
    }
    private func handle(_ error: Error) {
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
}

private class TopicPersistenceServiceSpy: TopicPersistenceService {
    var createdTopics = [Topic]()
    var updatedTopics = [Topic]()
    var deletedTopics = [Topic]()
    var reorderedTopicLists = [[Topic]]()
    var loadCallCount = 0
    private(set) var stubbedTopics = [Topic]()

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

    func load() -> [Topic] {
        loadCallCount += 1
        return stubbedTopics
    }

    func stub(_ topics: [Topic]) {
        stubbedTopics = topics
    }
}
