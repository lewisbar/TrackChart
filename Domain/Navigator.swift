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

    public init() {}

    public func showDetail(for topic: NavigationTopic) {
        path.append(topic)
    }

    public func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
