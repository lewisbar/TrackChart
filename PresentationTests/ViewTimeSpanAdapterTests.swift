//
//  ViewTimeSpanAdapterTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Testing
import Foundation
import Presentation

struct ViewTimeSpanAdapterTests {
    @Test func pagesForTopic() {
        let sut = ViewTimeSpan.week
        let oneDayInSeconds = 60 * 60 * 24.0
        let oneWeekInSeconds = oneDayInSeconds * 7.0
        let topic = ViewTopic(
            id: UUID(),
            name: "a name",
            details: "some details",
            entries: [
                ViewEntry(id: UUID(), value: 1, timestamp: Date(timeIntervalSinceReferenceDate: 0)),
                ViewEntry(id: UUID(), value: 2, timestamp: Date(timeIntervalSinceReferenceDate: 10)),
                ViewEntry(id: UUID(), value: 3, timestamp: Date(timeIntervalSinceReferenceDate: oneDayInSeconds)),
                ViewEntry(id: UUID(), value: 4, timestamp: Date(timeIntervalSinceReferenceDate: oneDayInSeconds + 10)),

                ViewEntry(id: UUID(), value: -5, timestamp: Date(timeIntervalSinceReferenceDate: oneWeekInSeconds)),
                ViewEntry(id: UUID(), value: -6, timestamp: Date(timeIntervalSinceReferenceDate: oneWeekInSeconds + 10)),
                ViewEntry(id: UUID(), value: -7, timestamp: Date(timeIntervalSinceReferenceDate: oneWeekInSeconds + oneDayInSeconds)),
                ViewEntry(id: UUID(), value: -8, timestamp: Date(timeIntervalSinceReferenceDate: oneWeekInSeconds + oneDayInSeconds + 10)),
                ViewEntry(id: UUID(), value: -9, timestamp: Date(timeIntervalSinceReferenceDate: oneWeekInSeconds + 2*oneDayInSeconds)),
                ViewEntry(id: UUID(), value: -10, timestamp: Date(timeIntervalSinceReferenceDate: oneWeekInSeconds + 2*oneDayInSeconds + 10)),

                ViewEntry(id: UUID(), value: -11, timestamp: Date(timeIntervalSinceReferenceDate: 2*oneWeekInSeconds)),
                ViewEntry(id: UUID(), value: -12, timestamp: Date(timeIntervalSinceReferenceDate: 2*oneWeekInSeconds + 10)),
                ViewEntry(id: UUID(), value: -13, timestamp: Date(timeIntervalSinceReferenceDate: 2*oneWeekInSeconds + 20)),
                ViewEntry(id: UUID(), value: -14, timestamp: Date(timeIntervalSinceReferenceDate: 2*oneWeekInSeconds + oneDayInSeconds)),
                ViewEntry(id: UUID(), value: -15, timestamp: Date(timeIntervalSinceReferenceDate: 2*oneWeekInSeconds + oneDayInSeconds + 10)),
            ],
            aggregator: .sum,
            treatsMissingAsZero: false,
            palette: .arcticIce
        )

        let pages = sut.pages(for: topic)

        #expect(pages.count == 3)
        #expect(pages[0].entries.count == 2)  // one per day
        #expect(pages[1].entries.count == 3)
        #expect(pages[2].entries.count == 2)

        #expect(pages.map(\.aggregator) == [.sum, .sum, .sum])

        #expect(pages[0].aggregate == 10)
        #expect(pages[1].aggregate == -45)
        #expect(pages[2].aggregate == -65)

        #expect(pages[0].entries.map(\.value) == [3, 7])
        #expect(pages[1].entries.map(\.value) == [-11, -15, -19])
        #expect(pages[2].entries.map(\.value) == [-36, -29])
    }

}
