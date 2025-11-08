//
//  ChartView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Charts

enum ChartMode {
    case paged(TimeSpan, defaultAggregator: ChartDataProvider)
    case preview
    case overview
}

struct ChartView<Placeholder: View>: View {
    let rawEntries: [ChartEntry]
    let palette: Palette
    let mode: ChartMode
    private let placeholder: () -> Placeholder

    init(rawEntries: [ChartEntry], palette: Palette, mode: ChartMode, placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init) {
        self.rawEntries = rawEntries
        self.palette = palette
        self.mode = mode
        self.placeholder = placeholder
    }

    var body: some View {
        switch mode {
        case .paged(let span, let aggregator):
            PagedChartView(rawEntries: rawEntries, span: span, defaultAggregator: aggregator, palette: palette, placeholder: placeholder)
        case .preview:
            PreviewChartView(rawEntries: rawEntries, palette: palette, placeholder: placeholder)
        case .overview:
            OverviewChartView(rawEntries: rawEntries, palette: palette, placeholder: placeholder)
        }
    }
}

#Preview {
    let entries: [ChartEntry] = [
        .init(value: 2.3, timestamp: .now.advanced(by: -86_400 * 16)),
        .init(value: -2.3, timestamp: .now.advanced(by: -86_400 * 15)),
        .init(value: 2.5, timestamp: .now.advanced(by: -86_400 * 14)),
        .init(value: 1.3, timestamp: .now.advanced(by: -86_400 * 13)),
        .init(value: 0, timestamp: .now.advanced(by: -86_400 * 12)),
        .init(value: -1, timestamp: .now.advanced(by: -86_400 * 11)),
        .init(value: 2, timestamp: .now.advanced(by: -86_400 * 10)),
        .init(value: 1, timestamp: .now.advanced(by: -86_400 * 9)),
        .init(value: 2.3, timestamp: .now.advanced(by: -86_400 * 8)),
        .init(value: -2.3, timestamp: .now.advanced(by: -86_400 * 7)),
        .init(value: 2.5, timestamp: .now.advanced(by: -86_400 * 6)),
        .init(value: 1.3, timestamp: .now.advanced(by: -86_400 * 5)),
        .init(value: 0, timestamp: .now.advanced(by: -86_400 * 4)),
        .init(value: -1, timestamp: .now.advanced(by: -86_400 * 3)),
        .init(value: 0, timestamp: .now.advanced(by: -86_400 * 2)),
        .init(value: 2, timestamp: .now.advanced(by: -86_400 * 1.8)),
        .init(value: 4, timestamp: .now.advanced(by: -86_400 * 1.4)),
        .init(value: 1, timestamp: .now.advanced(by: -86_400 * 1)),
        .init(value: -1, timestamp: .now.advanced(by: -86_400 * 0.9)),
        .init(value: 3, timestamp: .now.advanced(by: -86_400 * 0.4))
    ]

    ScrollView {
        VStack {
            ChartView(rawEntries: entries, palette: .fire, mode: .preview).frame(height: 260).card(padding: nil)
            ChartView(rawEntries: entries, palette: .fire, mode: .overview).frame(height: 260).card(padding: nil)
            ChartView(rawEntries: entries, palette: .fire, mode: .paged(.week, defaultAggregator: .dailySum)).frame(height: 260).card()
            ChartView(rawEntries: [], palette: .arcticIce, mode: .preview).frame(height: 260).card(padding: nil)
        }
        .padding()
    }
}
