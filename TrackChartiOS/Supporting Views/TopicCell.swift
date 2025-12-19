//
//  TopicCell.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation

struct TopicCell: View {
    let topic: ViewTopic
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
            topic: topic,
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
        topic: ViewTopic(
            id: UUID(),
            name: "Topic 1",
            details: "Some details for topic 1",
            entries: [
                .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -800)),
                .init(id: UUID(), value: -3, timestamp: .now.advanced(by: -700)),
                .init(id: UUID(), value: -2, timestamp: .now.advanced(by: -600)),
                .init(id: UUID(), value: 1, timestamp: .now.advanced(by: -500)),
                .init(id: UUID(), value: 5, timestamp: .now.advanced(by: -400)),
                .init(id: UUID(), value: 9, timestamp: .now.advanced(by: -300)),
                .init(id: UUID(), value: 10, timestamp: .now.advanced(by: -200))
            ],
            aggregator: .sum,
            treatsMissingAsZero: true,
            palette: .sunset
        ),
        showTopic: {}
    )
    .padding()

    TopicCell(
        topic: ViewTopic(
            id: UUID(),
            name: "Topic 2",
            details: "Some details for topic 2",
            entries: [],
            aggregator: .sum,
            treatsMissingAsZero: false,
            palette: .coralReef
        ),
        showTopic: {}
    )
    .padding()
}
