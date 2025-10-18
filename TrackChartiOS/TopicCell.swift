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

//#Preview {
//    TopicCell(
//        topic: TopicCellModel(
//            id: UUID(),
//            name: "Daily Pages Read",
//            info: "7 entries",
//            entries: [1, 2, 4, 8, 16, -1, -2].map { TopicCellEntry(value: $0, timestamp: Date()) }
//        ),
//        showTopic: { _ in }
//    )
//    .padding()
//
//    TopicCell(
//        topic: TopicCellModel(
//            id: UUID(),
//            name: "Daily Pages Read",
//            info: "7 entries",
//            entries: [].map { TopicCellEntry(value: $0, timestamp: Date()) }
//        ),
//        showTopic: { _ in }
//    )
//    .padding()
//
//    TopicCell(
//        topic: TopicCellModel(
//            id: UUID(),
//            name: "Daily Pages Read",
//            info: "7 entries",
//            entries: [1].map { TopicCellEntry(value: $0, timestamp: Date()) }
//        ),
//        showTopic: { _ in }
//    )
//    .padding()
//}
