//
//  SwiftDataSaver.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

import SwiftData

@MainActor
public final class SwiftDataSaver {
    private let contextHasChanges: () -> Bool
    private let saveToContext: () throws -> Void
    private let sendError: (Error) -> Void

    private var saveTask: Task<Void, Never>?

    public init(
        contextHasChanges: @escaping () -> Bool,
        saveToContext: @escaping () throws -> Void,
        sendError: @escaping (Error) -> Void
    ) {
        self.contextHasChanges = contextHasChanges
        self.saveToContext = saveToContext
        self.sendError = sendError
    }

    public func save() {
        guard contextHasChanges() else { return }
        do { try saveToContext() }
        catch { sendError(error) }
    }

    @discardableResult
    public func debounceSave(delayInSeconds: Double = 0.5) -> Task<Void, Never>? {
        guard contextHasChanges() else { return nil }
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            save()
        }
        return saveTask
    }
}
