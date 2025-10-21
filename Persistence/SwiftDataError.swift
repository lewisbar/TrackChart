//
//  SwiftDataError.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

enum SwiftDataError: LocalizedError {
    case saveFailed(String)
    case fetchFailed(String)
    case iCloudSyncFailed(String)
    case validationFailed(String)

    var errorDescription: String? {
        switch self {
        case let .saveFailed(reason): "Failed to save data: \(reason)"
        case let .fetchFailed(reason): "Failed to load data: \(reason)"
        case let .iCloudSyncFailed(reason): "iCloud sync failed: \(reason)"
        case let .validationFailed(reason): "Invalid data: \(reason)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .fetchFailed: "Please try again or check your storage settings."
        case .iCloudSyncFailed: "Check your internet connection or iCloud settings and try again."
        case .validationFailed: "Ensure all required fields are filled correctly."
        }
    }
}
