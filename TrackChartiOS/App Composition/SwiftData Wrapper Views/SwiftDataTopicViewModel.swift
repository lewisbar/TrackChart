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
public class SwiftDataTopicViewModel {
    public func entries(for topic: TopicEntity) -> [ChartEntry] {
        topic.sortedEntries.map { ChartEntry(value: $0.value, timestamp: $0.timestamp)}
    }

    public func submit(newValue: Double, timestamp: Date, to topic: TopicEntity) {
        let newEntry = EntryEntity(value: newValue, timestamp: timestamp)
        topic.entries?.append(newEntry)
    }

    public func changePalette(to palette: Palette, for topic: TopicEntity) {
        topic.palette = palette.name
    }

    public func changeAggregator(to aggregator: Aggregator, for topic: TopicEntity) {
        topic.aggregator = aggregator.name
    }
}
