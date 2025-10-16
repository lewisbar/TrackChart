//
//  TopicViewModel.swift
//  Presentation
//
//  Created by Lennart Wisbar on 14.10.25.
//

import Domain

@Observable
public class TopicViewModel {
    public let id: UUID

    public var name: String {
        didSet {
            guard oldValue != name else { return }
            updateTopic(currentTopic)
        }
    }

    public var entries: [ViewEntry] {
        didSet {
            guard oldValue != entries else { return }
            updateTopic(currentTopic)
        }
    }

    public var unsubmittedValue: Double {
        didSet {
            guard oldValue != unsubmittedValue else { return }
            updateTopic(currentTopic)
        }
    }

    private let updateTopic: (Topic) -> Void

    private var currentTopic: Topic {
        Topic(id: id, name: name, entries: entries.map(\.entry), unsubmittedValue: unsubmittedValue)
    }

    public init(topic: Topic, updateTopic: @escaping (Topic) -> Void) {
        self.id = topic.id
        self.name = topic.name
        self.entries = topic.entries.map(ViewEntry.init)
        self.unsubmittedValue = topic.unsubmittedValue
        self.updateTopic = updateTopic
    }
}

public struct ViewEntry: Equatable {
    public let value: Double
    public let timestamp: Date

    public init(value: Double, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }

    public init(from entry: Entry) {
        self.value = entry.value
        self.timestamp = entry.timestamp
    }

    public var entry: Entry {
        Entry(value: value, timestamp: timestamp)
    }
}
