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
            Spacer()
            minusButton
            CountLabel(count: count)
            plusButton
            Spacer()
            submitButton
        }
    }

    private var plusButton: some View {
        Button(action: {
            count += 1
        }) {
            Image(systemName: "plus")
                .foregroundColor(.green)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }

    private var minusButton: some View {
        Button(action: {
            count -= 1
        }) {
            Image(systemName: "minus")
                .foregroundColor(.red)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }

    private var submitButton: some View {
        Button(action: {
            submitNewValue(count)
            count = 0
        }) {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
                .font(.title2)
                .frame(minWidth: 24, minHeight: 24)
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
                .frame(minWidth: 24, minHeight: 24)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
        }
    }
}

#Preview {
    CounterView(submitNewValue: { _ in }, deleteLastValue: {})
//        .environment(\.layoutDirection, .rightToLeft)
}
