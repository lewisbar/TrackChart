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
    private let modelContainer: ModelContainer
    private let saver: SwiftDataSaver
    @State private var path = [TopicEntity]()

    init() {
        do {
            modelContainer = try ModelContainer(for: TopicEntity.self)
            saver = SwiftDataSaver(modelContext: modelContainer.mainContext, sendError: { error in print(error.localizedDescription) /*TODO*/ })
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
        }
        .modelContainer(modelContainer)
    }

    private func makeTopicListView() -> some View {
        NavigationStack(path: $path) {
            SwiftDataTopicListView(viewModel: SwiftDataTopicListViewModel(showTopic: showTopic))
                .navigationDestination(for: TopicEntity.self) {
                    SwiftDataTopicView(
                        topic: $0,
                        viewModel: SwiftDataTopicViewModel(
                            save: saver.save,
                            debounceSave: saver.debounceSave
                        )
                    )
                }
        }
    }

    private func showTopic(_ topic: TopicEntity?) {
        guard let topic else { return }
        path = [topic]
    }
}
