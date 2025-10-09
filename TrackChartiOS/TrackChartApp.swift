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
        store: TopicStore(persistenceService: UserDefaultsTopicPersistenceService()),
        navigator: Navigator()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
                .onAppear(perform: model.loadTopics)
        }
    }

    private func makeTopicListView() -> some View {
        NavigationStack(path: $model.path) {
            TopicListView(topics: $model.topicCellModels, showTopic: model.navigate, createTopic: model.navigateToNewTopic)
                .navigationDestination(for: NavigationTopic.self, destination: makeTopicView)
        }
    }

    private func makeTopicCellModel(for topic: Topic) -> TopicCellModel {
        TopicCellModel(id: topic.id, name: topic.name, info: "\(topic.entries.count) entries")
    }

    private func makeDismissButton() -> some View {
        Button("OK") { model.dismissAlert() }
    }

    @ViewBuilder
    private func makeTopicView(for navigationTopic: NavigationTopic) -> some View {
        if let topic = model.topic(for: navigationTopic.id) {
            TopicView(title: $model.currentTopicName, counterView: { makeCounterView(for: topic) }, chartView: { makeChartView(for: topic) })
        }
    }

    private func makeCounterView(for topic: Topic) -> some View {
        CounterView(submitNewValue: { model.submit($0, to: topic) }, deleteLastValue: { model.removeLastValue(from: topic) })
    }

    @ViewBuilder
    private func makeChartView(for topic: Topic) -> some View {
        if !topic.entries.isEmpty {
            ChartView(values: topic.entries)
        } else {
            ChartPlaceholderView()
        }
    }
}
