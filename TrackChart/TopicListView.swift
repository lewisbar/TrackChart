//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

struct TopicListView: View {
    let topics: [TopicCellModel]

    init(topics: [TopicCellModel]) {
        self.topics = topics
    }

    var body: some View {
        List(topics) { topic in
            TopicCell(topic: topic)
        }
    }
}

#Preview {
    TopicListView(topics: [
        TopicCellModel(name: "Daily Pages Read", info: "15 entries"),
        TopicCellModel(name: "Pushups", info: "230 entries"),
        TopicCellModel(name: "Hours Studied", info: "32 entries")
    ])
}
