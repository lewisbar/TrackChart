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
    }

    var path: [Destination] = [.list]
}

struct NavigationPathNavigatorTests {
    @Test func init_startsWithTopicList() {
        let sut = NavigationPathNavigator()
        sut.path = [.list]
    }
}
