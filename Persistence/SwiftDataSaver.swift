//
//  SwiftDataSaver.swift
//  Persistence
//
//  Created by Lennart Wisbar on 21.10.25.
//

import SwiftData

@MainActor
public class SwiftDataSaver {
    private let modelContext: ModelContext
    private let sendError: (Error) -> Void
    private var saveTask: Task<Void, Never>?

    public init(modelContext: ModelContext, sendError: @escaping (Error) -> Void) {
        self.modelContext = modelContext
        self.sendError = sendError
    }

    public func save() {
        guard modelContext.hasChanges else { return }
        do { try modelContext.save() }
        catch { sendError(error) }
    }

    @discardableResult
    public func debounceSave(delayInSeconds: Double = 0.5) -> Task<Void, Never>? {
        guard modelContext.hasChanges else { return nil }
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            save()
        }
        return saveTask
    }
}
