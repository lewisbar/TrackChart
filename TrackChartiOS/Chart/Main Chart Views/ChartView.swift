//
//  ChartView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Charts
import DataProcessing
import Presentation

enum ChartMode {
    case paged(TimeSpan, dataProvider: ChartDataProvider)
    case preview
    case overview
}

struct ChartView<Placeholder: View>: View {
    let rawEntries: [ChartEntry]
    let aggregator: Aggregator
    let treatsMissingAsZero: Bool
    let palette: Palette
    let mode: ChartMode
    private let placeholder: () -> Placeholder

    init(rawEntries: [ChartEntry], aggregator: Aggregator, treatsMissingAsZero: Bool, palette: Palette, mode: ChartMode, placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init) {
        self.rawEntries = rawEntries
        self.aggregator = aggregator
        self.treatsMissingAsZero = treatsMissingAsZero
        self.palette = palette
        self.mode = mode
        self.placeholder = placeholder
    }

    var body: some View {
        switch mode {
        case .paged(let span, let dataProvider):
            PagedChartView(rawEntries: rawEntries, span: span, dataProvider: dataProvider, palette: palette, placeholder: placeholder)
        case .preview:
            PreviewChartView(rawEntries: rawEntries, aggregator: aggregator, treatsMissingAsZero: treatsMissingAsZero, palette: palette, placeholder: placeholder)
        case .overview:
            OverviewChartView(rawEntries: rawEntries, aggregator: aggregator, treatsMissingAsZero: treatsMissingAsZero, palette: palette, placeholder: placeholder)
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
            ChartView(rawEntries: entries, aggregator: .sum, treatsMissingAsZero: true, palette: .fire, mode: .preview).frame(height: 260).card(padding: nil)
            ChartView(rawEntries: entries, aggregator: .sum, treatsMissingAsZero: false, palette: .fire, mode: .overview).frame(height: 260).card(padding: nil)
            ChartView(rawEntries: entries, aggregator: .sum, treatsMissingAsZero: true, palette: .fire, mode: .paged(.week, dataProvider: .dailySum(treatsMissingAsZero: true))).frame(height: 260).card()
            ChartView(rawEntries: [], aggregator: .sum, treatsMissingAsZero: false, palette: .arcticIce, mode: .preview).frame(height: 260).card(padding: nil)
        }
        .padding()
    }
}
