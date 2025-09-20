//
//  NavigationPathNavigatorTests.swift
//  TrackChartTests
//
//  Created by Lennart Wisbar on 20.09.25.
//

import Testing
import Foundation
import TrackChart

class NavigationPathNavigator {
    enum Destination: Equatable {
        case list
        case detail(Topic)
    }

    var path: [Destination] = [.list]

    func showDetail(for topic: Topic) {
        path.append(.detail(topic))
    }
}

struct NavigationPathNavigatorTests {
    @Test func init_startsWithTopicList() {
        let sut = NavigationPathNavigator()
        sut.path = [.list]
    }

    @Test func showDetail_addsDetailToStack() {
        let sut = NavigationPathNavigator()
        let topic = Topic(id: UUID(), name: "a topic", entries: [1, 3, 5])

        sut.showDetail(for: topic)

        #expect(sut.path == [.list, .detail(topic)])
    }
}
