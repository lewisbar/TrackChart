//
//  UnpagedPointMarks.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 07.11.25.
//

import SwiftUI
import Charts
import Presentation

struct UnpagedPointMarks {
    let palette: Palette
    let xLabel: String
    let yLabel: String

    @ChartContentBuilder
    func pointMark(for entry: ViewEntry, in entries: [ViewEntry]) -> some ChartContent {
        if entries.count == 1 {
            PointMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                .symbol(symbol: pointSymbol)
        }
    }

    private func pointSymbol() -> some View {
        ZStack {
            Circle().fill(palette.pointFill)
            Circle().stroke(palette.pointOutline, lineWidth: 2)
        }
        .frame(width: 6)
    }
}
