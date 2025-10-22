//
//  SwiftDataError.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

public enum SwiftDataSaverError: LocalizedError {
    case saveFailed(Error)

    public var errorDescription: String? {
        switch self {
        case let .saveFailed(error): "Failed to save data: \(error.localizedDescription)"
        }
    }
}
