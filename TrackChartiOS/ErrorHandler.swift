//
//  ErrorHandler.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 22.10.25.
//

import Foundation
import Persistence

import SwiftData

@Observable
public final class ErrorHandler {
    public var alertTitle = ""
    public var alertMessage = ""
    public var showAlert = false

    public init() {}

    public func handleError(_ error: Error) {
        alertTitle = "Something went wrong"

        if let error = error as? SwiftDataSaverError, case .saveFailed = error {
            alertMessage = "Failed to save data."
        } else {
            alertMessage = "An error occurred."
        }

        showAlert = true

        // TODO: Log error using String(describing: error) to include enum case names
        print(error)
    }

    public func reset() {
        showAlert = false
        alertTitle = ""
        alertMessage = ""
    }
}
