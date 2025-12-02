//
//  TopicView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Presentation

struct TopicView<Settings: View>: View {
    let topic: ViewTopic
    let submitNewValue: (Double, Date) -> Void
    let settingsView: () -> Settings
    let showEntryList: () -> Void
    @State private var isShowingSettings = false
    @State private var isShowingInput = false
    @State private var enteredValue: Double? = nil

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            chartList
            plusButton
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(topic.name)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: chevronOnlyBackButton)
            ToolbarItem(placement: .topBarTrailing, content: settingsButton)
        }
        .sheet(isPresented: $isShowingInput) {
            DecimalInputView(submit: submitNewValue, dismiss: { isShowingInput = false })
        }
        .sheet(isPresented: $isShowingSettings) {
            settingsView()
        }
        .onAppear {
            if topic.name.isEmpty {
                isShowingSettings = true
            }
        }
    }

    private var chartList: some View {
        List {
            if topic.entries.isEmpty { tutorialView } else { overviewChart }
            entriesCell
            pagedCard(.week)
            pagedCard(.month)
            pagedCard(.year)
        }
        .safeAreaInset(edge: .bottom) {
            // Make room for the plus button
            Color.clear.frame(height: 36)
        }
    }

    private var overviewChart: some View {
        ChartView(topic: topic, mode: .overview)
            .frame(height: 150)
            .padding(.top)
            .padding(.horizontal)
    }

    private var tutorialView: some View {
        Text(.noEntriesYet)
            .foregroundColor(.secondary)
            .padding()
    }

    private var entriesCell: some View {
        Button(action: showEntryList) {
            HStack {
                Text(.entries(topic.entries.count))
                    .tint(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .tint(.secondary)
            }
            .padding()
            .card()
        }
    }

    private func pagedCard(_ span: ViewTimeSpan) -> some View {
        ChartView(
            topic: topic,
            mode: .paged(span)
        )
        .card()
        .frame(height: 260)
        .listRowSeparator(.hidden)
    }

    private var plusButton: some View {
        VStack {
            Spacer()
            CircleButton(action: showNumpad, image: Image(systemName: "plus"), color: .blue)
                .padding(.bottom)
        }
        .accessibilityHint(.addANewEntry)
    }

    private func showNumpad() {
        isShowingInput = true
    }

    private func chevronOnlyBackButton() -> some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
        }
        .tint(.secondary)
    }

    private func settingsButton() -> some View {
        Button(action: showSettings) {
            Image(systemName: "gearshape.fill")
        }
        .tint(.secondary)
        .accessibilityLabel(.settingsButton)
    }

    private func showSettings() {
        isShowingSettings = true
    }
}

#Preview {
    let entries = [1, 2, 4, 8, 17, 3, 0, -2, -8, -3, 1].enumerated().map { index, value in
        ViewEntry(
            id: UUID(),
            value: Double(value),
            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
        )
    }

    TopicView(
        topic: ViewTopic(id: UUID(), name: "Topic 1", entries: entries, aggregator: .average, treatsMissingAsZero: true, palette: .arcticIce),
        submitNewValue: { _, _ in },
        settingsView: EmptyView.init,
        showEntryList: {}
    )
}
