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
    public let mid:     Color
    public let bottom:  Color

    // MARK: Derived colors
    public var top:          Color { primary.opacity(0.5) }
    public var pointOutline: Color { mid.opacity(1.0) }
    public var pointFill:    Color { .white }
    public var shadow:       Color { primary.opacity(0.3) }

    public func linearGradient(startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) -> LinearGradient {
        LinearGradient(colors: [primary, top, mid, bottom], startPoint: startPoint, endPoint: endPoint)
    }

    public func radialGradient() -> RadialGradient {
        RadialGradient(colors: [primary, top, mid, bottom], center: .center, startRadius: 5, endRadius: 50)
    }

    // MARK: All palettes
    public static let availablePalettes: [Palette] = [
        ocean, fire, forest, sunset,
        aurora, volcano, meadow, twilight,
        coralReef, desertDune, arcticIce, midnight,
        roseGarden, lavenderField
    ]

    // MARK: Helpers
    public static func palette(named name: String) -> Palette {
        availablePalettes.first { $0.name == name } ?? ocean
    }

    public static var random: Palette {
        availablePalettes.randomElement() ?? ocean
    }

    // MARK: - Individual palette definitions

    // ── Ocean (default; based on blue) ───────────────────────────────────────
    public static var ocean: Palette {
        Palette(
            name: "Ocean",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? .systemBlue.withAlphaComponent(0.9)
                : .systemBlue.withAlphaComponent(0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? .systemCyan.withAlphaComponent(0.30)
                : .systemCyan.withAlphaComponent(0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? .systemTeal.withAlphaComponent(0.15)
                : .systemTeal.withAlphaComponent(0.10) })
        )
    }

    // ── Fire ───
    public static var fire: Palette {
        Palette(
            name: "Fire",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 1.00, green: 0.30, blue: 0.10, alpha: 0.9)
                : UIColor(red: 0.95, green: 0.25, blue: 0.05, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 1.00, green: 0.55, blue: 0.00, alpha: 0.30)
                : UIColor(red: 0.95, green: 0.50, blue: 0.00, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.90, green: 0.70, blue: 0.00, alpha: 0.15)
                : UIColor(red: 0.85, green: 0.65, blue: 0.00, alpha: 0.10) })
        )
    }

    // ── Forest ───────────────────────────────────────────────────────
    public static var forest: Palette {
        Palette(
            name: "Forest",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.00, green: 0.55, blue: 0.25, alpha: 0.9)
                : UIColor(red: 0.00, green: 0.45, blue: 0.20, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.25, green: 0.65, blue: 0.35, alpha: 0.30)
                : UIColor(red: 0.20, green: 0.55, blue: 0.30, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.45, green: 0.55, blue: 0.25, alpha: 0.15)
                : UIColor(red: 0.40, green: 0.50, blue: 0.20, alpha: 0.10) })
        )
    }

    // ── Sunset (warm coral → magenta) ───────
    public static var sunset: Palette {
        Palette(
            name: "Sunset",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 1.00, green: 0.35, blue: 0.45, alpha: 0.9)
                : UIColor(red: 0.95, green: 0.30, blue: 0.40, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 1.00, green: 0.55, blue: 0.70, alpha: 0.30)
                : UIColor(red: 0.95, green: 0.50, blue: 0.65, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.80, green: 0.20, blue: 0.55, alpha: 0.15)
                : UIColor(red: 0.75, green: 0.15, blue: 0.50, alpha: 0.10) })
        )
    }

    // ── Aurora (cool greens → blues → purples) ───────────────────────
    public static var aurora: Palette {
        Palette(
            name: "Aurora",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.10, green: 0.70, blue: 0.80, alpha: 0.9)
                : UIColor(red: 0.05, green: 0.60, blue: 0.70, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.30, green: 0.50, blue: 0.90, alpha: 0.30)
                : UIColor(red: 0.25, green: 0.45, blue: 0.85, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.45, green: 0.30, blue: 0.70, alpha: 0.15)
                : UIColor(red: 0.40, green: 0.25, blue: 0.65, alpha: 0.10) })
        )
    }

    // ── Volcano (deep reds → orange → yellow) ───────────────────────
    public static var volcano: Palette {
        Palette(
            name: "Volcano",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.80, green: 0.15, blue: 0.10, alpha: 0.9)
                : UIColor(red: 0.75, green: 0.10, blue: 0.05, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 1.00, green: 0.40, blue: 0.00, alpha: 0.30)
                : UIColor(red: 0.95, green: 0.35, blue: 0.00, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 1.00, green: 0.70, blue: 0.20, alpha: 0.15)
                : UIColor(red: 0.95, green: 0.65, blue: 0.15, alpha: 0.10) })
        )
    }

    // ── Meadow (fresh greens → lime → yellow-green) ───────────────────
    public static var meadow: Palette {
        Palette(
            name: "Meadow",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.30, green: 0.75, blue: 0.20, alpha: 0.9)
                : UIColor(red: 0.25, green: 0.65, blue: 0.15, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.55, green: 0.85, blue: 0.30, alpha: 0.30)
                : UIColor(red: 0.50, green: 0.80, blue: 0.25, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.70, green: 0.85, blue: 0.40, alpha: 0.15)
                : UIColor(red: 0.65, green: 0.80, blue: 0.35, alpha: 0.10) })
        )
    }

    // ── Twilight (deep indigos → violet → magenta) ───────────────────
    public static var twilight: Palette {
        Palette(
            name: "Twilight",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.25, green: 0.15, blue: 0.55, alpha: 0.9)
                : UIColor(red: 0.20, green: 0.10, blue: 0.50, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.45, green: 0.25, blue: 0.75, alpha: 0.30)
                : UIColor(red: 0.40, green: 0.20, blue: 0.70, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.65, green: 0.30, blue: 0.80, alpha: 0.15)
                : UIColor(red: 0.60, green: 0.25, blue: 0.75, alpha: 0.10) })
        )
    }

    // ── Coral Reef (vibrant coral → turquoise → aqua) ─────────────────
    public static var coralReef: Palette {
        Palette(
            name: "Coral Reef",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 1.00, green: 0.45, blue: 0.45, alpha: 0.9)
                : UIColor(red: 0.95, green: 0.40, blue: 0.40, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.70, blue: 0.70, alpha: 0.30)
                : UIColor(red: 0.15, green: 0.65, blue: 0.65, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.00, green: 0.80, blue: 0.80, alpha: 0.15)
                : UIColor(red: 0.00, green: 0.75, blue: 0.75, alpha: 0.10) })
        )
    }

    // ── Desert Dune (warm sand → terracotta → ochre) ─────────────────
    public static var desertDune: Palette {
        Palette(
            name: "Desert Dune",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.90, green: 0.60, blue: 0.30, alpha: 0.9)
                : UIColor(red: 0.85, green: 0.55, blue: 0.25, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.80, green: 0.45, blue: 0.20, alpha: 0.30)
                : UIColor(red: 0.75, green: 0.40, blue: 0.15, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.70, green: 0.55, blue: 0.30, alpha: 0.15)
                : UIColor(red: 0.65, green: 0.50, blue: 0.25, alpha: 0.10) })
        )
    }

    // ── Arctic Ice (icy blues → silver → white) ─────────────────────
    public static var arcticIce: Palette {
        Palette(
            name: "Arctic Ice",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.30, green: 0.70, blue: 0.95, alpha: 0.9)
                : UIColor(red: 0.25, green: 0.65, blue: 0.90, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.60, green: 0.80, blue: 0.95, alpha: 0.30)
                : UIColor(red: 0.55, green: 0.75, blue: 0.90, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.85, green: 0.90, blue: 0.95, alpha: 0.15)
                : UIColor(red: 0.80, green: 0.85, blue: 0.90, alpha: 0.10) })
        )
    }

    // ── Midnight (deep navy → indigo → violet) ─────────────────────
    public static var midnight: Palette {
        Palette(
            name: "Midnight",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.05, green: 0.05, blue: 0.30, alpha: 0.9)
                : UIColor(red: 0.00, green: 0.00, blue: 0.25, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.15, blue: 0.55, alpha: 0.30)
                : UIColor(red: 0.15, green: 0.10, blue: 0.50, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.35, green: 0.25, blue: 0.70, alpha: 0.15)
                : UIColor(red: 0.30, green: 0.20, blue: 0.65, alpha: 0.10) })
        )
    }

    // ── Rose Garden (soft pinks → rose → magenta) ───────────────────
    public static var roseGarden: Palette {
        Palette(
            name: "Rose Garden",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.95, green: 0.45, blue: 0.60, alpha: 0.9)
                : UIColor(red: 0.90, green: 0.40, blue: 0.55, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.90, green: 0.60, blue: 0.75, alpha: 0.30)
                : UIColor(red: 0.85, green: 0.55, blue: 0.70, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.80, green: 0.70, blue: 0.85, alpha: 0.15)
                : UIColor(red: 0.75, green: 0.65, blue: 0.80, alpha: 0.10) })
        )
    }

    // ── Lavender Field (lavender → lilac → soft purple) ─────────────
    public static var lavenderField: Palette {
        Palette(
            name: "Lavender Field",
            primary: Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.65, green: 0.45, blue: 0.85, alpha: 0.9)
                : UIColor(red: 0.60, green: 0.40, blue: 0.80, alpha: 0.7) }),
            mid:     Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.75, green: 0.60, blue: 0.90, alpha: 0.30)
                : UIColor(red: 0.70, green: 0.55, blue: 0.85, alpha: 0.25) }),
            bottom:  Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                ? UIColor(red: 0.85, green: 0.75, blue: 0.95, alpha: 0.15)
                : UIColor(red: 0.80, green: 0.70, blue: 0.90, alpha: 0.10) })
        )
    }
}
