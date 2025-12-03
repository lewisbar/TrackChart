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
            entries: viewEntries,
            aggregator: viewAggregator,
            treatsMissingAsZero: treatsMissingAsZero,
            palette: viewPalette
        )
    }

    var settingsViewTopic: SettingsTopic {
        SettingsTopic(name: name, palette: viewPalette, aggregator: viewAggregator, treatsMissingAsZero: treatsMissingAsZero)
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
}

public extension EntryEntity {
    var viewEntry: ViewEntry {
        ViewEntry(id: id, value: value, timestamp: timestamp)
    }
}
