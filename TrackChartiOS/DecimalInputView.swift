//
//  DecimalInputView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 23.10.25.
//

import SwiftUI

struct DecimalInputView: View {
    @State private var model: DecimalInputViewModel
    private let dismiss: () -> Void

    init(submitValue: @escaping (Double) -> Void, dismiss: @escaping () -> Void) {
        self.model = DecimalInputViewModel(submitValue: submitValue)
        self.dismiss = dismiss
    }

    var body: some View {
        VStack {
            displayLabel
                .padding(.top, 10)

            Divider()

            numberPad
                .padding(.horizontal)

            controlButtons
                .padding(.bottom, 15)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var displayLabel: some View {
        Text(model.value)
            .font(.largeTitle)
            .frame(maxHeight: 40)
    }

    private var numberPad: some View {
        VStack(spacing: 10) {
            ForEach([
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                [".", "0", "⌫"]
            ], id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        numberButton(for: key)
                    }
                }
            }
        }
    }

    private func numberButton(for key: String) -> some View {
        Button(action: { model.handleInput(key) }) {
            Text(key)
                .frame(maxWidth: .infinity, maxHeight: 80)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .font(.title2)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button("+/-", action: model.toggleSign)
                .buttonStyle(.bordered)

            Button("Submit", action: model.submitNumber)
                .buttonStyle(.borderedProminent)

            Button("Hide", action: dismiss)
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    DecimalInputView(submitValue: { _ in }, dismiss: {})
}
