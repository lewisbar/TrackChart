//
//  TopicStoreTests.swift
//  PersistenceTests
//
//  Created by Lennart Wisbar on 18.09.25.
//

import Testing

struct Topic: Equatable {
    let name: String
    let entries: [Int]
}

class TopicStore {
    var topics: [Topic] = []
}

struct TopicStoreTests {
    @Test func startsEmpty() {
        let sut = TopicStore()
        #expect(sut.topics == [])
    }

}
