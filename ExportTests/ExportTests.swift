//
//  ExportTests.swift
//  ExportTests
//
//  Created by Lennart Wisbar on 16.06.26.
//

import Testing
import Foundation
@testable import Export

struct ExportTests {

    @Test func csvString_producesHeaderAndFormattedRows() {
        // Fixed style injected by caller (Composition Root controls timezone).
        // NOTE: Using Date.FormatStyle(timeZone:) + components (current approach) is locale-sensitive
        // and produces separators like "," or "/" (e.g. under de_DE: "01.01.2001, 00:00:00").
        // This test currently demonstrates the bug (will fail until csvString uses fixed format).
        let style = Date.FormatStyle(timeZone: TimeZone(secondsFromGMT: 0)!)
            .year(.defaultDigits)
            .month(.twoDigits)
            .day(.twoDigits)
            .hour(.twoDigits(amPM: .omitted))
            .minute(.twoDigits)
            .second(.twoDigits)

        let e1 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 0), value: 42.5)
        let e2 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 86400), value: -3)

        let csv = Export.csvString(from: [e1, e2], dateStyle: style)

        let expected = """
        timestamp,value
        2001-01-01 00:00:00,42.5
        2001-01-02 00:00:00,-3.0
        """
        #expect(csv == expected)
    }

}
