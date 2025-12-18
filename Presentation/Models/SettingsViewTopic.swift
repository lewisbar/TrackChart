//
//  SettingsViewTopic.swift
//  Presentation
//
//  Created by Lennart Wisbar on 01.12.25.
//

public struct SettingsTopic {
    public var name: String
    public var details: String
    public var palette: Palette
    public var aggregator: ViewAggregator
    public var treatsMissingAsZero: Bool

    public init(name: String, details: String, palette: Palette, aggregator: ViewAggregator, treatsMissingAsZero: Bool) {
        self.name = name
        self.details = details
        self.palette = palette
        self.aggregator = aggregator
        self.treatsMissingAsZero = treatsMissingAsZero
    }
}
