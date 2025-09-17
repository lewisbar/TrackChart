//
//  ChartPlaceholderView.swift
//  TrackChart
//
//  Created by LennartWisbar on 17.09.25.
//

import SwiftUI

struct ChartPlaceholderView: View {
    var body: some View {
        Text("Start adding data points using the buttons above.")
            .multilineTextAlignment(.center)
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(.bottom, 50)
    }
}

#Preview {
    ChartPlaceholderView()
}
