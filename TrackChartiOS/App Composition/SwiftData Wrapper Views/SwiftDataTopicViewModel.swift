//
//  SwiftDataTopicViewModel.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

import SwiftData
import Persistence

@MainActor
public class SwiftDataTopicViewModel {
    public func entries(for topic: TopicEntity) -> [ChartEntry] {
        topic.sortedEntries.map { ChartEntry(value: $0.value, timestamp: $0.timestamp)}
    }

    public func submit(newValue: Double, timestamp: Date, to topic: TopicEntity) {
        let newEntry = EntryEntity(value: newValue, timestamp: timestamp)
        topic.entries?.append(newEntry)
    }

    public func deleteLastValue(from topic: TopicEntity) {
        if !(topic.entries?.isEmpty ?? false) {
            topic.entries = topic.sortedEntries.dropLast()
        }
    }

    public func changePalette(to palette: Palette, for topic: TopicEntity) {
        topic.palette = palette.name
    }
}
