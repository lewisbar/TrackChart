//
//  TopicListViewModelTests.swift
//  PresentationTests
//
//  Created by LennartWisbar on 14.10.25.
//

import Testing
import Presentation
import Domain

class TopicListViewModel {
    var topics: [TopicCellModel]

    init(topics: [Topic]) {
        self.topics = topics.map(TopicCellModel.init)
    }
}

struct TopicListViewModelTests {
    @Test func init_setsCellModels() {
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [5, 6], unsubmittedValue: 4)
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-12, 0], unsubmittedValue: 0)

        let sut = TopicListViewModel(topics: [topic1, topic2])

        #expect(sut.topics == [TopicCellModel(from: topic1), TopicCellModel(from: topic2)])
    }

}
