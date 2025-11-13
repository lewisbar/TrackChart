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
        .modelContainer(modelContainer)
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
            .toolbar { ToolbarItem(placement: .topBarLeading) { branding } }
            .navigationDestination(for: TopicEntity.self) { topic in
                SwiftDataTopicView(
                    topic: topic,
                    viewModel: SwiftDataTopicViewModel(),
                    settingsView: { makeSettingsView(for: topic) }
                )
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private var branding: some View {
        HStack {
            if let icon = Bundle.main.appIcon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            }

            Text("TrackChart")
                .font(.title3)
                .fontDesign(.monospaced)
        }
    }

    private func makeSettingsView(for topic: TopicEntity) -> some View {
        SettingsView(
            name: topic.name,
            palette: Palette.palette(named: topic.palette),
            rename: { topic.name = $0 },
            changePalette: { topic.palette = $0.name }
        )
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func showTopic(_ topic: TopicEntity?) {
        guard let topic else { return }
        path = [topic]
    }
}
