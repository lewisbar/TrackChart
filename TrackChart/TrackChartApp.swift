//
//  TrackChartApp.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI
import Persistence

@main
struct TrackChartApp: App {
    @State private var topicStore = TopicStore(persistenceService: UserDefaultsTopicPersistenceService(topicIDsKey: "com.trackchart.topics.idlist"))
    @State private var topicCellModels = [TopicCellModel]()
    @State private var isTopicCreationViewPresented = false
    @State private var isAlertViewPresented = false
    @State private var alertMessage = (title: "Error", message: "Please try again later. If the error persists, don't hesitate to contact support.")

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
                .onAppear { do { try topicStore.load() } catch { handle(error) } }
                .onChange(of: topicStore.topics, updateTopicCellModels)
                .onChange(of: topicCellModels, propagateDeletedAndReorderedCellModelsToStore)
                .sheet(isPresented: $isTopicCreationViewPresented, content: makeTopicCreationView)
                .alert(alertMessage.title, isPresented: $isAlertViewPresented, actions: makeDismissButton, message: { Text(alertMessage.message) })
        }
    }

    private func makeTopicListView() -> some View {
        NavigationStack {
            TopicListView(topics: $topicCellModels, startTopicCreation: startTopicCreation)
                .navigationDestination(for: TopicCellModel.self, destination: makeTopicView)
        }
    }

    private func updateTopicCellModels() {
        topicCellModels = topicStore
            .topics
            .map(Topic.init)
            .map(makeTopicCellModel)
    }

    private func propagateDeletedAndReorderedCellModelsToStore() {
        let updatedIDs = topicCellModels.map(\.id)

        topicStore.topics.forEach { topic in
            if !updatedIDs.contains(topic.id) {
                do { try topicStore.remove(topic) } catch { handle(error) }
            }
        }

        let reorderedTopics = updatedIDs.compactMap { topicStore.topic(for: $0) }
        do { try topicStore.reorder(to: reorderedTopics) } catch { handle(error) }
    }

    private func makeTopicCellModel(for topic: Topic) -> TopicCellModel {
        TopicCellModel(id: topic.id, name: topic.name, info: "\(topic.entries.count) entries")
    }

    private func startTopicCreation() {
        isTopicCreationViewPresented = true
    }

    private func makeTopicCreationView() -> some View {
        TopicCreationView(createTopic: { name in
            createTopic(withName: name)
            isTopicCreationViewPresented = false
        })
    }

    private func createTopic(withName name: String) {
        let newTopic = Persistence.Topic(id: UUID(), name: name, entries: [])
        do { try topicStore.add(newTopic) } catch { handle(error) }
    }

    private func makeDismissButton() -> some View {
        Button("OK") { isAlertViewPresented = false }
    }

    private func delete(_ topicCellModel: TopicCellModel) {
        guard let persistenceTopic = topicStore.topics.first(where: { $0.id == topicCellModel.id }) else { return}

        do { try topicStore.remove(persistenceTopic) } catch { handle(error) }
    }

    @ViewBuilder
    private func makeTopicView(for topicCellModel: TopicCellModel) -> some View {
        if let persistenceTopic = topicStore.topics.first(where: { $0.id == topicCellModel.id }) {
            let topic = Topic(from: persistenceTopic)
            TopicView(title: topic.name, counterView: { makeCounterView(for: topic) }, chartView: { makeChartView(for: topic) })
        }
    }

    private func makeCounterView(for topic: Topic) -> some View {
        CounterView(submitNewValue: { submit($0, to: topic) }, deleteLastValue: { removeLastValue(from: topic) })
    }

    private func submit(_ newValue: Int, to topic: Topic) {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: topic.entries + [newValue])
        do { try topicStore.update(updatedTopic.persistenceTopic) } catch { handle(error) }
    }

    private func removeLastValue(from topic: Topic) {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: topic.entries.dropLast())
        do { try topicStore.update(updatedTopic.persistenceTopic) } catch { handle(error) }
    }

    @ViewBuilder
    private func makeChartView(for topic: Topic) -> some View {
        if !topic.entries.isEmpty {
            ChartView(values: topic.entries)
        } else {
            ChartPlaceholderView()
        }
    }

    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }
}

private extension Topic {
    init(from persistenceTopic: Persistence.Topic) {
        self.id = persistenceTopic.id
        self.name = persistenceTopic.name
        self.entries = persistenceTopic.entries
    }

    var persistenceTopic: Persistence.Topic {
        Persistence.Topic(id: id, name: name, entries: entries)
    }
}
