//
//  PaletteTests.swift
//  TrackChartiOSTests
//
//  Created by Lennart Wisbar on 06.11.25.
//

import Testing
import TrackChartiOS

struct PaletteTests {
    @Test func id_returnsName()  {
        #expect(Palette.ocean.id == Palette.ocean.name)
        #expect(Palette.fire.id == Palette.fire.name)
        #expect(Palette.roseGarden.id == Palette.roseGarden.name)
    }

    @Test func paletteNamed() {
        #expect(Palette.palette(named: Palette.volcano.name).id == Palette.volcano.id)
        #expect(Palette.palette(named: Palette.twilight.name).id == Palette.twilight.id)
        #expect(Palette.palette(named: Palette.lavenderField.name).id == Palette.lavenderField.id)
    }
}
