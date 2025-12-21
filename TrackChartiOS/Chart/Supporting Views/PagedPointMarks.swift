//
//  PagedPointMarks.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 07.11.25.
//

import SwiftUI
import Charts
import DataProcessing
import Presentation

struct PagedPointMarks {
    let palette: Palette
    let xLabel: String
    let yLabel: String

    @ChartContentBuilder
    func pointMark(for entry: ViewEntry, on page: ChartViewPage) -> some ChartContent {
        if page.isMaxEntry(entry) || isPositiveAndToday(entry) {
            PointMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                .symbol(symbol: pointSymbol)
                .annotation(position: .top, spacing: 2) { highValueAnnotation(for: entry, on: page) }
        }

        if page.isMinEntry(entry) || isNegativeAndToday(entry) {
            PointMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                .symbol(symbol: pointSymbol)
                .annotation(position: .bottom, spacing: 2) { lowValueAnnotation(for: entry, on: page) }
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
    private func highValueAnnotation(for entry: ViewEntry, on page: ChartViewPage) -> some View {
        annotation(for: entry.value)
    }

    @ViewBuilder
    private func lowValueAnnotation(for entry: ViewEntry, on page: ChartViewPage) -> some View {
        annotation(for: entry.value)
    }

    private func isPositiveAndToday(_ entry: ViewEntry) -> Bool {
        isToday(entry) && entry.value >= 0
    }

    private func isNegativeAndToday(_ entry: ViewEntry) -> Bool {
        isToday(entry) && entry.value < 0
    }

    private func isToday(_ entry: ViewEntry) -> Bool {
        Calendar.current.isDateInToday(entry.timestamp)
    }

    private func annotation(for value: Double) -> some View {
        let formattedValue = value.formatted(.number.precision(.fractionLength(0...2)))

        return Text(formattedValue)
            .font(.caption)
            .foregroundColor(palette.primary)
    }
}
