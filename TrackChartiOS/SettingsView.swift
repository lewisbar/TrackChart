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
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Topic Settings")
                .font(.largeTitle)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom)

            VStack(alignment: .leading) {
                Text("Name")

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
            }
            .padding(.bottom)

            VStack(alignment: .leading) {
                Text("Color Palette: \(palette.name)")

                palettePicker
            }

            Spacer()
        }
        .padding(.vertical)
        .padding(.horizontal, 24)
        .onAppear {
            if name.isEmpty {
                isTextFieldFocused = true
            }
        }
    }

    private var palettePicker: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(Palette.availablePalettes, id: \.self) { availablePalette in
                    Button {
                        palette = availablePalette
                    } label: {
                        Circle()
                            .fill(availablePalette.radialGradient())
                            .frame(width: 24, height: 24)
                            .overlay {
                                if palette == availablePalette {
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 2)
                                }
                            }
                            .frame(width: 28, height: 28)
                    }
                    .tint(nil)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    @Previewable @State var palette: Palette = .ocean

    VStack {
        SettingsView(name: .constant("Topic 1"), palette: $palette)
        Text(palette.name)
            .font(.largeTitle)
            .foregroundStyle(palette.linearGradient())
    }
}
