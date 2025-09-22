//
//  NavigatorTests.swift
//  TrackChartTests
//
//  Created by Lennart Wisbar on 20.09.25.
//

import Testing
import Foundation

struct NavigationTopic: Hashable, Codable {
    let id: UUID
    let name: String
    let entries: [Int]
}

class Navigator {
    var path = [NavigationTopic]()

    func showDetail(for topic: NavigationTopic) {
        path.append(topic)
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

struct NavigatorTests {
    @Test func init_startsWithHome() {
        let sut = Navigator()
        #expect(sut.path.isEmpty)
    }

    @Test func showDetail_addsDetailToStack() {
        let sut = Navigator()
        let topic = NavigationTopic(id: UUID(), name: "a topic", entries: [1, 3, 5])

        sut.showDetail(for: topic)

        #expect(sut.path == [topic])
    }

    @Test func showDetail_whenAlreadyOnDetail_addsAnotherDetailToStack() {
        let sut = Navigator()
        let topic1 = NavigationTopic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = NavigationTopic(id: UUID(), name: "another topic", entries: [-1, -3])

        sut.showDetail(for: topic1)
        #expect(sut.path == [topic1])

        sut.showDetail(for: topic2)
        #expect(sut.path == [topic1, topic2])
    }

    @Test func goBack_removesDetailRepeatedly() {
        let sut = Navigator()
        let topic1 = NavigationTopic(id: UUID(), name: "a topic", entries: [1, 3, 5])
        let topic2 = NavigationTopic(id: UUID(), name: "another topic", entries: [-1, -3])
        sut.path = [topic1, topic2]

        sut.goBack()
        #expect(sut.path == [topic1])

        sut.goBack()
        #expect(sut.path == [])

        sut.goBack()
        #expect(sut.path == [])
    }
}
