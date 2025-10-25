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
                .font(.largeTitle)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)

            TextField("Name", text: $name)

            palettePicker

            Spacer()
        }
        .padding()
    }

    private var palettePicker: some View {
        HStack(spacing: 16) {
            ForEach(Palette.availablePalettes, id: \.self) { availablePalette in
                Button {
                    palette = availablePalette
                } label: {
                    Circle()
                        .fill(availablePalette.primary)
                        .frame(width: 24, height: 24)
                        .overlay {
                            if palette == availablePalette {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            }
                        }
                }
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView(name: .constant("Topic 1"), palette: .constant(.ocean))
}
