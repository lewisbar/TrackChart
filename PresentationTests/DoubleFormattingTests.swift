//
//  DoubleFormattingTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 29.01.26.
//

import Testing
import Foundation
import Presentation

struct DoubleFormattingTests {
    @Test func zero() {
        #expect(0.compact(german) == "0")
        #expect(0.compact(us) == "0")
    }

    @Test func positive() {
        #expect(1.compact(german) == "1")
        #expect(1.compact(us) == "1")
    }

    @Test func negative() {
        #expect((-1).compact(german) == "-1")
        #expect((-1).compact(us) == "-1")
    }

    @Test func decimals() {
        #expect(1.123.compact(german) == "1,1")
        #expect(1.126.compact(german) == "1,1")

        #expect(1.123.compact(us) == "1.1")
        #expect(1.126.compact(us) == "1.1")
    }

    @Test func small() {
        #expect(0.001.compact(german) == "0,001")
        #expect(0.001.compact(us) == "0.001")
    }

    @Test func smallDecimal() {
        #expect(1.001.compact(german) == "1")
        #expect(1.001.compact(us) == "1")
    }

    @Test func thousands() {
        #expect(1100.compact(german) == "1100")

        #expect(1100.compact(us) == "1.1K")
        #expect(1120.compact(us) == "1.1K")
        #expect(1123.compact(us) == "1.1K")
        #expect(1156.compact(us) == "1.2K")
    }

    @Test func negativeThousands() {
        #expect((-1100).compact(german) == "-1100")

        #expect((-1100).compact(us) == "-1.1K")
        #expect((-1120).compact(us) == "-1.1K")
        #expect((-1123).compact(us) == "-1.1K")
        #expect((-1156).compact(us) == "-1.2K")
    }

    @Test func thousandsWithDecimals_shouldNotShowDecimals() {
        #expect(1100.12.compact(german) == "1100")
        #expect(1100.51.compact(german) == "1101")

        #expect(1100.12.compact(us) == "1.1K")
        #expect(1120.12.compact(us) == "1.1K")
        #expect(1123.12.compact(us) == "1.1K")
        #expect(1156.12.compact(us) == "1.2K")
    }

    @Test func negativeThousandsWithDecimals_shouldNotShowDecimals() {
        #expect((-1100.12).compact(german) == "-1100")
        #expect((-1100.51).compact(german) == "-1101")

        #expect((-1100.12).compact(us) == "-1.1K")
        #expect((-1120.12).compact(us) == "-1.1K")
        #expect((-1123.12).compact(us) == "-1.1K")
        #expect((-1156.12).compact(us) == "-1.2K")
    }

    @Test func millions() {
        #expect(1100123.compact(german) == "1,1 Mio.")
        #expect(1120123.compact(german) == "1,1 Mio.")
        #expect(1123123.compact(german) == "1,1 Mio.")
        #expect(1155123.compact(german) == "1,2 Mio.")

        #expect(1100123.compact(us) == "1.1M")
        #expect(1120123.compact(us) == "1.1M")
        #expect(1123123.compact(us) == "1.1M")
        #expect(1155123.compact(us) == "1.2M")
    }

    @Test func billions() {
        #expect(1100123456.compact(german) == "1,1 Mrd.")
        #expect(1120123456.compact(german) == "1,1 Mrd.")
        #expect(1123123456.compact(german) == "1,1 Mrd.")
        #expect(1155123456.compact(german) == "1,2 Mrd.")

        #expect(1100123456.compact(us) == "1.1B")
        #expect(1120123456.compact(us) == "1.1B")
        #expect(1123123456.compact(us) == "1.1B")
        #expect(1155123456.compact(us) == "1.2B")
    }

    @Test func trillions() {
        #expect(1100123456789.compact(german) == "1,1 Bio.")
        #expect(1120123456789.compact(german) == "1,1 Bio.")
        #expect(1123123456789.compact(german) == "1,1 Bio.")
        #expect(1155123456789.compact(german) == "1,2 Bio.")

        #expect(1100123456789.compact(us) == "1.1T")
        #expect(1120123456789.compact(us) == "1.1T")
        #expect(1123123456789.compact(us) == "1.1T")
        #expect(1155123456789.compact(us) == "1.2T")
    }

    // MARK: - Helpers

    private let german = Locale(identifier: "de_DE")
    private let us = Locale(identifier: "en_US")
}
