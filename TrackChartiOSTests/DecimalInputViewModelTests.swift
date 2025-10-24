//
//  DecimalInputViewModelTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 24.10.25.
//

import Testing
@testable import TrackChartiOS

struct DecimalInputViewModelTests {
    @Test func startsWithZero() {
        let sut = DecimalInputViewModel(submitValue: { _ in })
        #expect(sut.value == "0")
    }

    @Test func hasCorrectKeys() {
        let sut = DecimalInputViewModel(submitValue: { _ in })
        #expect(sut.keys == [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            [".", "0", "⌫"]
        ])
    }
}
