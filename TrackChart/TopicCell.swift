//
//  TopicCell.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import SwiftUI

struct TopicCell: View {
    let topic: TopicVM

    var body: some View {
        HStack {
            Text(topic.name)
            Spacer()
            Text(topic.info)
        }
    }
}

#Preview {
    TopicCell(topic: TopicVM(name: "Daily Pages Read", info: "17 entries"))
}
