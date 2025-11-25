//
//  SettingsView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.10.25.
//

import SwiftUI
import DataProcessing

struct SettingsTopic {
    var name: String
    var palette: Palette
    var aggregator: Aggregator
    var treatsMissingAsZero: Bool
}

struct SettingsView: View {
    @State private var topic: SettingsTopic
    let save: (SettingsTopic) -> Void

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss
    @State private var isShowingLongAggregationExplanation = false

    init(
        topic: SettingsTopic,
        save: @escaping (SettingsTopic) -> Void
    ) {
        self.topic = topic
        self.save = save
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    nameSetting
                    colorSetting
                    aggregatorSetting.padding(.top)
                    zeroFillingSetting.padding(.top)
                    Spacer()
                }
                .padding(.vertical)
                .padding(.horizontal, 24)
            }
            .navigationTitle(.topicSettings)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { cancelButton }
                ToolbarItem(placement: .confirmationAction) { doneButton }
            }
            .onAppear {
                if topic.name.isEmpty {
                    isTextFieldFocused = true
                }
            }
        }
    }

    private var nameSetting: some View {
        VStack(alignment: .leading) {
            Text(.name)

            TextField(String(localized: .name), text: $topic.name)
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
                Text(topic.palette.name)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(.selectedColorPalette(topic.palette.name))

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
                    proxy.scrollTo(topic.palette, anchor: .center)
                }
            }
            .onChange(of: topic.palette) { oldPalette, newPalette in
                guard newPalette != oldPalette else { return }
                topic.palette = newPalette

                withAnimation {
                    proxy.scrollTo(newPalette, anchor: .center)
                }

            }
        }
    }

    private func paletteButton(for availablePalette: Palette, proxy: ScrollViewProxy) -> some View {
        Button {
            topic.palette = availablePalette

            withAnimation {
                proxy.scrollTo(availablePalette, anchor: .center)
            }
        } label: {
            Circle()
                .fill(availablePalette.radialGradient())
                .frame(width: 24, height: 24)
                .overlay {
                    if topic.palette == availablePalette {
                        Circle()
                            .stroke(Color.primary, lineWidth: 2)
                    }
                }
                .frame(width: 28, height: 28)
                .id(availablePalette) // Required for scrollTo
        }
        .tint(nil)
        .accessibilityLabel(availablePalette.name + selectedPaletteSuffix(for: availablePalette))
        .accessibilityHint(.selectsThisColorPaletteForChartRendering, isEnabled: topic.palette != availablePalette)
    }

    private func selectedPaletteSuffix(for availablePalette: Palette) -> String {
        topic.palette == availablePalette ? String(localized: .isSelectedPalette) : ""
    }

    private var aggregatorSetting: some View {
        VStack(alignment: .leading) {
            Text(.aggregationMethod)

            Picker(.aggregator, selection: $topic.aggregator) {
                ForEach(Aggregator.allCases, id: \.self) { aggregator in
                    Text(aggregator.localizedName)
                }
            }
            .pickerStyle(.segmented)

            Text(.aggregationExplanationShort)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            Button {
                isShowingLongAggregationExplanation = true
            } label: {
                Text(.learnMore)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.top, 1)
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

    private var zeroFillingSetting: some View {
        VStack(alignment: .leading) {
            Toggle(.displayEmptyPeriodsAsZero, isOn: $topic.treatsMissingAsZero)

            VStack(alignment: .leading, spacing: 4) {
                Text(.zeroFillingExplanationShort)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
        }
    }

    private var cancelButton: some View {
        Button(.cancel, role: .cancel) { dismiss() }
    }

    private var doneButton: some View {
        Button(.done, role: .none) {
            save(topic)
            dismiss()
        }
        .bold()
        .disabled(topic.name.isEmpty)
    }
}

#Preview {
    let topic = SettingsTopic(name: "Topic 1", palette: .arcticIce, aggregator: .average, treatsMissingAsZero: false)

    VStack {
        SettingsView(topic: topic, save: { _ in })
        Text(topic.palette.name)
            .font(.largeTitle)
            .foregroundStyle(topic.palette.linearGradient())
    }
}
