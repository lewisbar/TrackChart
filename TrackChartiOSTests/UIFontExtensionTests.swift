//
//  UIFontExtensionTests.swift
//  TrackChartTests
//
//  Created by LennartWisbar on 16.09.25.
//

import Testing
import SwiftUI
import TrackChartiOS

struct UIFontExtensionTests {
    @Test func widthOf_singleDigit_returnsCorrectNumber() {
        let downScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 8))
        #expect(downScaledFont.width(of: "0") == 6)
        #expect(downScaledFont.width(of: "1") == 6)
        #expect(downScaledFont.width(of: "8") == 6)

        let mediumFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 22))
        #expect(mediumFont.width(of: "0") == 14)
        #expect(mediumFont.width(of: "1") == 14)
        #expect(mediumFont.width(of: "8") == 14)

        let upScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 40))
        #expect(upScaledFont.width(of: "0") == 26)
        #expect(upScaledFont.width(of: "1") == 26)
        #expect(upScaledFont.width(of: "8") == 26)
    }

    @Test func widthOf_twoDigits_returnsCorrectNumber() {
        let downScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 8))
        #expect(downScaledFont.width(of: "10") == 12)
        #expect(downScaledFont.width(of: "11") == 12)
        #expect(downScaledFont.width(of: "88") == 12)

        let mediumFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 22))
        #expect(mediumFont.width(of: "10") == 28)
        #expect(mediumFont.width(of: "11") == 28)
        #expect(mediumFont.width(of: "88") == 28)

        let upScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 40))
        #expect(upScaledFont.width(of: "10") == 52)
        #expect(upScaledFont.width(of: "11") == 52)
        #expect(upScaledFont.width(of: "88") == 52)
    }

    @Test func widthOf_threeDigits_returnsCorrectNumber() {
        let downScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 8))
        #expect(downScaledFont.width(of: "100") == 18)
        #expect(downScaledFont.width(of: "111") == 18)
        #expect(downScaledFont.width(of: "888") == 18)

        let mediumFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 22))
        #expect(mediumFont.width(of: "100") == 42)
        #expect(mediumFont.width(of: "111") == 42)
        #expect(mediumFont.width(of: "888") == 42)

        let upScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 40))
        #expect(upScaledFont.width(of: "100") == 78)
        #expect(upScaledFont.width(of: "111") == 78)
        #expect(upScaledFont.width(of: "888") == 78)
    }

    @Test func widthOf_fourDigits_returnsCorrectNumber() {
        let downScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 8))
        #expect(downScaledFont.width(of: "1000") == 24)
        #expect(downScaledFont.width(of: "1111") == 24)
        #expect(downScaledFont.width(of: "8888") == 24)

        let mediumFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 22))
        #expect(mediumFont.width(of: "1000") == 56)
        #expect(mediumFont.width(of: "1111") == 56)
        #expect(mediumFont.width(of: "8888") == 56)

        let upScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 40))
        #expect(upScaledFont.width(of: "1000") == 104)
        #expect(upScaledFont.width(of: "1111") == 104)
        #expect(upScaledFont.width(of: "8888") == 104)
    }

    @Test func widthOf_negativeNumber_returnsCorrectNumber() {
        let downScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 8))
        #expect(downScaledFont.width(of: "-1") == 12)
        #expect(downScaledFont.width(of: "-1111") == 30)
        #expect(downScaledFont.width(of: "-8888") == 30)

        let mediumFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 22))
        #expect(mediumFont.width(of: "-1") == 28)
        #expect(mediumFont.width(of: "-1111") == 70)
        #expect(mediumFont.width(of: "-8888") == 70)

        let upScaledFont = UIFontMetrics(forTextStyle: .title2).scaledFont(for: UIFont.systemFont(ofSize: 40))
        #expect(upScaledFont.width(of: "-1") == 52)
        #expect(upScaledFont.width(of: "-1111") == 130)
        #expect(upScaledFont.width(of: "-8888") == 130)
    }
}
