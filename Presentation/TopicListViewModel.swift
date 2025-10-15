//
//  TopicListViewModel.swift
//  Presentation
//
//  Created by Lennart Wisbar on 15.10.25.
//

import Domain

@Observable
public class TopicListViewModel {
    public var topics: [TopicCellModel] {
        didSet {
            guard !updatingFromStore, oldValue != topics else { return }
            updateTopicList(topics.map { $0.id })
        }
    }
    private var updatingFromStore = false

    private let updateTopicList: ([UUID]) -> Void

    public init(topics: [Topic], updateTopicList: @escaping ([UUID]) -> Void) {
        self.topics = topics.map(TopicCellModel.init)
        self.updateTopicList = updateTopicList
    }

    public func updateFromStore(topics: [Topic]) {
        updatingFromStore = true
        self.topics = topics.map(TopicCellModel.init)
        updatingFromStore = false
    }
}
