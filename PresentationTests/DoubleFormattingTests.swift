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
        #expect(0.compactTwoDecimals(german) == "0")
        #expect(0.compactTwoDecimals(us) == "0")
    }

    @Test func positive() {
        #expect(1.compactTwoDecimals(german) == "1")
        #expect(1.compactTwoDecimals(us) == "1")
    }

    @Test func negative() {
        #expect((-1).compactTwoDecimals(german) == "-1")
        #expect((-1).compactTwoDecimals(us) == "-1")
    }

    @Test func decimals() {
        #expect(1.123.compactTwoDecimals(german) == "1,12")
        #expect(1.126.compactTwoDecimals(german) == "1,13")

        #expect(1.123.compactTwoDecimals(us) == "1.12")
        #expect(1.126.compactTwoDecimals(us) == "1.13")
    }

    @Test func thousands() {
        #expect(1100.compactTwoDecimals(german) == "1100")

        #expect(1100.compactTwoDecimals(us) == "1.1K")
        #expect(1120.compactTwoDecimals(us) == "1.12K")
        #expect(1123.compactTwoDecimals(us) == "1.12K")
        #expect(1126.compactTwoDecimals(us) == "1.13K")
    }

    @Test func negativeThousands() {
        #expect((-1100).compactTwoDecimals(german) == "-1100")

        #expect((-1100).compactTwoDecimals(us) == "-1.1K")
        #expect((-1120).compactTwoDecimals(us) == "-1.12K")
        #expect((-1123).compactTwoDecimals(us) == "-1.12K")
        #expect((-1126).compactTwoDecimals(us) == "-1.13K")
    }

    @Test func thousandsWithDecimals_shouldNotShowDecimals() {
        #expect(1100.12.compactTwoDecimals(german) == "1100")
        #expect(1100.51.compactTwoDecimals(german) == "1101")

        #expect(1100.12.compactTwoDecimals(us) == "1.1K")
        #expect(1120.12.compactTwoDecimals(us) == "1.12K")
        #expect(1123.12.compactTwoDecimals(us) == "1.12K")
        #expect(1126.12.compactTwoDecimals(us) == "1.13K")
    }

    @Test func negativeThousandsWithDecimals_shouldNotShowDecimals() {
        #expect((-1100.12).compactTwoDecimals(german) == "-1100")
        #expect((-1100.51).compactTwoDecimals(german) == "-1101")

        #expect((-1100.12).compactTwoDecimals(us) == "-1.1K")
        #expect((-1120.12).compactTwoDecimals(us) == "-1.12K")
        #expect((-1123.12).compactTwoDecimals(us) == "-1.12K")
        #expect((-1126.12).compactTwoDecimals(us) == "-1.13K")
    }

    @Test func millions() {
        #expect(1100123.compactTwoDecimals(german) == "1,1 Mio.")
        #expect(1120123.compactTwoDecimals(german) == "1,12 Mio.")
        #expect(1123123.compactTwoDecimals(german) == "1,12 Mio.")
        #expect(1125123.compactTwoDecimals(german) == "1,13 Mio.")

        #expect(1100123.compactTwoDecimals(us) == "1.1M")
        #expect(1120123.compactTwoDecimals(us) == "1.12M")
        #expect(1123123.compactTwoDecimals(us) == "1.12M")
        #expect(1125123.compactTwoDecimals(us) == "1.13M")
    }

    @Test func billions() {
        #expect(1100123456.compactTwoDecimals(german) == "1,1 Mrd.")
        #expect(1120123456.compactTwoDecimals(german) == "1,12 Mrd.")
        #expect(1123123456.compactTwoDecimals(german) == "1,12 Mrd.")
        #expect(1125123456.compactTwoDecimals(german) == "1,13 Mrd.")

        #expect(1100123456.compactTwoDecimals(us) == "1.1B")
        #expect(1120123456.compactTwoDecimals(us) == "1.12B")
        #expect(1123123456.compactTwoDecimals(us) == "1.12B")
        #expect(1125123456.compactTwoDecimals(us) == "1.13B")
    }

    @Test func trillions() {
        #expect(1100123456789.compactTwoDecimals(german) == "1,1 Bio.")
        #expect(1120123456789.compactTwoDecimals(german) == "1,12 Bio.")
        #expect(1123123456789.compactTwoDecimals(german) == "1,12 Bio.")
        #expect(1125123456789.compactTwoDecimals(german) == "1,13 Bio.")

        #expect(1100123456789.compactTwoDecimals(us) == "1.1T")
        #expect(1120123456789.compactTwoDecimals(us) == "1.12T")
        #expect(1123123456789.compactTwoDecimals(us) == "1.12T")
        #expect(1125123456789.compactTwoDecimals(us) == "1.13T")
    }

    // MARK: - Helpers

    private let german = Locale(identifier: "de_DE")
    private let us = Locale(identifier: "en_US")
}
