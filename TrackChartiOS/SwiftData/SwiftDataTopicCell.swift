//
//  SwiftDataTopicCell.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 20.10.25.
//

import SwiftUI

/// Wrapper to decouple the actual View from SwiftData
struct SwiftDataTopicCell: View {
    let topic: Topic
    let showTopic: (Topic) -> Void

    var body: some View {
        TopicCell(
            name: topic.name,
            info: topic.info,
            entries: topic.entries?
                .sorted(by: { $0.sortIndex < $1.sortIndex })
                .map(\.value) ?? [],
            showTopic: { showTopic(topic)}
        )
    }
}
