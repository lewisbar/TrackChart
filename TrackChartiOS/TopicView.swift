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
    let entries: [ChartEntry]
    let submitNewValue: (Double) -> Void
    let deleteLastValue: () -> Void
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
        .toolbar { ToolbarItem(placement: .topBarLeading, content: chevronOnlyBackButton) }
        .sheet(isPresented: $isShowingInput) {
            DecimalInputView(submitValue: submitNewValue, dismiss: { isShowingInput = false })
                .presentationDetents([.fraction(0.45)])
        }
    }

    private var chartList: some View {
        List {
            ChartView(rawEntries: entries, dataProvider: .raw)
                .card()
                .frame(height: 180)
                .listRowSeparator(.hidden)

            ChartView(rawEntries: entries, dataProvider: .dailySum)
                .card()
                .frame(height: 180)
                .listRowSeparator(.hidden)

            ChartView(rawEntries: entries, dataProvider: .dailyAverage)
                .card()
                .frame(height: 180)
                .listRowSeparator(.hidden)

            ChartView(rawEntries: entries, dataProvider: .weeklySum)
                .card()
                .frame(height: 180)
                .listRowSeparator(.hidden)

            Spacer()
        }
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
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    TopicView(
        name: .constant("Topic 1"),
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
