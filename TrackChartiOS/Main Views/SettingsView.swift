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
    @State private var aggregator: Aggregator
    let rename: (String) -> Void
    let changePalette: (Palette) -> Void
    let changeAggregator: (Aggregator) -> Void
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss
    @State private var isShowingLongAggregationExplanation = false

    private let originalName: String
    private let originalPalette: Palette
    private let originalAggregator: Aggregator

    init(
        name: String,
        palette: Palette,
        aggregator: Aggregator,
        rename: @escaping (String) -> Void,
        changePalette: @escaping (Palette) -> Void,
        changeAggregator: @escaping (Aggregator) -> Void,
    ) {
        self.name = name
        self.palette = palette
        self.aggregator = aggregator
        self.rename = rename
        self.changePalette = changePalette
        self.changeAggregator = changeAggregator

        self.originalName = name
        self.originalPalette = palette
        self.originalAggregator = aggregator
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            title
            nameSetting
            colorSetting
            aggregatorSetting.padding(.top)
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
        .onDisappear {
            guard aggregator != originalAggregator else { return }
            changeAggregator(aggregator)
        }
    }

    private var title: some View {
        Text(.topicSettings)
            .font(.largeTitle)
            .fontWeight(.medium)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
    }

    private var nameSetting: some View {
        VStack(alignment: .leading) {
            Text(.name)

            TextField(String(localized: .name), text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
        }
        .padding(.bottom)
    }

    private var colorSetting: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(.colorPalette)
                Spacer()
                Text(palette.name)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(.selectedColorPalette(palette.name))

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
        .accessibilityLabel(availablePalette.name + selectedPaletteSuffix(for: availablePalette))
        .accessibilityHint(.selectsThisColorPaletteForChartRendering, isEnabled: palette != availablePalette)
    }

    private func selectedPaletteSuffix(for availablePalette: Palette) -> String {
        palette == availablePalette ? String(localized: .isSelectedPalette) : ""
    }

    private var aggregatorSetting: some View {
        VStack(alignment: .leading) {
            Text(.aggregationMethod)

            Picker(.aggregator, selection: $aggregator) {
                ForEach(Aggregator.allCases, id: \.self) { aggregator in
                    Text(aggregator.localizedName)
                }
            }
            .pickerStyle(.segmented)

            Text(.aggregationExplanationShort)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)

            Button {
                isShowingLongAggregationExplanation = true
            } label: {
                Text(.learnMore)
                    .font(.caption)
                    .padding(.horizontal, 8)
            }
            .sheet(isPresented: $isShowingLongAggregationExplanation) {
                ScrollView {
                    VStack(spacing: 0) {
                        Text(.aggregationExplained)
                            .font(.title)

                        Text(.aggregationExplanationLong)
                            .font(.body)
                            .minimumScaleFactor(0.7)
                            .padding()
                            .presentationDetents([.medium, .large])
                            .presentationCompactAdaptation(.popover)
                    }
                    .padding()
                }
            }
        }
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
        .tint(.primary)
        .padding()
    }
}

#Preview {
    @Previewable @State var name: String = "Topic 1"
    @Previewable @State var palette: Palette = Palette.palette(named: "Lavender Field")

    VStack {
        SettingsView(name: name, palette: palette, aggregator: .sum, rename: { _ in }, changePalette: { _ in }, changeAggregator: { _ in })
        Text(palette.name)
            .font(.largeTitle)
            .foregroundStyle(palette.linearGradient())
    }
}
