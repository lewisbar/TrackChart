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
    let showTopic: (UUID) -> Void

    var body: some View {
        Button(action: action, label: label)
    }

    private func action() {
        showTopic(topic.id)
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
                    values: topic.entries,
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
    TopicCell(topic: TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "7 entries", entries: [1, 2, 4, 8, 16, -1, -2]), showTopic: { _ in })
        .padding()

    TopicCell(topic: TopicCellModel(id: UUID(), name: "Pushups", info: "10 entries", entries: [1, 2, 4, 8, -16, -1, -2, 6, 7, 8]), showTopic: { _ in })
        .padding()

    TopicCell(topic: TopicCellModel(id: UUID(), name: "Hours Studied", info: "0 entries", entries: []), showTopic: { _ in })
        .padding()

    TopicCell(topic: TopicCellModel(id: UUID(), name: "Some Other Topic", info: "1 entry", entries: [1]), showTopic: { _ in })
        .padding()
}
