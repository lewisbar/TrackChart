//
//  CounterView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        Stepper(
            label: {
                Text("\(count)")
            }, onIncrement: {
                count += 1
            }, onDecrement: {
                count -= 1
            }
        )
    }
}

#Preview {
    CounterView()
}
