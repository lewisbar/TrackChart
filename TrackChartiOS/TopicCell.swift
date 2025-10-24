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
                HStack(alignment: .center) {
                    Text(topic.name)
                        .tint(.primary)
                        .font(.title3)
                        .minimumScaleFactor(0.5)

                    Spacer()

                    Text(topic.info)
                        .tint(.secondary)
                        .font(.caption)
                }
                .padding([.horizontal, .bottom])

                ChartView(
                    entries: topic.entries,
                    highlightsExtrema: false,
                    showsAxisLabels: false,
                    placeholder: { ChartPlaceholderView().font(.footnote).padding(.bottom, 30) }
                )
                .padding(.horizontal)
            }
            Image(systemName: "chevron.right")
                .tint(.secondary)
        }
        .card()
        .frame(height: 150)
    }
}

#Preview {
    TopicCell(
        topic: CellTopic(
            id: UUID(),
            name: "Topic 1",
            info: "5 entries",
            entries: [
                ChartEntry(value: 0, timestamp: .now),
                ChartEntry(value: -3, timestamp: .now),
                ChartEntry(value: -2, timestamp: .now),
                ChartEntry(value: 1, timestamp: .now),
                ChartEntry(value: 5, timestamp: .now),
                ChartEntry(value: 9, timestamp: .now),
                ChartEntry(value: 10, timestamp: .now)
            ]
        ),
        showTopic: {}
    )
    .padding()
}
