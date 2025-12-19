//
//  ChartView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Charts
import Presentation

struct ChartView<Placeholder: View>: View {
    let topic: ViewTopic
    let mode: ChartMode
    private let placeholder: () -> Placeholder

    init(topic: ViewTopic, mode: ChartMode, placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init) {
        self.topic = topic
        self.mode = mode
        self.placeholder = placeholder
    }

    var body: some View {
        switch mode {
        case let .paged(span):
            let pages = span.pages(for: topic)
            PagedChartView(pages: pages, aggregator: topic.aggregator, palette: topic.palette, placeholder: placeholder)
        case .preview:
            PreviewChartView(entries: topic.entries, palette: topic.palette, placeholder: placeholder)
        case .overview:
            OverviewChartView(entries: topic.entries, palette: topic.palette, placeholder: placeholder)
        }
    }
}

#Preview {
    let entries: [ViewEntry] = [
        .init(id: UUID(), value: 2.3, timestamp: .now.advanced(by: -86_400 * 16)),
        .init(id: UUID(), value: -2.3, timestamp: .now.advanced(by: -86_400 * 15)),
        .init(id: UUID(), value: 2.5, timestamp: .now.advanced(by: -86_400 * 14)),
        .init(id: UUID(), value: 1.3, timestamp: .now.advanced(by: -86_400 * 13)),
        .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -86_400 * 12)),
        .init(id: UUID(), value: -1, timestamp: .now.advanced(by: -86_400 * 11)),
        .init(id: UUID(), value: 2, timestamp: .now.advanced(by: -86_400 * 10)),
        .init(id: UUID(), value: 1, timestamp: .now.advanced(by: -86_400 * 9)),
        .init(id: UUID(), value: 2.3, timestamp: .now.advanced(by: -86_400 * 8)),
        .init(id: UUID(), value: -2.3, timestamp: .now.advanced(by: -86_400 * 7)),
        .init(id: UUID(), value: 2.5, timestamp: .now.advanced(by: -86_400 * 6)),
        .init(id: UUID(), value: 1.3, timestamp: .now.advanced(by: -86_400 * 5)),
        .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -86_400 * 4)),
        .init(id: UUID(), value: -1, timestamp: .now.advanced(by: -86_400 * 3)),
        .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -86_400 * 2)),
        .init(id: UUID(), value: 2, timestamp: .now.advanced(by: -86_400 * 1.8)),
        .init(id: UUID(), value: 4, timestamp: .now.advanced(by: -86_400 * 1.4)),
        .init(id: UUID(), value: 1, timestamp: .now.advanced(by: -86_400 * 1)),
        .init(id: UUID(), value: -1, timestamp: .now.advanced(by: -86_400 * 0.9)),
        .init(id: UUID(), value: 3, timestamp: .now.advanced(by: -86_400 * 0.4))
    ]
    let topic = ViewTopic(id: UUID(), name: "A Topic", details: "Some details", entries: entries, aggregator: .average, treatsMissingAsZero: true, palette: .arcticIce)

    ScrollView {
        VStack {
            ChartView(topic: topic, mode: .preview).frame(height: 260).card(padding: nil)
            ChartView(topic: topic, mode: .overview).frame(height: 260).card(padding: nil)
            ChartView(topic: topic, mode: .paged(.week)).frame(height: 260).card(padding: nil)
            ChartView(topic: topic, mode: .paged(.month)).frame(height: 260).card(padding: nil)
            ChartView(topic: topic, mode: .paged(.year)).frame(height: 260).card(padding: nil)
        }
        .padding()
    }
}
