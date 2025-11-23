//
//  TopicView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import DataProcessing

struct TopicView<Settings: View>: View {
    @Binding var name: String
    @Binding var palette: Palette
    @Binding var aggregator: Aggregator
    let entries: [ChartEntry]
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
        .navigationTitle(name)
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
            if name.isEmpty {
                isShowingSettings = true
            }
        }
    }

    private var chartList: some View {
        List {
            if entries.isEmpty { tutorialView } else { overviewChart }
            entriesCell
            pagedCard(span: .week,       dataProvider: aggregator == .sum ? .dailySum() : .dailyAverage())
            pagedCard(span: .month,      dataProvider: aggregator == .sum ? .dailySum() : .dailyAverage())
            pagedCard(span: .oneYear,    dataProvider: aggregator == .sum ? .monthlySum() : .monthlyAverage())
        }
        .safeAreaInset(edge: .bottom) {
            // Make room for the plus button
            Color.clear.frame(height: 36)
        }
    }

    private var overviewChart: some View {
        ChartView(rawEntries: entries, aggregator: aggregator, palette: palette, mode: .overview)
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
                Text(.entries(entries.count))
                    .tint(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .tint(.secondary)
            }
            .padding()
            .card()
        }
    }

    private func pagedCard(span: TimeSpan, dataProvider: ChartDataProvider) -> some View {
        ChartView(
            rawEntries: entries,
            aggregator: aggregator,
            palette: palette,
            mode: .paged(span, dataProvider: dataProvider)
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
        ChartEntry(
            value: Double(value),
            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
        )
    }

    TopicView(
        name: .constant("Topic 1"),
        palette: .constant(.ocean),
        aggregator: .constant(.sum),
        entries: entries,
        submitNewValue: { _, _ in },
        settingsView: EmptyView.init,
        showEntryList: {}
    )
}
