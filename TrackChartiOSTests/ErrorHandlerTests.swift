//
//  ErrorHandlerTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 22.10.25.
//

import Testing
import Foundation
import TrackChartiOS
import Persistence

struct ErrorHandlerTests {
    @Test func init_setsCorrectValues() {
        let sut = ErrorHandler()

        #expect(sut.alertTitle.isEmpty)
        #expect(sut.alertMessage.isEmpty)
        #expect(!sut.showAlert)
    }

    @Test func handleRandomError_setsCorrectValues() {
        let sut = ErrorHandler()
        let error = NSError(domain: "any error", code: 0)

        sut.handleError(error)

        #expect(sut.alertTitle == "Something went wrong")
        #expect(sut.alertMessage == "An error occurred.")
        #expect(sut.showAlert)
    }

    @Test func handleSaverError_setsCorrectValues() {
        let sut = ErrorHandler()
        let underlyingError = NSError(domain: "any error", code: 0)
        let error = SwiftDataSaverError.saveFailed(underlyingError)

        sut.handleError(error)

        #expect(sut.alertTitle == "Something went wrong")
        #expect(sut.alertMessage == "Failed to save data.")
        #expect(sut.showAlert)
    }

    @Test func reset_setsCorrectValues() {
        let sut = ErrorHandler()

        sut.reset()

        #expect(sut.alertTitle.isEmpty)
        #expect(sut.alertMessage.isEmpty)
        #expect(!sut.showAlert)
    }
}
