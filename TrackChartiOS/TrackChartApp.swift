//
//  TrackChartApp.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import SwiftData
import Persistence

@main
struct TrackChartApp: App {
    @State private var path = [TopicEntity]()

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
        }
        .modelContainer(for: TopicEntity.self)
    }

    private func makeTopicListView() -> some View {
        NavigationStack(path: $path) {
            SwiftDataTopicListView(showTopic: showTopic)
                .navigationDestination(for: TopicEntity.self, destination: SwiftDataTopicView.init)
        }
    }

    private func showTopic(_ topic: TopicEntity?) {
        guard let topic else { return }
        path = [topic]
    }
}
