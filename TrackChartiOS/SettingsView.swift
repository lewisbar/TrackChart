//
//  SettingsView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.10.25.
//

import SwiftUI
import Presentation

struct SettingsView: View {
    @Binding var name: String
    @Binding var palette: Palette

    var body: some View {
        VStack {
            Text("Topic Settings")
            Form {
                TextField("Name", text: $name)
                palettePicker
            }
        }
    }

    private var palettePicker: some View {
        Picker("Palettes", selection: $palette) {
            ForEach(Palette.availablePalettes, id: \.self) { palette in
                Image(systemName: "circle.fill")
                    .tint(palette.primary)
                    .tag(palette)
            }
        }
        .pickerStyle(.palette)
    }
}

#Preview {
    SettingsView(name: .constant("Topic 1"), palette: .constant(.ocean))
}
