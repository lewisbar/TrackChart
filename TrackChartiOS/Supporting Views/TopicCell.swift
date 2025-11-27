//
//  TopicCell.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation

struct TopicCell: View {
    let topic: CellTopic
    let showTopic: () -> Void

    var body: some View {
        Button(action: action, label: label)
    }

    private func action() {
        showTopic()
    }

    private func label() -> some View {
        HStack {
            VStack {
                titleRow
                    .padding(.leading)

                chart
                    .padding(.leading)
                    .padding(.bottom)
            }
            .padding(.top)
            .padding(.bottom, 4)

            chevron
                .padding(.trailing, 4)
        }
        .padding(.horizontal, 4)
        .card()
        .frame(height: 150)
    }

    private var titleRow: some View {
        HStack(alignment: .center) {
            Text(topic.name)
                .tint(.primary)
                .font(.title3)
                .minimumScaleFactor(0.5)

            Spacer()

            Text(.entries(topic.entries.count))
                .tint(.secondary)
                .font(.caption)
        }
    }

    private var chart: some View {
        ChartView(
            rawEntries: topic.entries,
            aggregator: topic.aggregator,
            treatsMissingAsZero: topic.treatsMissingAsZero,
            palette: topic.palette,
            mode: .preview,
            placeholder: { ChartPlaceholderView().font(.footnote).padding(.bottom, 20) }
        )
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .tint(.secondary)
    }
}

#Preview {
    TopicCell(
        topic: CellTopic(
            id: UUID(),
            name: "Topic 1",
            entries: [
                .init(value: 0, timestamp: .now.advanced(by: -800)),
                .init(value: -3, timestamp: .now.advanced(by: -700)),
                .init(value: -2, timestamp: .now.advanced(by: -600)),
                .init(value: 1, timestamp: .now.advanced(by: -500)),
                .init(value: 5, timestamp: .now.advanced(by: -400)),
                .init(value: 9, timestamp: .now.advanced(by: -300)),
                .init(value: 10, timestamp: .now.advanced(by: -200))
            ],
            aggregator: .sum,
            treatsMissingAsZero: true,
            palette: .sunset
        ),
        showTopic: {}
    )
    .padding()

    TopicCell(
        topic: CellTopic(
            id: UUID(),
            name: "Topic 2",
            entries: [],
            aggregator: .sum,
            treatsMissingAsZero: false,
            palette: .coralReef
        ),
        showTopic: {}
    )
    .padding()
}
