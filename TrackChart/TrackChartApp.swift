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
    @State private var store = ValueStore(persistenceService: UserDefaultsValuePersistenceService(key: "DataPoints"))

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
        }
    }

    private func makeTopicListView() -> some View {
        NavigationStack {
            TopicListView(topics: [TopicCellModel(name: "Test", info: "\(store.values.count) entries")])
                .navigationDestination(for: TopicCellModel.self, destination: makeTopicView)
        }
    }

    private func makeTopicView(for topic: TopicCellModel) -> some View {
        TopicView(title: "TrackChart", counterView: makeCounterView, chartView: makeChartView)
    }

    private func makeCounterView() -> some View {
        CounterView(submitNewValue: store.add, deleteLastValue: store.removeLastValue)
    }

    @ViewBuilder
    private func makeChartView() -> some View {
        if !store.values.isEmpty {
            ChartView(values: store.values)
        } else {
            ChartPlaceholderView()
        }
    }
}
