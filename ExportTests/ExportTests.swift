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
        // Fixed formatter injected by caller (Composition Root controls timezone/locale)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(secondsFromGMT: 0)!

        let e1 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 0), value: 42.5)
        let e2 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 86400), value: -3)

        let csv = Export.csvString(from: [e1, e2], dateFormatter: df)

        let expected = """
        timestamp,value
        2001-01-01 00:00:00,42.5
        2001-01-02 00:00:00,-3.0
        """
        #expect(csv == expected)
    }

}
