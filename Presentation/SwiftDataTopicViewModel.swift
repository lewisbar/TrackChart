//
//  SwiftDataTopicViewModel.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

import SwiftData
import Persistence
import DataProcessing

@MainActor
public enum SwiftDataTopicViewModel {
    public static func entries(for topic: TopicEntity) -> [ChartEntry] {
        topic.sortedEntries.map { ChartEntry(value: $0.value, timestamp: $0.timestamp)}
    }

    public static func submit(newValue: Double, timestamp: Date, to topic: TopicEntity) {
        let newEntry = EntryEntity(value: newValue, timestamp: timestamp)
        topic.entries?.append(newEntry)
    }
}
