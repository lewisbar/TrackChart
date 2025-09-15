//
//  CounterView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct CounterView: View {
    @State private var count = 0
    let submitNewValue: (Int) -> Void
    let deleteLastValue: () -> Void

    var body: some View {
        HStack {
            deleteButton
            stepper
            submitButton
        }
    }

    private var stepper: some View {
        Stepper(
            label: {
                stepperLabel
            }, onIncrement: {
                count += 1
            }, onDecrement: {
                count -= 1
            }
        )
    }

    private var stepperLabel: some View {
        Text("\(count)")
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 4)
    }

    private var submitButton: some View {
        Button(action: {
            submitNewValue(count)
            count = 0
        }) {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.title2)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }

    private var deleteButton: some View {
        Button(action: {
            deleteLastValue()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.red)
                .font(.title2)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }
}

#Preview {
    CounterView(submitNewValue: { _ in }, deleteLastValue: {})
//        .environment(\.layoutDirection, .rightToLeft)
}
