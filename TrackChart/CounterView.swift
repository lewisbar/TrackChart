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
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            Spacer()

            minusButton
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            CountLabel(count: count)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)

            plusButton
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            Spacer()

            submitButton
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

        }
    }

    private var plusButton: some View {
        CircleButton(
            action: { count += 1 },
            image: Image(systemName: "plus"),
            color: .green
        )
    }

    private var minusButton: some View {
        CircleButton(
            action: { count -= 1 },
            image: Image(systemName: "minus"),
            color: .red
        )
    }

    private var submitButton: some View {
        CircleButton(
            action: {
                submitNewValue(count)
                count = 0
            },
            image: Image(systemName: "checkmark"),
            color: .green)
    }

    private var deleteButton: some View {
        CircleButton(
            action: deleteLastValue,
            image: Image(systemName: "xmark"),
            color: .red
        )
    }
}

#Preview {
    CounterView(submitNewValue: { _ in }, deleteLastValue: {})
//        .environment(\.layoutDirection, .rightToLeft)
}
