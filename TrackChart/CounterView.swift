//
//  CounterView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct CounterView: View {
    @State private var count = 0
    let submit: (Int) -> Void

    var body: some View {
        HStack {
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
            submit(count)
            count = 0
        }) {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.title2)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }
}

#Preview {
    CounterView(submit: { _ in })
//        .environment(\.layoutDirection, .rightToLeft)
}
