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
            Text(topic.name)
            Spacer()
            Text(topic.info)
            Image(systemName: "chevron.right")
        }
    }
}

#Preview {
    TopicCell(topic: TopicCellModel(id: UUID(), name: "Daily Pages Read", info: "17 entries"), showTopic: { _ in })
}
