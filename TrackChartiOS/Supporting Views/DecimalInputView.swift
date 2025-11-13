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
    private let dismissesOnSubmit: Bool

    // Controls whether the date picker is shown
    @State private var isEditingTimestamp = false

    init(
        initialValue: Double = 0,
        initialTimestamp: Date? = nil,
        submit: @escaping (Double, Date) -> Void,
        dismiss: @escaping () -> Void,
        dismissesOnSubmit: Bool = false
    ) {
        self.model = DecimalInputViewModel(initialValue: initialValue, initialTimestamp: initialTimestamp, submit: submit)
        self.dismiss = dismiss
        self.dismissesOnSubmit = dismissesOnSubmit
    }

    var body: some View {
        VStack {
            displayLabel
                .padding(.top, 10)

            timestampEditor
                .padding(.horizontal)
                .padding(.vertical, 4)

            Divider()

            numberPad
                .padding(.horizontal)

            controlButtons
                .padding(.bottom, 15)
        }
        .background(Color(uiColor: .systemBackground))
        .presentationDetents([.fraction(0.52)])
    }

    private var displayLabel: some View {
        Text(model.value)
            .font(.largeTitle)
            .frame(maxHeight: 40)
    }

    private var timestampEditor: some View {
        HStack {
            if isEditingTimestamp {
                // Compact picker
                DatePicker(
                    "",
                    selection: Binding(
                        get: { model.selectedTimestamp ?? Date() },
                        set: { model.setTimestamp($0) }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .clipped()
                .frame(maxWidth: .infinity, alignment: .leading)

                // Cancel editing → back to "Now"
                Button {
                    model.clearTimestamp()
                    withAnimation(.easeInOut) {
                        isEditingTimestamp = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                // Collapsed label
                Button {
                    withAnimation(.easeInOut) {
                        isEditingTimestamp = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(model.timestampDisplay)
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                // Clear only when a date is set
                if model.selectedTimestamp != nil {
                    Button {
                        model.clearTimestamp()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .font(.title3)
        .frame(height: 44)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            // Collapse picker when tapping outside the picker area
            if isEditingTimestamp {
                withAnimation(.easeInOut) {
                    isEditingTimestamp = false
                }
            }
        }
    }

    private var numberPad: some View {
        VStack(spacing: 10) {
            ForEach(model.keys, id: \.self) { row in
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
                .accessibilityLabel("Change sign")

            Button("Submit", action: {
                model.submitNumber()
                if dismissesOnSubmit { dismiss() }
                // Collapse picker after submit
                withAnimation(.easeInOut) {
                    isEditingTimestamp = false
                }
            })
            .buttonStyle(.borderedProminent)

            Button("Hide", action: dismiss)
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    DecimalInputView(submit: { _, _ in }, dismiss: {})
}
