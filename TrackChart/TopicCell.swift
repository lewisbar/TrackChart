//
//  TopicCell.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

struct TopicCell: View {
    let topic: TopicCellModel

    var body: some View {
        NavigationLink(value: topic, label: label)
    }

    private func label() -> some View {
        HStack {
            Text(topic.name)
            Spacer()
            Text(topic.info)
        }
    }
}

#Preview {
    TopicCell(topic: TopicCellModel(name: "Daily Pages Read", info: "17 entries"))
}
