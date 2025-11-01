//
//  PreviewChartView.swift
//  TrackChartiOS
//
//  Created by LennartWisbar on 31.10.25.
//

import SwiftUI
import Charts

struct PreviewChartView: View {
    let entries: [ProcessedEntry]
    let palette: Palette

    var body: some View {
        if entries.isEmpty {
            ChartPlaceholderView()
        } else {
            Chart(entries) { entry in
                AreaMark(x: .value("Date", entry.timestamp), y: .value("Value", entry.value))
                    .foregroundStyle(areaGradient)
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Date", entry.timestamp), y: .value("Value", entry.value))
                    .foregroundStyle(palette.primary)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .shadow(color: palette.shadow, radius: 2)
                    .interpolationMethod(.catmullRom)
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

// Auto-aggregation
extension PreviewChartView {
    init(rawEntries: [ChartEntry], palette: Palette) {
        let provider = ChartDataProvider.automaticPreview
        let processed = provider.processedEntries(from: rawEntries)
        self.entries = Array(processed.prefix(60))
        self.palette = palette
    }
}
