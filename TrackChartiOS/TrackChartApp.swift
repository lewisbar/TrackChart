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
    @State private var topicStore = TopicStore(persistenceService: UserDefaultsTopicPersistenceService())
    @State private var topicCellModels = [TopicCellModel]()
    @State private var currentTopic: Topic?
    @State private var currentTopicName: String = ""
    @State private var isAlertViewPresented = false
    @State private var alertMessage = (title: "Error", message: "Please try again later. If the error persists, don't hesitate to contact support.")

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
                .onAppear { do { try topicStore.load() } catch { handle(error) } }
                .onChange(of: topicStore.topics, updateTopicCellModels)
                .onChange(of: topicCellModels, propagateDeletedAndReorderedCellModelsToStore)
                .onChange(of: currentTopicName) { currentTopic.map { set(name: currentTopicName, for: $0) } }
                .alert(alertMessage.title, isPresented: $isAlertViewPresented, actions: makeDismissButton, message: { Text(alertMessage.message) })
        }
    }

    private func makeTopicListView() -> some View {
        NavigationStack {
            TopicListView(topics: $topicCellModels)
                .navigationDestination(for: TopicCellModel.self, destination: makeTopicView)
                .navigationDestination(for: String.self, destination: makeNewTopicView)
        }
    }

    private func updateTopicCellModels() {
        topicCellModels = topicStore
            .topics
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

    private func makeDismissButton() -> some View {
        Button("OK") { isAlertViewPresented = false }
    }

    private func delete(_ topicCellModel: TopicCellModel) {
        guard let persistenceTopic = topicStore.topics.first(where: { $0.id == topicCellModel.id }) else { return}

        do { try topicStore.remove(persistenceTopic) } catch { handle(error) }
    }

    @ViewBuilder
    private func makeTopicView(for topicCellModel: TopicCellModel) -> some View {
        if let topic = topicStore.topics.first(where: { $0.id == topicCellModel.id }) {

            TopicView(title: $currentTopicName, counterView: { makeCounterView(for: topic) }, chartView: { makeChartView(for: topic) })
                .onAppear {
                    currentTopic = topic
                    currentTopicName = topic.name
                }
                .onDisappear {
                    currentTopic = nil
                    currentTopicName = ""
                }
        }
    }

    private func makeNewTopicView(_ code: String) -> some View {
        let newTopic = Topic(id: UUID(), name: "", entries: [])
        return TopicView(title: $currentTopicName, counterView: { makeCounterView(for: newTopic) }, chartView: { makeChartView(for: newTopic) })
            .onAppear {
                do { try topicStore.add(newTopic) } catch { handle(error) }
                currentTopic = newTopic
                currentTopicName = newTopic.name
            }
            .onDisappear {
                currentTopic = nil
                currentTopicName = ""
            }
    }

    private func makeCounterView(for topic: Topic) -> some View {
        CounterView(submitNewValue: { submit($0, to: topic) }, deleteLastValue: { removeLastValue(from: topic) })
    }

    private func submit(_ newValue: Int, to topic: Topic) {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: topic.entries + [newValue])
        do { try topicStore.update(updatedTopic) } catch { handle(error) }
    }

    private func removeLastValue(from topic: Topic) {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: topic.entries.dropLast())
        do { try topicStore.update(updatedTopic) } catch { handle(error) }
    }

    private func set(name: String, for topic: Topic) {
        let updatedTopic = Topic(id: topic.id, name: name, entries: topic.entries)
        do { try topicStore.update(updatedTopic) } catch { handle(error) }
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
