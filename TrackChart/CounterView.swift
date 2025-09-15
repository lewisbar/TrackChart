//
//  CounterView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct CounterView: View {
    @Binding var count: Int
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
                Text("\(count)")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 4)
            }, onIncrement: {
                count += 1
            }, onDecrement: {
                count -= 1
            }
        )
    }

    private var submitButton: some View {
        Button(action: {
            submit(count)
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
    @Previewable @State var count = 4

    CounterView(count: $count, submit: { _ in count = 0 })
//        .environment(\.layoutDirection, .rightToLeft)
}
