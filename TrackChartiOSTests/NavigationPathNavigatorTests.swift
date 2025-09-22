//
//  NavigationPathNavigatorTests.swift
//  TrackChartTests
//
//  Created by Lennart Wisbar on 20.09.25.
//

import Testing
import Foundation
import TrackChartiOS
import Domain

class NavigationPathNavigator {
    enum Destination: Equatable {
        case detail(Topic)
    }

    var path: [Destination] = []

    func showDetail(for topic: Topic) {
        path.append(.detail(topic))
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

struct NavigationPathNavigatorTests {
    @Test func init_startsWithHome() {
        let sut = NavigationPathNavigator()
        #expect(sut.path == [])
    }

    @Test func showDetail_addsDetailToStack() {
        let sut = NavigationPathNavigator()
        let topic = Topic(id: UUID(), name: "a topic", entries: [1, 3, 5])

        sut.showDetail(for: topic)

        #expect(sut.path == [.detail(topic)])
    }

    @Test func showDetail_whenAlreadyOnDetail_addsAnotherDetailToStack() {
        let sut = NavigationPathNavigator()
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-1, -3])

        sut.showDetail(for: topic1)
        #expect(sut.path == [.detail(topic1)])

        sut.showDetail(for: topic2)
        #expect(sut.path == [.detail(topic1), .detail(topic2)])
    }

    @Test func goBack_removesDetailRepeatedly() {
        let sut = NavigationPathNavigator()
        let topic1 = Topic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = Topic(id: UUID(), name: "another topic", entries: [-1, -3])
        sut.path = [.detail(topic1), .detail(topic2)]

        sut.goBack()
        #expect(sut.path == [.detail(topic1)])

        sut.goBack()
        #expect(sut.path == [])

        sut.goBack()
        #expect(sut.path == [])
    }
}
