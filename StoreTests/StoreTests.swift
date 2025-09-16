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

    func add(_ value: Int) {
        values.append(value)
    }
}

struct StoreTests {
    @Test func startsEmpty() {
        let sut = Store()
        #expect(sut.values == [])
    }

    @Test func add_appendsValue() {
        let sut = Store()
        #expect(sut.values == [])

        sut.add(4)
        #expect(sut.values == [4])

        sut.add(2)
        #expect(sut.values == [4, 2])
    }
}
