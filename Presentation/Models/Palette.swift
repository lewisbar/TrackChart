//
//  Palette.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.10.25.
//

import SwiftUI

public struct Palette: Identifiable, Hashable, Sendable {
    private init(name: String, primary: Color, mid: Color, bottom: Color) {
        self.name = name
        self.primary = primary
        self.mid = mid
        self.bottom = bottom
    }

    public var id: String { name }
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

    public static var ocean: Palette {
        Palette(
            name: "Ocean",
            primary: .Ocean.primary,
            mid: .Ocean.mid,
            bottom: .Ocean.bottom
        )
    }

    public static var fire: Palette {
        Palette(
            name: "Fire",
            primary: .Fire.primary,
            mid: .Fire.mid,
            bottom: .Fire.bottom
        )
    }

    public static var forest: Palette {
        Palette(
            name: "Forest",
            primary: .Forest.primary,
            mid: .Forest.mid,
            bottom: .Forest.bottom
        )
    }

    public static var sunset: Palette {
        Palette(
            name: "Sunset",
            primary: .Sunset.primary,
            mid: .Sunset.mid,
            bottom: .Sunset.bottom
        )
    }

    public static var aurora: Palette {
        Palette(
            name: "Aurora",
            primary: .Aurora.primary,
            mid: .Aurora.mid,
            bottom: .Aurora.bottom
        )
    }

    public static var volcano: Palette {
        Palette(
            name: "Volcano",
            primary: .Volcano.primary,
            mid: .Volcano.mid,
            bottom: .Volcano.bottom
        )
    }

    public static var meadow: Palette {
        Palette(
            name: "Meadow",
            primary: .Meadow.primary,
            mid: .Meadow.mid,
            bottom: .Meadow.bottom
        )
    }

    public static var twilight: Palette {
        Palette(
            name: "Twilight",
            primary: .Twilight.primary,
            mid: .Twilight.mid,
            bottom: .Twilight.bottom
        )
    }

    public static var coralReef: Palette {
        Palette(
            name: "Coral Reef",
            primary: .CoralReef.primary,
            mid: .CoralReef.mid,
            bottom: .CoralReef.bottom
        )
    }

    public static var desertDune: Palette {
        Palette(
            name: "Desert Dune",
            primary: .DesertDune.primary,
            mid: .DesertDune.mid,
            bottom: .DesertDune.bottom
        )
    }

    public static var arcticIce: Palette {
        Palette(
            name: "Arctic Ice",
            primary: .ArcticIce.primary,
            mid: .ArcticIce.mid,
            bottom: .ArcticIce.bottom
        )
    }

    public static var midnight: Palette {
        Palette(
            name: "Midnight",
            primary: .Midnight.primary,
            mid: .Midnight.mid,
            bottom: .Midnight.bottom
        )
    }

    public static var roseGarden: Palette {
        Palette(
            name: "Rose Garden",
            primary: .RoseGarden.primary,
            mid: .RoseGarden.mid,
            bottom: .RoseGarden.bottom
        )
    }

    public static var lavenderField: Palette {
        Palette(
            name: "Lavender Field",
            primary: .LavenderField.primary,
            mid: .LavenderField.mid,
            bottom: .LavenderField.bottom
        )
    }
}
