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
    public var name: String { didSet { updateTopic(currentTopic) } }
    public var entries: [Int] { didSet { updateTopic(currentTopic) } }
    public var unsubmittedValue: Int { didSet { updateTopic(currentTopic) } }
    public let updateTopic: (Topic) -> Void

    private var currentTopic: Topic {
        Topic(id: id, name: name, entries: entries, unsubmittedValue: unsubmittedValue)
    }

    public init(topic: Topic, updateTopic: @escaping (Topic) -> Void) {
        self.id = topic.id
        self.name = topic.name
        self.entries = topic.entries
        self.unsubmittedValue = topic.unsubmittedValue
        self.updateTopic = updateTopic
    }
}
