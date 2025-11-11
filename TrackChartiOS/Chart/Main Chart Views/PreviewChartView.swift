//
//  PreviewChartView.swift
//  TrackChartiOS
//
//  Created by Lennar tWisbar on 31.10.25.
//

import SwiftUI
import Charts

struct PreviewChartView<Placeholder: View>: View {
    let entries: [ProcessedEntry]
    let palette: Palette
    private let placeholder: () -> Placeholder
    private let xLabel = "Date"
    private let yLabel = "Value"

    init(rawEntries: [ChartEntry], palette: Palette, placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init) {
        let provider = ChartDataProvider.automaticPreview()
        self.entries = provider.processedEntries(from: rawEntries)
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
            .chartXScale(domain: dateRange)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
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
}
