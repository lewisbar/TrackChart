//
//  TrackChartApp.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Domain
import Persistence
import Presentation

@main
struct TrackChartApp: App {
    @State private var model = AppModel(
        store: PersistentTopicStore(persistenceService: InMemoryPersistenceService()),
        navigator: Navigator()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
                .onAppear(perform: model.loadTopics)
                .alert(model.alertMessage.title, isPresented: $model.isAlertViewPresented, actions: makeDismissButton, message: makeAlertText)
        }
    }

    private func makeTopicListView() -> some View {
        NavigationStack(path: $model.path) {
            TopicListView(model: model.topicListModel, showTopic: model.navigate, createTopic: model.navigateToNewTopic)
                .navigationDestination(for: NavigationTopic.self, destination: makeTopicView)
        }
    }

    private func makeAlertText() -> some View {
        Text(model.alertMessage.message)
    }

    private func makeDismissButton() -> some View {
        Button("OK") { model.dismissAlert() }
    }

    @ViewBuilder
    private func makeTopicView(for navigationTopic: NavigationTopic) -> some View {
        if let topic = model.topic(for: navigationTopic.id) {
            TopicView(model: TopicViewModel(topic: topic, updateTopic: model.update))
        }
    }
}

private class InMemoryPersistenceService: TopicPersistenceService {
    private var topics: [Topic] = [
        .init(id: UUID(), name: "Topic 1", entries: [
            .init(value: 1, timestamp: Date().advanced(by: -1000)),
            .init(value: 2, timestamp: Date().advanced(by: -500)),
            .init(value: 0, timestamp: Date().advanced(by: -200)),
            .init(value: -1, timestamp: Date().advanced(by: -100)),
            .init(value: 0, timestamp: Date().advanced(by: 0))
        ], unsubmittedValue: 4)
    ]

    func create(_ topic: Topic) throws {
        topics.append(topic)
    }
    
    func update(_ topic: Topic) throws {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }
        topics[index] = topic
    }
    
    func delete(_ topic: Topic) throws {
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }
        topics.remove(at: index)
    }
    
    func reorder(to newOrder: [Topic]) throws {
        topics = newOrder
    }
    
    func load() throws -> [Topic] {
        topics
    }
}
