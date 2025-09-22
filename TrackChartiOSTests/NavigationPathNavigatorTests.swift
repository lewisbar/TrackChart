//
//  NavigationPathNavigatorTests.swift
//  TrackChartTests
//
//  Created by Lennart Wisbar on 20.09.25.
//

import Testing
import Foundation
import TrackChartiOS

class NavigationPathNavigator {
    enum Destination: Equatable {
        case list
        case detail(Topic)
    }

    var path: [Destination] = [.list]

    func showDetail(for topic: Topic) {
        path.append(.detail(topic))
    }

    func goBack() {
        guard path.last != .list else { return }
        path.removeLast()
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

    @Test func showDetail_whenAlreadyOnDetail_addsAnotherDetailToStack() {
        let sut = NavigationPathNavigator()
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-1, -3])

        sut.showDetail(for: topic1)
        #expect(sut.path == [.list, .detail(topic1)])

        sut.showDetail(for: topic2)
        #expect(sut.path == [.list, .detail(topic1), .detail(topic2)])
    }

    @Test func goBack_removesDetailRepeatedly_butKeepsList() {
        let sut = NavigationPathNavigator()
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-1, -3])
        sut.path = [.list, .detail(topic1), .detail(topic2)]

        sut.goBack()
        #expect(sut.path == [.list, .detail(topic1)])

        sut.goBack()
        #expect(sut.path == [.list])

        sut.goBack()
        #expect(sut.path == [.list])
    }
}
