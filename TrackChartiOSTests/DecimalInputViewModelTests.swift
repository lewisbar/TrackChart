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

    @Test func submitNumber() {
        var submittedValues = [Double]()
        let sut = DecimalInputViewModel(submitValue: { submittedValues.append($0) })
        sut.value = "-32.6"

        sut.submitNumber()

        #expect(submittedValues == [-32.6])
        #expect(sut.value == "0")
    }

    @Test func submitNumber_withInvalidValue_resetsValueToZeroAndDoesNotSubmit() {
        var submittedValues = [Double]()
        let sut = DecimalInputViewModel(submitValue: { submittedValues.append($0) })
        sut.value = "not a number"

        sut.submitNumber()

        #expect(submittedValues.isEmpty)
        #expect(sut.value == "0")
    }

    @Test func toggleSign_withInvalidValue_resetsValueToZero() {
        let sut = DecimalInputViewModel(submitValue: { _ in })
        sut.value = "not a number"

        sut.toggleSign()

        #expect(sut.value == "0")
    }
}
