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

    @Test func toggleSign() {
        let sut = DecimalInputViewModel(submitValue: { _ in })

        sut.value = "0"
        sut.toggleSign()
        #expect(sut.value == "-0")

        sut.value = "-0"
        sut.toggleSign()
        #expect(sut.value == "0")

        sut.value = "1"
        sut.toggleSign()
        #expect(sut.value == "-1")

        sut.value = "-1"
        sut.toggleSign()
        #expect(sut.value == "1")

        sut.value = "10"
        sut.toggleSign()
        #expect(sut.value == "-10")

        sut.value = "-10"
        sut.toggleSign()
        #expect(sut.value == "10")

        sut.value = "0.01"
        sut.toggleSign()
        #expect(sut.value == "-0.01")

        sut.value = "-0.01"
        sut.toggleSign()
        #expect(sut.value == "0.01")

        sut.value = "0."
        sut.toggleSign()
        #expect(sut.value == "-0.")

        sut.value = "-0."
        sut.toggleSign()
        #expect(sut.value == "0.")

        sut.value = "10."
        sut.toggleSign()
        #expect(sut.value == "-10.")

        sut.value = "-10."
        sut.toggleSign()
        #expect(sut.value == "10.")

        sut.value = "1.00"
        sut.toggleSign()
        #expect(sut.value == "-1.00")

        sut.value = "-1.00"
        sut.toggleSign()
        #expect(sut.value == "1.00")
    }

    @Test func handleInput_backspace() {
        let sut = DecimalInputViewModel(submitValue: { _ in })
        let backspace = "⌫"

        sut.value = "0"
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "-0"
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "8"
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "-8"
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "0."
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "-0."
        sut.handleInput(backspace)
        #expect(sut.value == "-0")

        sut.value = "1."
        sut.handleInput(backspace)
        #expect(sut.value == "1")

        sut.value = "-1."
        sut.handleInput(backspace)
        #expect(sut.value == "-1")

        sut.value = "0.0"
        sut.handleInput(backspace)
        #expect(sut.value == "0.")

        sut.value = "-0.0"
        sut.handleInput(backspace)
        #expect(sut.value == "-0.")

        sut.value = "0.1"
        sut.handleInput(backspace)
        #expect(sut.value == "0.")

        sut.value = "-0.1"
        sut.handleInput(backspace)
        #expect(sut.value == "-0.")

        sut.value = "1.1"
        sut.handleInput(backspace)
        #expect(sut.value == "1.")

        sut.value = "-1.1"
        sut.handleInput(backspace)
        #expect(sut.value == "-1.")

        sut.value = "78"
        sut.handleInput(backspace)
        #expect(sut.value == "7")

        sut.value = "-78"
        sut.handleInput(backspace)
        #expect(sut.value == "-7")

        sut.value = ""
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = ""
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "-"
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "-."
        sut.handleInput(backspace)
        #expect(sut.value == "0")

        sut.value = "."
        sut.handleInput(backspace)
        #expect(sut.value == "0")
    }

    @Test func handleInput_decimalPoint() {
        let sut = DecimalInputViewModel(submitValue: { _ in })
        let decimalPoint = "."

        sut.value = "0"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "0.")

        sut.value = "-0"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-0.")

        sut.value = "12"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "12.")

        sut.value = "-12"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-12.")

        sut.value = "0."
        sut.handleInput(decimalPoint)
        #expect(sut.value == "0.")

        sut.value = "-0."
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-0.")

        sut.value = "12."
        sut.handleInput(decimalPoint)
        #expect(sut.value == "12.")

        sut.value = "-12."
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-12.")

        sut.value = "0.0"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "0.0")

        sut.value = "-0.0"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-0.0")

        sut.value = "12.0"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "12.0")

        sut.value = "-12.0"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-12.0")

        sut.value = "0.01"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "0.01")

        sut.value = "-0.01"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-0.01")

        sut.value = "12.11"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "12.11")

        sut.value = "-12.11"
        sut.handleInput(decimalPoint)
        #expect(sut.value == "-12.11")
    }
}
