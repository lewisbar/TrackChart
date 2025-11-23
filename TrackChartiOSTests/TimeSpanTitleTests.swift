//
//  TimeSpanTitleTests.swift
//  TrackChartiOSTests
//
//  Created by LennartWisbar on 23.11.25.
//

import Testing
import TrackChartiOS
import DataProcessing

struct TimeSpanTitleTests {
    @Test func title() {
        #expect(TimeSpan.week.title == String(localized: "Week"))
        #expect(TimeSpan.month.title == String(localized: "Month"))
        #expect(TimeSpan.oneYear.title == String(localized: "Year"))
    }
}
