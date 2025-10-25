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
                    rawEntries: topic.entries,
                    dataProvider: dataProvider(),
                    palette: topic.palette,
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

    // TODO: Move logic elsewhere?
    private func dataProvider() -> ChartDataProvider {
        let timestamps = topic.entries.map(\.timestamp)
        guard let earliest = timestamps.min(), let latest = timestamps.max() else { return .raw }
        let numberOfDays = latest.timeIntervalSince(earliest) / 86_400

        switch numberOfDays {
        case 0...2: return .raw
        case 3...100: return .dailySum
        case 101...365: return .weeklySum
        default: return .monthlySum
        }
    }
}

#Preview {
    TopicCell(
        topic: CellTopic(
            id: UUID(),
            name: "Topic 1",
            entries: [
                ChartEntry(value: 0, timestamp: .now),
                ChartEntry(value: -3, timestamp: .now),
                ChartEntry(value: -2, timestamp: .now),
                ChartEntry(value: 1, timestamp: .now),
                ChartEntry(value: 5, timestamp: .now),
                ChartEntry(value: 9, timestamp: .now),
                ChartEntry(value: 10, timestamp: .now)
            ],
            palette: .sunset
        ),
        showTopic: {}
    )
    .padding()
}
