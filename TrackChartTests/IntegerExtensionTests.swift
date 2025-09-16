//
//  IntegerExtensionTests.swift
//  TrackChartTests
//
//  Created by LennartWisbar on 16.09.25.
//

import Testing
import TrackChart

struct IntegerExtensionTests {
    @Test func numberOfCharacters_zero_returnsOne() {
        #expect(0.numberOfCharacters() == 1)
    }

    @Test func numberOfCharacters_singleDigit_returnsOne() {
        for number in [1, 2, 3, 5, 6, 9] {
            #expect(number.numberOfCharacters() == 1)
        }
    }

    @Test func numberOfCharacters_twoDigits_returnsTwo() {
        for number in [10, 11, 12, 29, 71, 86, 99] {
            #expect(number.numberOfCharacters() == 2)
        }
    }

    @Test func numberOfCharacters_threeDigits_returnsThree() {
        for number in [100, 101, 102, 111, 303, 555, 611, 888, 999] {
            #expect(number.numberOfCharacters() == 3)
        }
    }

    @Test func numberOfCharacters_fourDigits_returnsFour() {
        for number in [1000, 1001, 1003, 1111, 2222, 3456, 8111, 8888, 9999] {
            #expect(number.numberOfCharacters() == 4)
        }
    }

    @Test func numberOfCharacters_singleDigit_negative_returnsTwo() {
        for number in [-9, -8, -7, -4, -2, -1] {
            #expect(number.numberOfCharacters() == 2)
        }
    }

    @Test func numberOfCharacters_twoDigits_negative_returnsThree() {
        for number in [-99, -98, -97, -88, -81, -50, -18, -11, -10] {
            #expect(number.numberOfCharacters() == 3)
        }
    }

    @Test func numberOfCharacters_threeDigits_negative_returnsFour() {
        for number in [-999, -998, -997, -888, -881, -811, -555, -312, -102, -101, -100] {
            #expect(number.numberOfCharacters() == 4)
        }
    }

    @Test func numberOfCharacters_fourDigits_negative_returnsFive() {
        for number in [-9999, -9998, -9997, -9111, -8888, -8881, -8111, -7654, -2000, -1111, -1002, -1001, -1000] {
            #expect(number.numberOfCharacters() == 5)
        }
    }
}
