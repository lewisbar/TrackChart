//
//  TopicListView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

struct TopicListView: View {
    let topics: [TopicVM]

    init(topics: [TopicVM]) {
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
        TopicVM(name: "Daily Pages Read", info: "15 entries"),
        TopicVM(name: "Pushups", info: "230 entries"),
        TopicVM(name: "Hours Studied", info: "32 entries")
    ])
}
