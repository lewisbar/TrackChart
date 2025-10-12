//
//  ChartPlaceholderView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 17.09.25.
//

import SwiftUI

struct ChartPlaceholderView: View {
    var body: some View {
        Text("No data yet")
            .foregroundStyle(.secondary)
            .tint(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
    }
}

#Preview {
    ChartPlaceholderView()
}
