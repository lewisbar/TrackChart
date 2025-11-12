//
//  TopicView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct TopicView: View {
    @Binding var name: String
    @Binding var palette: Palette
    let entries: [ChartEntry]
    let submitNewValue: (Double) -> Void
    let deleteLastValue: () -> Void
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
            DecimalInputView(submitValue: submitNewValue, dismiss: { isShowingInput = false })
                .presentationDetents([.fraction(0.45)])
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(name: name, palette: palette, rename: { name = $0 }, changePalette: { palette = $0 })
        }
        .onAppear {
            if name.isEmpty {
                isShowingSettings = true
            }
        }
    }

    private var chartList: some View {
        List {
            overviewChart
            pagedCard(span: .week,       default: .dailySum())
            pagedCard(span: .month,      default: .dailySum())
            pagedCard(span: .oneYear,    default: .monthlySum())
            Spacer()
        }
    }

    private var overviewChart: some View {
        ChartView(rawEntries: entries, palette: palette, mode: .overview)
            .frame(height: 150)
            .padding(.top)
            .padding(.horizontal)
    }

    private func pagedCard(span: TimeSpan, default aggregator: ChartDataProvider) -> some View {
        ChartView(
            rawEntries: entries,
            palette: palette,
            mode: .paged(span, defaultAggregator: aggregator)
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
        .accessibilityHint("Add a new entry")
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
        .accessibilityLabel("Settings button")
    }

    private func showSettings() {
        isShowingSettings = true
    }
}

#Preview {
    TopicView(
        name: .constant("Topic 1"),
        palette: .constant(.ocean),
        entries: [1, 2, 4, 8, 17, 3, 0, -2, -8, -3, 1].enumerated().map { index, value in
            ChartEntry(
                value: Double(value),
                timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
            )
        },
        submitNewValue: { _ in },
        deleteLastValue: {}
    )
}
