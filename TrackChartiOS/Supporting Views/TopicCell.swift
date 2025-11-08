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
                .padding(.horizontal)

                ChartView(
                    rawEntries: topic.entries,
                    palette: topic.palette,
                    mode: .preview,
                    placeholder: { ChartPlaceholderView().font(.footnote).padding(.bottom, 20) }
                )
                .padding(.horizontal)
                .padding(.bottom)
            }
            Image(systemName: "chevron.right")
                .tint(.secondary)
        }
        .padding(.top)
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
        .card()
        .frame(height: 150)
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
            palette: .coralReef
        ),
        showTopic: {}
    )
    .padding()
}
