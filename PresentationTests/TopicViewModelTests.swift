//
//  TopicViewModelTests.swift
//  PresentationTests
//
//  Created by Lennart Wisbar on 14.10.25.
//

import Testing
import Domain

class TopicViewModel {
    let id: UUID
    var name: String
    var entries: [Int]
    var unsubmittedValue: Int

    init(topic: Topic) {
        self.id = topic.id
        self.name = topic.name
        self.entries = topic.entries
        self.unsubmittedValue = topic.unsubmittedValue
    }
}

struct TopicViewModelTests {
    @Test func init_setsInitialValues() {
        let topic = Topic(id: UUID(), name: "a topic", entries: [-1, 2], unsubmittedValue: 4)

        let sut = TopicViewModel(topic: topic)

        #expect(sut.id == topic.id)
        #expect(sut.name == topic.name)
        #expect(sut.entries == topic.entries)
        #expect(sut.unsubmittedValue == topic.unsubmittedValue)
    }
}
