//
//  ChartViewPageTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 02.12.25.
//

import Testing
import Foundation
import Presentation

struct ChartViewPageTests {
    @Test func extrema() {
        let entry1 = ViewEntry(id: UUID(), value: 1.1, timestamp: .now.advanced(by: -400))
        let entry2 = ViewEntry(id: UUID(), value: 1.2, timestamp: .now.advanced(by: -300))
        let entry3 = ViewEntry(id: UUID(), value: 1.3, timestamp: .now.advanced(by: -200))
        let entry4 = ViewEntry(id: UUID(), value: -1.3, timestamp: .now.advanced(by: -100))
        let entry5 = ViewEntry(id: UUID(), value: -1.2, timestamp: .now.advanced(by: -50))
        let entry6 = ViewEntry(id: UUID(), value: -1.3, timestamp: .now.advanced(by: -10))

        let sut = ChartViewPage(
            id: "an ID",
            entries: [entry1, entry2, entry3, entry4, entry5],
            title: "a title",
            dateRange: Date().advanced(by: -500)...Date(),
            aggregator: .sum,
            aggregate: -0.2,
            maxEntries: [entry3.id],
            minEntries: [entry4.id, entry6.id]
        )

        #expect(sut.isMaxEntry(entry1) == false)
        #expect(sut.isMaxEntry(entry2) == false)
        #expect(sut.isMaxEntry(entry3) == true)
        #expect(sut.isMaxEntry(entry4) == false)
        #expect(sut.isMaxEntry(entry5) == false)
        #expect(sut.isMaxEntry(entry6) == false)

        #expect(sut.isMinEntry(entry1) == false)
        #expect(sut.isMinEntry(entry2) == false)
        #expect(sut.isMinEntry(entry3) == false)
        #expect(sut.isMinEntry(entry4) == true)
        #expect(sut.isMinEntry(entry5) == false)
        #expect(sut.isMinEntry(entry6) == true)

        #expect(sut.isExtremum(entry1) == false)
        #expect(sut.isExtremum(entry2) == false)
        #expect(sut.isExtremum(entry3) == true)
        #expect(sut.isExtremum(entry4) == true)
        #expect(sut.isExtremum(entry5) == false)
        #expect(sut.isExtremum(entry6) == true)
    }
}
