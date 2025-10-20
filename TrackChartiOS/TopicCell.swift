//
//  TopicCell.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation

struct TopicCell: View {
    let topic: TopicCellModel
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
                    values: topic.entries.map(\.value),
                    showPointMarks: false,
                    annotateExtrema: false,
                    showAxisLabels: false,
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
        topic: TopicCellModel(
            id: UUID(),
            name: "Topic 1",
            info: "5 entries",
            entries: [
                TopicCellEntry(value: 0, timestamp: .now),
                TopicCellEntry(value: -3, timestamp: .now),
                TopicCellEntry(value: -2, timestamp: .now),
                TopicCellEntry(value: 1, timestamp: .now),
                TopicCellEntry(value: 5, timestamp: .now),
                TopicCellEntry(value: 9, timestamp: .now),
                TopicCellEntry(value: 10, timestamp: .now)
            ]
        ),
        showTopic: {
        })
        .padding()
}
