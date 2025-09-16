//
//  Int+numberOfDigits.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Foundation

public extension Int {
    /// Calculates number of digits for a given number. The minus sign is counted as a digit, too.
    func numberOfDigits() -> Int {
        if self == 0 { return 1 } // Special case: 0 has 1 digit

        var digitCount = Int(log10(abs(Double(self))) + 1)

        if self < 0 {
            digitCount += 1  // Add 1 digit for the minus sign
        }

        return digitCount
    }
}
