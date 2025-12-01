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

//#Preview {
//    let entries: [ViewEntry] = [
//        .init(id: UUID(), value: 2.3, timestamp: .now.advanced(by: -86_400 * 16)),
//        .init(id: UUID(), value: -2.3, timestamp: .now.advanced(by: -86_400 * 15)),
//        .init(id: UUID(), value: 2.5, timestamp: .now.advanced(by: -86_400 * 14)),
//        .init(id: UUID(), value: 1.3, timestamp: .now.advanced(by: -86_400 * 13)),
//        .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -86_400 * 12)),
//        .init(id: UUID(), value: -1, timestamp: .now.advanced(by: -86_400 * 11)),
//        .init(id: UUID(), value: 2, timestamp: .now.advanced(by: -86_400 * 10)),
//        .init(id: UUID(), value: 1, timestamp: .now.advanced(by: -86_400 * 9)),
//        .init(id: UUID(), value: 2.3, timestamp: .now.advanced(by: -86_400 * 8)),
//        .init(id: UUID(), value: -2.3, timestamp: .now.advanced(by: -86_400 * 7)),
//        .init(id: UUID(), value: 2.5, timestamp: .now.advanced(by: -86_400 * 6)),
//        .init(id: UUID(), value: 1.3, timestamp: .now.advanced(by: -86_400 * 5)),
//        .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -86_400 * 4)),
//        .init(id: UUID(), value: -1, timestamp: .now.advanced(by: -86_400 * 3)),
//        .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -86_400 * 2)),
//        .init(id: UUID(), value: 2, timestamp: .now.advanced(by: -86_400 * 1.8)),
//        .init(id: UUID(), value: 4, timestamp: .now.advanced(by: -86_400 * 1.4)),
//        .init(id: UUID(), value: 1, timestamp: .now.advanced(by: -86_400 * 1)),
//        .init(id: UUID(), value: -1, timestamp: .now.advanced(by: -86_400 * 0.9)),
//        .init(id: UUID(), value: 3, timestamp: .now.advanced(by: -86_400 * 0.4))
//    ]
//
//    ScrollView {
//        VStack {
//            ChartView(mode: .preview(entries), aggregator: .sum, palette: .fire).frame(height: 260).card(padding: nil)
//            ChartView(mode: .overview(entries), aggregator: .sum, palette: .arcticIce).frame(height: 260).card(padding: nil)
//            ChartView(
//                mode: .paged(
//                    [
//                        .init(id: UUID(), entries: Array(entries.prefix(5)), title: "Page 1", dateRange: entries[0].timestamp...entries[4].timestamp, periodStart: entries[0].timestamp, aggregator: .average, aggregate: 20),
//                        .init(
//                            id: UUID(),
//                            entries: Array(entries.suffix(5)),
//                            title: "Page 2",
//                            dateRange: entries[entries.count-5].timestamp...entries[entries.count-1].timestamp,
//                            periodStart: entries[entries.count-5].timestamp,
//                            aggregator: .average,
//                            aggregate: 15
//                        )
//                    ]
//                ),
//                aggregator: .average,
//                palette: .aurora
//            ).frame(height: 260).card(padding: nil)
//        }
//        .padding()
//    }
//}
