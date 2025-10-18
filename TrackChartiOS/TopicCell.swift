//
//  TopicCell.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI
import Presentation

struct TopicCell: View {
    let topic: Topic
    let showTopic: (Topic) -> Void

    var body: some View {
        Button(action: action, label: label)
    }

    private func action() {
        showTopic(topic)
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
                    values: topic.entries?.sorted(by: { $0.sortIndex < $1.sortIndex }).map(\.value).map(Int.init) ?? [],
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
    let topic = Topic(name: "Topic 1", entries: [
        Entry(value: 4, timestamp: .now, sortIndex: 0),
        Entry(value: -5, timestamp: .now, sortIndex: 1),
        Entry(value: 0, timestamp: .now, sortIndex: 2),
        Entry(value: 4, timestamp: .now, sortIndex: 3),
        Entry(value: 14, timestamp: .now, sortIndex: 4),
    ], unsubmittedValue: 0, sortIndex: 0)

    TopicCell(topic: topic, showTopic: { _ in })
        .padding()
}
