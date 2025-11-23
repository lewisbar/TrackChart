//
//  TopicCell.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

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
                ChartEntry(value: 0, timestamp: .now.advanced(by: -800)),
                ChartEntry(value: -3, timestamp: .now.advanced(by: -700)),
                ChartEntry(value: -2, timestamp: .now.advanced(by: -600)),
                ChartEntry(value: 1, timestamp: .now.advanced(by: -500)),
                ChartEntry(value: 5, timestamp: .now.advanced(by: -400)),
                ChartEntry(value: 9, timestamp: .now.advanced(by: -300)),
                ChartEntry(value: 10, timestamp: .now.advanced(by: -200))
            ],
            aggregator: .sum,
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
            palette: .coralReef
        ),
        showTopic: {}
    )
    .padding()
}
