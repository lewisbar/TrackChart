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
    private let saver: SwiftDataSaver
    @Bindable private var errorHandler: ErrorHandler
    @State private var path = [TopicEntity]()

    init() {
        do {
            modelContainer = try ModelContainer(for: TopicEntity.self)
            let context = modelContainer.mainContext
            let errorHandler = ErrorHandler()
            self.errorHandler = errorHandler
            saver = SwiftDataSaver(
                contextHasChanges: { context.hasChanges },
                saveToContext: context.save,
                sendError: errorHandler.handleError
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(mainView: makeTopicListView)
                .alert(
                    errorHandler.alertTitle,
                    isPresented: $errorHandler.showAlert,
                    actions: { Button("OK", action: errorHandler.reset) },
                    message: { Text(errorHandler.alertMessage) }
                )
        }
        .modelContainer(modelContainer)
    }

    private func makeTopicListView() -> some View {
        NavigationStack(path: $path) {
            SwiftDataTopicListView(
                viewModel: SwiftDataTopicListViewModel(
                    save: saver.save,
                    insert: modelContext.insert,
                    delete: modelContext.delete,
                    showTopic: showTopic
                )
            )
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
