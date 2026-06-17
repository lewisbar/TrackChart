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
        // Caller controls the timezone for wall time in the exported timestamps.
        // The format inside csvString is now fixed ("yyyy-MM-dd HH:mm:ss") using ISO8601FormatStyle
        // so it never inserts commas or locale date separators (e.g. "17.06.2026, 10:43:43").
        let tz = TimeZone(secondsFromGMT: 0)!

        let e1 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 0), value: 42.5)
        let e2 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 86400), value: -3)

        let csv = Export.csvString(from: [e1, e2], timeZone: tz)

        let expected = """
        timestamp,value
        2001-01-01 00:00:00,42.5
        2001-01-02 00:00:00,-3.0
        """
        #expect(csv == expected)
    }

    @Test func csvString_timestampFormatIsFixedNoCommasRegardlessOfLocale() {
        // Regression test: must never contain "," inside the timestamp field.
        // Old FormatStyle(.current) under German produced e.g. "17.06.2026, 10:43:43" -> 3 CSV columns.
        let tz = TimeZone(identifier: "Europe/Berlin")!
        let entry = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 0), value: 7.0)
        let csv = Export.csvString(from: [entry], timeZone: tz)
        let dataRow = csv.split(separator: "\n")[1]
        let fields = dataRow.split(separator: ",")
        #expect(fields.count == 2)
        #expect(fields[0] == "2001-01-01 01:00:00")
        #expect(fields[1] == "7.0")
    }

}
