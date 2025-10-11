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
        Button(action: action, label: label).card()
    }

    private func action() {
        showTopic(topic.id)
    }

    private func label() -> some View {
        HStack {
            Text(topic.name)
                .tint(.primary)

            Spacer()

            Text(topic.info)
                .tint(.secondary)

            Image(systemName: "chevron.right")
                .tint(.secondary)
        }
    }
}

#Preview {
    TopicCell(topic: TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "17 entries"), showTopic: { _ in })
}
