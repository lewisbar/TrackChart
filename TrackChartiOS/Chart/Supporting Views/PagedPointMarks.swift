//
//  PagedPointMarks.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 07.11.25.
//

import SwiftUI
import Charts

struct PagedPointMarks {
    let palette: Palette
    let xLabel: String
    let yLabel: String

    @ChartContentBuilder
    func pointMark(for entry: ProcessedEntry, on page: ChartPage) -> some ChartContent {
        if page.isExtremum(entry) {
            PointMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                .symbol(symbol: pointSymbol)
                .annotation(position: .top, spacing: 2) { maxPositiveValueAnnotation(for: entry, on: page) }
                .annotation(position: .bottom, spacing: 2) { minNegativeValueAnnotation(for: entry, on: page) }
        }
    }

    private func pointSymbol() -> some View {
        ZStack {
            Circle().fill(palette.pointFill)
            Circle().stroke(palette.pointOutline, lineWidth: 2)
        }
        .frame(width: 6)
    }

    @ViewBuilder
    private func maxPositiveValueAnnotation(for entry: ProcessedEntry, on page: ChartPage) -> some View {
        if page.isMaxPositiveEntry(entry) {
            annotation(for: entry.value)
        }
    }

    @ViewBuilder
    private func minNegativeValueAnnotation(for entry: ProcessedEntry, on page: ChartPage) -> some View {
        if page.isMinNegativeEntry(entry) {
            annotation(for: entry.value)
        }
    }

    private func annotation(for value: Double) -> some View {
        let formattedValue = value.formatted(.number.precision(.fractionLength(0...2)))

        return Text("\(formattedValue)")
            .font(.caption)
            .foregroundColor(palette.primary)
    }
}
