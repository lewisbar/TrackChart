//
//  StoreTests.swift
//  StoreTests
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Testing
import Store

class Store {
    private(set) var values: [Int] = []
}

struct StoreTests {
    @Test func startsEmpty() {
        let sut = Store()
        #expect(sut.values == [])
    }
}
