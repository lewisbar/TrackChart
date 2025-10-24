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

}
