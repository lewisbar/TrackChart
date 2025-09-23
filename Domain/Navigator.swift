//
//  Navigator.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 23.09.25.
//

import Foundation

@Observable
public class Navigator {
    public var path = [NavigationTopic]()
    private let saveTopic: (Topic) -> Void

    public init(saveTopic: @escaping (Topic) -> Void) {
        self.saveTopic = saveTopic
    }

    public func showDetail(for topic: NavigationTopic) {
        path.append(topic)
    }

    public func showNewDetail() {
        let newTopic = Topic(id: UUID(), name: "", entries: [])
        saveTopic(newTopic)
        path.append(NavigationTopic(from: newTopic))
    }

    public func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
