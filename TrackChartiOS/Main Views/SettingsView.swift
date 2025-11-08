//
//  SettingsView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.10.25.
//

import SwiftUI

struct SettingsView: View {
    @State private var name: String
    @State private var palette: Palette
    let rename: (String) -> Void
    let changePalette: (Palette) -> Void
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss

    private let originalName: String
    private let originalPalette: Palette

    init(
        name: String,
        palette: Palette,
        rename: @escaping (String) -> Void,
        changePalette: @escaping (Palette) -> Void
    ) {
        self.name = name
        self.palette = palette
        self.rename = rename
        self.changePalette = changePalette

        self.originalName = name
        self.originalPalette = palette
    }

    var body: some View {
        VStack(alignment: .leading) {
            title
            nameSetting
            colorSetting
            Spacer()
        }
        .padding(.vertical)
        .padding(.horizontal, 24)
        .overlay(alignment: .topTrailing) {
            dismissButton
        }
        .onAppear {
            if name.isEmpty {
                isTextFieldFocused = true
            }
        }
        .onDisappear {
            guard name != originalName else { return }
            rename(name)
        }
        .onDisappear {
            guard palette != originalPalette else { return }
            changePalette(palette)
        }
    }

    private var title: some View {
        Text("Topic Settings")
            .font(.largeTitle)
            .fontWeight(.medium)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
    }

    private var nameSetting: some View {
        VStack(alignment: .leading) {
            Text("Name")

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
        }
        .padding(.bottom)
    }

    private var colorSetting: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Color Palette:")
                Spacer()
                Text(palette.name)
                    .foregroundStyle(.secondary)
            }

            palettePicker
        }
    }

    private var palettePicker: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(Palette.availablePalettes) { availablePalette in
                        paletteButton(for: availablePalette, proxy: proxy)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                withAnimation {
                    proxy.scrollTo(palette, anchor: .center)
                }
            }
            .onChange(of: palette) { oldPalette, newPalette in
                guard newPalette != oldPalette else { return }
                palette = newPalette

                withAnimation {
                    proxy.scrollTo(newPalette, anchor: .center)
                }

            }
        }
    }

    private func paletteButton(for availablePalette: Palette, proxy: ScrollViewProxy) -> some View {
        Button {
            palette = availablePalette

            withAnimation {
                proxy.scrollTo(availablePalette, anchor: .center)
            }
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
                .id(availablePalette) // Required for scrollTo
        }
        .tint(nil)
    }

    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 0.5))
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .padding()
    }
}

#Preview {
    @Previewable @State var name: String = "Topic 1"
    @Previewable @State var palette: Palette = Palette.palette(named: "Lavender Field")

    VStack {
        SettingsView(name: name, palette: palette, rename: { _ in }, changePalette: { _ in })
        Text(palette.name)
            .font(.largeTitle)
            .foregroundStyle(palette.linearGradient())
    }
}
