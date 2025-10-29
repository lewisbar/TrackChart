//
//  TopicView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Presentation

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
            SettingsView(name: $name, palette: $palette)
        }
        .onAppear {
            if name.isEmpty {
                isShowingSettings = true
            }
        }
    }

    private var chartList: some View {
        List {
            chartCard(named: "Raw Data", dataProvider: .raw)
            chartCard(named: "Daily Sum", dataProvider: .dailySum)
            chartCard(named: "Daily Average", dataProvider: .dailyAverage)
            chartCard(named: "Weekly Sum", dataProvider: .weeklySum)

            Spacer()
        }
    }

    private func chartCard(named title: String, dataProvider: ChartDataProvider) -> some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)

            ChartView(rawEntries: entries, dataProvider: dataProvider, palette: palette)
        }
        .card()
        .frame(height: 220)
        .listRowSeparator(.hidden)
    }

    private var plusButton: some View {
        VStack {
            Spacer()
            CircleButton(action: showNumpad, image: Image(systemName: "plus"), color: .blue)
                .padding(.bottom)
        }
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
    }

    private func showSettings() {
        isShowingSettings = true
    }
}

#Preview {
    TopicView(
        name: .constant("Topic 1"),
        palette: .constant(.ocean),
        entries: [1, 2, 4, 8, 7, 3, 0, -2, -8, -3, 1].enumerated().map { index, value in
            ChartEntry(
                value: Double(value),
                timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
            )
        },
        submitNewValue: { _ in },
        deleteLastValue: {}
    )
    .padding()
}
