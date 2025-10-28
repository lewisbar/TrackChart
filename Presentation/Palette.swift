//
//  Palette.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.10.25.
//

import SwiftUI
import UIKit

public struct Palette: Hashable, Sendable {
    public let name: String
    public let primary: Color
    public let mid: Color
    public let bottom: Color

    // Derived colors
    public var top: Color { primary.opacity(0.5) }
    public var pointOutline: Color { mid.opacity(1.0) }
    public var pointFill: Color { .white }
    public var shadow: Color { primary.opacity(0.3) }

    public static let availablePalettes = [
        Palette.ocean,
        Palette.fire,
        Palette.forest,
        Palette.sunset
    ]

    public static func palette(named name: String) -> Palette {
        availablePalettes.first(where: { $0.name == name }) ?? .ocean
    }

    public static var random: Palette {
        availablePalettes.randomElement() ?? .ocean
    }

    public static var ocean: Palette {
        Palette(
            name: "ocean",
            primary: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                    .systemBlue.withAlphaComponent(0.9) :
                    .systemBlue.withAlphaComponent(0.7)
            }),
            mid: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                    .systemCyan.withAlphaComponent(0.3) :
                    .systemCyan.withAlphaComponent(0.25)
            }),
            bottom: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                    .systemTeal.withAlphaComponent(0.15) :
                    .systemTeal.withAlphaComponent(0.1)
            })
        )
    }

    public static var fire: Palette {
        Palette(
            name: "fire",
            primary: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                    .systemRed.withAlphaComponent(0.9) :
                    .systemRed.withAlphaComponent(0.7)
            }),
            mid: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                    .systemOrange.withAlphaComponent(0.3) :
                    .systemOrange.withAlphaComponent(0.25)
            }),
            bottom: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                    .systemYellow.withAlphaComponent(0.15) :
                    .systemYellow.withAlphaComponent(0.1)
            })
        )
    }

    public static var forest: Palette {
        Palette(
            name: "forest",
            primary: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.0, green: 0.5, blue: 0.2, alpha: 0.9) :
                UIColor(red: 0.0, green: 0.4, blue: 0.15, alpha: 0.7)
            }),
            mid: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 0.3) :
                UIColor(red: 0.15, green: 0.5, blue: 0.25, alpha: 0.25)
            }),
            bottom: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.4, green: 0.5, blue: 0.2, alpha: 0.15) :
                UIColor(red: 0.35, green: 0.45, blue: 0.15, alpha: 0.1)
            })
        )
    }

    public static var sunset: Palette {
        Palette(
            name: "sunset",
            primary: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.9) :
                UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.7)
            }),
            mid: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.3) :
                UIColor(red: 0.9, green: 0.5, blue: 0.15, alpha: 0.25)
            }),
            bottom: Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ?
                UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 0.15) :
                UIColor(red: 0.7, green: 0.15, blue: 0.4, alpha: 0.1)
            })
        )
    }
}
