//
//  OverviewChartView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 01.11.25.
//

import SwiftUI
import Charts
import Presentation

struct OverviewChartView: View {
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
            .chartXAxis(content: xAxisContent)
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
}

// Auto-aggregation
extension OverviewChartView {
    init(rawEntries: [ChartEntry], palette: Palette) {
        let provider = ChartDataProvider.automaticPreview
        let processed = provider.processedEntries(from: rawEntries)
        self.entries = Array(processed.prefix(60))
        self.palette = palette
    }
}
