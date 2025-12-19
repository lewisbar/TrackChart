//
//  TopicEntityMapping.swift
//  Presentation
//
//  Created by Lennart Wisbar on 01.12.25.
//

import Persistence
import DataProcessing

public extension TopicEntity {
    var viewTopic: ViewTopic {
        ViewTopic(
            id: id,
            name: name,
            details: details,
            entries: viewEntries,
            aggregator: viewAggregator,
            treatsMissingAsZero: treatsMissingAsZero,
            palette: viewPalette
        )
    }

    var settingsTopic: SettingsTopic {
        SettingsTopic(name: name, details: details ?? "", palette: viewPalette, aggregator: viewAggregator, treatsMissingAsZero: treatsMissingAsZero)
    }

    var viewEntries: [ViewEntry] {
        sortedEntries.map(\.viewEntry)
    }

    var viewAggregator: ViewAggregator {
        Aggregator.aggregator(named: aggregator).viewAggregator
    }

    var viewPalette: Palette {
        .palette(named: palette)
    }

    func apply(_ settingsTopic: SettingsTopic) {
        name = settingsTopic.name
        details = settingsTopic.details.isEmpty ? nil : settingsTopic.details
        palette = settingsTopic.palette.name
        aggregator = settingsTopic.aggregator.name
        treatsMissingAsZero = settingsTopic.treatsMissingAsZero
    }

    convenience init(from settingsTopic: SettingsTopic, at sortIndex: Int) {
        self.init(
            name: settingsTopic.name,
            details: settingsTopic.details.isEmpty ? nil : settingsTopic.details,
            palette: settingsTopic.palette.name,
            aggregator: settingsTopic.aggregator.name,
            treatsMissingAsZero: settingsTopic.treatsMissingAsZero,
            sortIndex: sortIndex
        )
    }
}

public extension EntryEntity {
    var viewEntry: ViewEntry {
        ViewEntry(id: id, value: value, timestamp: timestamp)
    }
}
