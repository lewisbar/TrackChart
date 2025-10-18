//
//  TrackChartApp.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Domain
import Presentation
import SwiftData

@main
struct TrackChartApp: App {
    @State private var path = [Topic]()

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
        }
        .modelContainer(for: Topic.self)
    }

    private func makeTopicListView() -> some View {
        NavigationStack(path: $path) {
            TopicListView(showTopic: showTopic)
                .navigationDestination(for: Topic.self, destination: TopicView.init)
        }
    }

    private func showTopic(_ topic: Topic) {
        path = [topic]
    }
}
