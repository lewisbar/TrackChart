//
//  UIFont+maxCharacterWidth.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 16.09.25.
//

import SwiftUI

extension UIFont {
    func maxCharacterWidth() -> CGFloat {
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
