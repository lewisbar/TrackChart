//
//  UIFont+maxCharacterWidth.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 16.09.25.
//

import SwiftUI

public extension UIFont {
    func width(of string: String) -> CGFloat {
        CGFloat(string.count) * maxCharacterWidth()
    }

    private func maxCharacterWidth() -> CGFloat {
        let characters = "0123456789-" // Include digits and minus for negative numbers

        let maxWidth = characters.map { char in
            NSAttributedString(
                string: String(char),
                attributes: [.font: self]
            ).size().width
        }.max() ?? 0

        return ceil(maxWidth) // Round up for safety
    }
}
