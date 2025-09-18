//
//  TopicVM.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Foundation

struct TopicVM: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let info: String
}
