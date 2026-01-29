//
//  Double+Formatting.swift
//  Presentation
//
//  Created by Lennart Wisbar on 29.01.26.
//

import Foundation

public extension Double {
    func compactTwoDecimals(_ locale: Locale) -> String {
        formatted(
            .number
                .notation(.compactName)
                .locale(locale)
                .precision(precision(for: locale))
        )
    }

    private func precision(for locale: Locale) -> NumberFormatStyleConfiguration.Precision {
        let doesNotAbbreviateThousands = locale.language.languageCode?.identifier == "de"
        let absolute = abs(self)
        let isInTheThousands = absolute >= 1000 && absolute < 1_000_000

        return if isInTheThousands, doesNotAbbreviateThousands {
            .fractionLength(0)
        } else {
            .fractionLength(0...2)
        }
    }
}
