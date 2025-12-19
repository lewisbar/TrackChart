//
//  SettingsTopicTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 19.12.25.
//

import Testing
import Presentation

struct SettingsTopicTests {
    @Test func new() {
        let sut = SettingsTopic.new
        #expect(sut.name == "")
        #expect(sut.details == "")
        #expect(sut.aggregator == .sum)
        #expect(sut.treatsMissingAsZero == false)
    }
}
