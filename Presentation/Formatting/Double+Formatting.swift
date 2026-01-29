//
//  Double+Formatting.swift
//  Presentation
//
//  Created by Lennart Wisbar on 29.01.26.
//

import Foundation

public extension Double {
    func compact(_ locale: Locale = .current) -> String {
        formatted(.number.notation(.compactName).locale(locale))
    }
}
