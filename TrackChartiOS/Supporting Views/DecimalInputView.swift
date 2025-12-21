//
//  DecimalInputView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 23.10.25.
//

import SwiftUI
import Presentation
import AudioToolbox

struct DecimalInputView: View {
    @State private var model: DecimalInputViewModel
    private let dismiss: () -> Void
    private let dismissesOnSubmit: Bool

    @State private var flyingValue: Double? = nil
    @State private var isSubmitting = false
    @State private var isDimmed = false

    // Controls whether the date picker is shown
    @State private var isEditingTimestamp = false

    init(
        initialValue: Double = 0,
        initialTimestamp: Date? = nil,
        submit: @escaping (Double, Date) -> Void,
        dismiss: @escaping () -> Void,
        dismissesOnSubmit: Bool = false
    ) {
        self.model = DecimalInputViewModel(initialValue: initialValue, initialTimestamp: initialTimestamp, submit: submit, nowDescription: String(localized: .now))
        self.dismiss = dismiss
        self.dismissesOnSubmit = dismissesOnSubmit
    }

    var body: some View {
        mainView
            .presentationDetents([.fraction(0.54)])
            .sensoryFeedback(.increase, trigger: flyingValue, condition: { isPositive($1) })
            .sensoryFeedback(.decrease, trigger: flyingValue, condition: { !isPositive($1) })
    }

    func isPositive(_ number: Double?) -> Bool {
        number ?? -1 >= 0
    }

    private var mainView: some View {
        VStack {
            displayLabel
                .padding(.top, 16)

            timestampEditor
                .padding(.horizontal)
                .padding(.bottom, 4)

            Divider()

            numberPad
                .padding(.horizontal)
                .padding(.bottom, 16)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var displayLabel: some View {
        ZStack {
            Text(model.value)
                .font(.largeTitle)
                .opacity(isDimmed ? 0.3 : 1.0)
                .animation(.easeOut(duration: 0.2), value: isDimmed)

            flyingText
        }
        .frame(maxHeight: 40)
    }

    @ViewBuilder
    private var flyingText: some View {
        if let flying = formattedFlyingValue {
            Text(flying)
                .font(.largeTitle)
                .foregroundColor(flying.hasPrefix("-") ? .red : .green)
                .scaleEffect(isSubmitting ? 1.2 : 1)
                .offset(y: isSubmitting ? -20 : 0)   // Fly upward
                .opacity(isSubmitting ? 0 : 1)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                .animation(.easeOut(duration: 0.5), value: isSubmitting)
                .onAppear(perform: giveSubmissionFeedback)
        }
    }

    private func giveSubmissionFeedback() {
        startDisplayDimmingAnimation()
        startFlyingNumberAnimation()
        giveAudioFeedback()
        if dismissesOnSubmit { dismissAfterDelay() }
    }

    private func startDisplayDimmingAnimation() {
        isDimmed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                isDimmed = false
            }
        }
    }

    private func startFlyingNumberAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            isSubmitting = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            flyingValue = nil
            isSubmitting = false
        }
    }

    private func giveAudioFeedback() {
        let value = flyingValue ?? 0
        if value >= 0 {
            AudioServicesPlaySystemSound(1103)
        } else if value < 0 {
            AudioServicesPlaySystemSound(1105)
        }
    }

    private func dismissAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dismiss()
        }
    }

    private var formattedFlyingValue: String? {
        flyingValue?.formatted(.number
            .sign(strategy: .always())
            .precision(.fractionLength(0...2))
        )
    }

    private var timestampEditor: some View {
        Group {
            if isEditingTimestamp {
                datePicker
            } else {
                nowButton
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

    private var datePicker: some View {
        HStack {
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
            .tint(.primary)
        }
    }

    private var nowButton: some View {
        HStack {
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
            .tint(.primary)

            // Clear only when a date is set
            if model.selectedTimestamp != nil {
                Button {
                    model.clearTimestamp()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .tint(.primary)
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
            Divider()
            controlButtons
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
        HStack(spacing: 10) {
            toggleSignButton
            submitButton
            hideButton
        }
    }

    private var toggleSignButton: some View {
        Button(action: model.toggleSign) {
            Text("+/-")
                .frame(maxWidth: .infinity, maxHeight: 80)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(.changeSign)
    }

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            Text(.submit)
                .frame(maxWidth: .infinity, maxHeight: 80)
        }
        .buttonStyle(.borderedProminent)
    }

    private func submit() {
        model.submitNumber { submittedDouble in
            DispatchQueue.main.async {
                flyingValue = submittedDouble
            }
        }

        // Collapse picker after submit
        withAnimation(.easeInOut) {
            isEditingTimestamp = false
        }
    }

    private var hideButton: some View {
        Button(action: dismiss) {
            Text(.hide)
                .frame(maxWidth: .infinity, maxHeight: 80)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    DecimalInputView(submit: { _, _ in }, dismiss: {})
}
