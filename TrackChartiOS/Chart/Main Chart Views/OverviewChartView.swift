//
//  OverviewChartView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 01.11.25.
//

import SwiftUI
import Charts
import Presentation

struct OverviewChartView<Placeholder: View>: View {
    let entries: [ViewEntry]
    let palette: Palette
    private let placeholder: () -> Placeholder
    private let xLabel = String(localized: .date)
    private let yLabel = String(localized: .value)

    init(entries: [ViewEntry], palette: Palette, placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init) {
        self.entries = entries
        self.palette = palette
        self.placeholder = placeholder
    }

    var body: some View {
        if entries.isEmpty {
            placeholder()
        } else {
            Chart(entries) { entry in
                AreaMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                    .foregroundStyle(areaGradient)
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                    .foregroundStyle(palette.primary)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .shadow(color: palette.shadow, radius: 2)
                    .interpolationMethod(.catmullRom)
                UnpagedPointMarks(palette: palette, xLabel: xLabel, yLabel: yLabel)
                    .pointMark(for: entry, in: entries)
            }
            .chartXAxis(content: xAxisContent)
            .chartYAxis(content: yAxisContent)
        }
    }

    private var dateRange: ClosedRange<Date> {
        let dates = entries.map(\.timestamp)
        return (dates.min() ?? Date()) ... (dates.max() ?? Date())
    }

    private var areaGradient: LinearGradient {
        LinearGradient(stops: [
            .init(color: palette.top, location: 0),
            .init(color: palette.mid, location: 0.5),
            .init(color: palette.bottom, location: 1)
        ], startPoint: .top, endPoint: .bottom)
    }

    @AxisContentBuilder
    private func xAxisContent() -> some AxisContent {
        AxisMarks(preset: .aligned, values: .automatic(desiredCount: 3)) { _ in
            AxisValueLabel(collisionResolution: .greedy())
        }
    }

    @AxisContentBuilder
    private func yAxisContent() -> some AxisContent {
        AxisMarks(format: Decimal.FormatStyle.number.notation(.compactName))
    }
}
