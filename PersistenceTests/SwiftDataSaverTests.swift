//
//  SwiftDataSaverTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 22.10.25.
//

import Testing
import Persistence
import SwiftData

@MainActor
struct SwiftDataSaverTests {
    @Test func save_whenContextHasNoChanges_doesNotSave() {
        var saveCallCount = 0
        var capturedErrors = [Error]()
        let sut = SwiftDataSaver(
            contextHasChanges: { false },
            saveToContext: { saveCallCount += 1 },
            sendError: { capturedErrors.append($0) })

        sut.save()

        #expect(saveCallCount == 0)
        #expect(capturedErrors.isEmpty)
    }

    @Test func save_onError_sendsError() {
        var saveCallCount = 0
        var capturedErrors = [Error]()
        let error = anyNSError()
        let sut = SwiftDataSaver(
            contextHasChanges: { true },
            saveToContext: { saveCallCount += 1; throw error },
            sendError: { capturedErrors.append($0) }
        )

        sut.save()

        #expect(saveCallCount == 1)
        #expect(capturedErrors.map { $0 as NSError } == [error])
    }

    @Test func save_whenContextHasChanges_saves() {
        var saveCallCount = 0
        var capturedErrors = [Error]()
        let sut = SwiftDataSaver(
            contextHasChanges: { true },
            saveToContext: { saveCallCount += 1 },
            sendError: { capturedErrors.append($0) }
        )

        sut.save()

        #expect(saveCallCount == 1)
        #expect(capturedErrors.isEmpty)
    }

    @Test func debounceSave_whenContextHasNoChanges_doesNotSave() async {
        var saveCallCount = 0
        var capturedErrors = [Error]()
        let sut = SwiftDataSaver(
            contextHasChanges: { false },
            saveToContext: { saveCallCount += 1 },
            sendError: { capturedErrors.append($0) })

        let saveTask = sut.debounceSave(delayInSeconds: 0)
        await saveTask?.value

        #expect(saveTask == nil)
        #expect(saveCallCount == 0)
        #expect(capturedErrors.isEmpty)
    }

    @Test func debounceSave_onError_sendsError() async {
        var saveCallCount = 0
        var capturedErrors = [Error]()
        let error = anyNSError()
        let sut = SwiftDataSaver(
            contextHasChanges: { true },
            saveToContext: { saveCallCount += 1; throw error },
            sendError: { capturedErrors.append($0) }
        )

        await sut.debounceSave(delayInSeconds: 0)?.value

        #expect(saveCallCount == 1)
        #expect(capturedErrors.map { $0 as NSError } == [error])
    }

    @Test func debounceSave_whenContextHasChanges_saves() async {
        var saveCallCount = 0
        var capturedErrors = [Error]()
        let sut = SwiftDataSaver(
            contextHasChanges: { true },
            saveToContext: { saveCallCount += 1 },
            sendError: { capturedErrors.append($0) }
        )

        await sut.debounceSave(delayInSeconds: 0)?.value

        #expect(saveCallCount == 1)
        #expect(capturedErrors.isEmpty)
    }

    @Test func debounceSave_whenCancelled_doesNotSave() async {
        var saveCallCount = 0
        var capturedErrors = [Error]()
        let sut = SwiftDataSaver(
            contextHasChanges: { true },
            saveToContext: { saveCallCount += 1 },
            sendError: { capturedErrors.append($0) }
        )

        let saveTask = sut.debounceSave(delayInSeconds: 0)
        saveTask?.cancel()
        await saveTask?.value

        #expect(saveCallCount == 0)
        #expect(capturedErrors.isEmpty)
    }

    @Test func debounceSave_whenCalledTwice_cancelsFirst() async {
        var saveCallCount = 0
        var sleepCalls = [UInt64]()
        let sut = SwiftDataSaver(
            contextHasChanges: { true },
            saveToContext: { saveCallCount += 1 },
            sendError: { _ in },
            sleep: { nanoseconds in
                sleepCalls.append(nanoseconds)
                try Task.checkCancellation()
                await Task.yield()
            }
        )

        let saveTask1 = sut.debounceSave(delayInSeconds: 1)
        let saveTask2 = sut.debounceSave(delayInSeconds: 1)

        await saveTask1?.value
        #expect(saveCallCount == 0)

        await saveTask2?.value
        #expect(saveCallCount == 1)

        #expect(sleepCalls == [1_000_000_000, 1_000_000_000])
    }

    // MARK: - Helpers

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}
