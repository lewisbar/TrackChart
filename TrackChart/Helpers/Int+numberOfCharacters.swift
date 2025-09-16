//
//  Int+numberOfCharacters.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 16.09.25.
//

import Foundation

public extension Int {
    /// Calculates number of digits for a given number. The minus sign is counted as a digit, too.
    func numberOfCharacters() -> Int {
        "\(self)".count
    }
}
