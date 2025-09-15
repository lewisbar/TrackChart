//
//  Int+numberOfDigits.swift
//  TrackChart
//
//  Created by LennartWisbar on 16.09.25.
//

import Foundation

extension Int {
     func numberOfDigits() -> Int {
        if self == 0 { return 1 } // Special case: 0 has 1 digit

        var digitCount = Int(log10(abs(Double(self))) + 1)

        if self < 0 {
            digitCount += 1  // Add 1 digit for the minus sign
        }

        return digitCount
    }
}
