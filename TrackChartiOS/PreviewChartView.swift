//
//  PreviewChartView.swift
//  TrackChartiOS
//
//  Created by LennartWisbar on 31.10.25.
//

import SwiftUI
import Charts
import Presentation

struct PreviewChartView: View {
    let entries: [ProcessedEntry]
    let palette: Palette

    var body: some View {
        if entries.isEmpty {
            ChartPlaceholderView()
        } else {
            Chart(entries) { entry in
                LineMark(x: .value("Date", entry.timestamp), y: .value("Value", entry.value))
                    .foregroundStyle(palette.primary)
                    .lineStyle(.init(lineWidth: 1.5))
            }
            .chartXScale(domain: dateRange)
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 3)) { _ in AxisValueLabel() } }
            .frame(height: 80)
        }
    }

    private var dateRange: ClosedRange<Date> {
        let dates = entries.map(\.timestamp)
        return (dates.min() ?? Date()) ... (dates.max() ?? Date())
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
