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
    private var modelContext: ModelContext { modelContainer.mainContext }
    @State private var path = [TopicEntity]()

    init() {
        do {
            modelContainer = try ModelContainer(for: TopicEntity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.primary)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.secondary)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
        }
        .modelContainer(for: TopicEntity.self)
    }

    private func makeTopicListView() -> some View {
        NavigationStack(path: $path) {
            SwiftDataTopicListView(
                viewModel: SwiftDataTopicListViewModel(
                    insert: modelContext.insert,
                    delete: modelContext.delete,
                    showTopic: showTopic,
                    randomPalette: { Palette.random.name }
                )
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.title2)
                            .foregroundStyle(.red)
                        Text("TrackChart")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                    }
                }
            }
            .navigationDestination(for: TopicEntity.self) {
                SwiftDataTopicView(
                    topic: $0,
                    viewModel: SwiftDataTopicViewModel()
                )
            }
        }
    }

    private func showTopic(_ topic: TopicEntity?) {
        guard let topic else { return }
        path = [topic]
    }
}
