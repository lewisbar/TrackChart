//
//  TimeSpanTitleTests.swift
//  TrackChartiOSTests
//
//  Created by LennartWisbar on 23.11.25.
//

import Testing
@testable import TrackChartiOS
import DataProcessing

struct TimeSpanTitleTests {
    @Test func title() {
        #expect(TimeSpan.week.title == String(localized: .week))
        #expect(TimeSpan.month.title == String(localized: .month))
        #expect(TimeSpan.oneYear.title == String(localized: .year))
    }
}
