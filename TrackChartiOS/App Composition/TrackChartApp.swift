//
//  TrackChartApp.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import SwiftData
import Persistence
import DataProcessing
import Presentation
import Export

private enum Destination: Hashable {
    case topicView(TopicEntity)
    case entryListView(TopicEntity)
}

private struct IdentifiableSortIndex: Identifiable {
    let id = UUID()
    let value: Int
}

@main
struct TrackChartApp: App {
    private let modelContainer: ModelContainer
    private var modelContext: ModelContext { modelContainer.mainContext }
    @State private var path = [Destination]()
    @State private var newTopicSortIndex: IdentifiableSortIndex?

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
                    newTopic: showNewTopicCreation,
                    randomPalette: { Palette.random.name }
                )
            )
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarLeading) { BrandingView() }.sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .topBarLeading) { BrandingView() }
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case let .topicView(topic):
                    SwiftDataTopicView(
                        topic: topic,
                        settingsView: { makeSettingsView(for: topic) },
                        showEntryList: { showEntryList(for: topic) }
                    )
                case let .entryListView(topic):
                    SwiftDataEntryListView(topic: topic, viewModel: SwiftDataEntryListViewModel())
                }
            }
            .sheet(item: $newTopicSortIndex) {
                makeSettingsViewForNewTopic(withSortIndex: $0.value)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func makeSettingsView(for topic: TopicEntity) -> some View {
        // Snapshot the export payload as pure value types *here* (in the root),
        // so the closure we pass down never captures the live SwiftData model.
        // This is the key to keeping the settings Form responsive.
        let exportEntries = topic.sortedEntries.map { Export.ExportEntry(timestamp: $0.timestamp, value: $0.value) }
        let exportTopicName = topic.name
        let style = Date.FormatStyle(timeZone: .current)
            .year(.defaultDigits)
            .month(.twoDigits)
            .day(.twoDigits)
            .hour(.twoDigits(amPM: .omitted))
            .minute(.twoDigits)
            .second(.twoDigits)

        return SettingsView(
            topic: topic.settingsTopic,
            save: topic.apply,
            onExport: {
                let csv = Export.csvString(from: exportEntries, dateStyle: style)
                let filename = Export.suggestedFilename(for: exportTopicName)
                // Prefer Documents over tmp for share sheet / Files app compatibility.
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let url = docs.appendingPathComponent(filename)
                try? csv.write(to: url, atomically: true, encoding: .utf8)
                return url
            }
        )
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func makeSettingsViewForNewTopic(withSortIndex sortIndex: Int) -> some View {
        SettingsView(
            topic: .new,
            save: {
                let newTopic = TopicEntity(from: $0, at: sortIndex)
                modelContext.insert(newTopic)
                showTopic(newTopic)
            }
            // onExport uses default (dummy URL) for new topics
        )
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private func showTopic(_ topic: TopicEntity?) {
        guard let topic else { return }
        path = [.topicView(topic)]
    }

    private func showNewTopicCreation(sortIndex: Int) {
        newTopicSortIndex = IdentifiableSortIndex(value: sortIndex)
    }

    private func showEntryList(for topic: TopicEntity) {
        path.append(.entryListView(topic))
    }
}
