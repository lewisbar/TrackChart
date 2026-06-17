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

    private static let gmt = TimeZone(secondsFromGMT: 0)! // fixture, guaranteed for test
    private static let berlin = TimeZone(identifier: "Europe/Berlin")!

    @Test func csvString_producesHeaderAndFormattedRows() {
        // Caller controls the timezone for wall time in the exported timestamps.
        // The format inside csvString is now fixed ("yyyy-MM-dd HH:mm:ss") using ISO8601FormatStyle
        // so it never inserts commas or locale date separators (e.g. "17.06.2026, 10:43:43").
        let e1 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 0), value: 42.5)
        let e2 = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 86400), value: -3)

        let csv = Export.csvString(from: [e1, e2], timeZone: Self.gmt)

        let expected = "\u{FEFF}timestamp,value\n2001-01-01 00:00:00,42.5\n2001-01-02 00:00:00,-3.0"
        #expect(csv == expected)
    }

    @Test func csvString_timestampFormatIsFixedNoCommasRegardlessOfLocale() {
        // Regression test: must never contain "," inside the timestamp field.
        // Old FormatStyle(.current) under German produced e.g. "17.06.2026, 10:43:43" -> 3 CSV columns.
        let entry = ExportEntry(timestamp: Date(timeIntervalSinceReferenceDate: 0), value: 7.0)
        let csv = Export.csvString(from: [entry], timeZone: Self.berlin)
        // Note: leading BOM is present; split on \n and take the data line.
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: false)
        let dataRow = lines[1]
        let fields = dataRow.split(separator: ",")
        #expect(fields.count == 2)
        #expect(fields[0] == "2001-01-01 01:00:00")
        #expect(fields[1] == "7.0")
    }

    @Test func csvString_emptyEntriesProducesOnlyHeaderWithBOM() {
        let csv = Export.csvString(from: [], timeZone: Self.gmt)
        #expect(csv == "\u{FEFF}timestamp,value")
    }

    @Test func suggestedFilename_sanitizesSpecialCharsAndUsesFixedDashDateAndHasCsvExtension() {
        // Must be locale-independent and produce safe filenames (no / from US numeric dates etc.)
        let fixedDate = Date(timeIntervalSinceReferenceDate: 0) // 2001-01-01 UTC
        let unsafeName = "My/Topic:With\\Slashes"
        let filename = Export.suggestedFilename(for: unsafeName, at: fixedDate)

        #expect(filename == "My-Topic-With-Slashes - 2001-01-01.csv")
        #expect(filename.hasSuffix(".csv"))
        #expect(!filename.contains("/"))
        #expect(!filename.contains(":"))
        #expect(!filename.contains("\\"))
    }

}
