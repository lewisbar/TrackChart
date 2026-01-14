//
//  SettingsView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.10.25.
//

import SwiftUI
import Presentation

struct SettingsView: View {
    @State private var topic: SettingsTopic
    let save: (SettingsTopic) -> Void

    @FocusState private var isTitleFieldFocused: Bool
    @FocusState private var isDetailsFieldFocused: Bool
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
            Form {
                Section {
                    nameSetting
                    colorSetting
                }

                Section {
                    detailsSetting
                } header: {
                    Text(.description)
                }

                Section {
                    aggregatorSetting
                } header: {
                    Text(.aggregationMethod)
                } footer: {
                    aggregatorSettingExplanation
                }

                Section {
                    zeroFillingSetting
                } footer: {
                    Text(.zeroFillingExplanationShort)
                }
            }
            .formStyle(.grouped)
            .padding(.top, -16)
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                withAnimation {
                    isTitleFieldFocused = false
                    isDetailsFieldFocused = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { cancelButton }
                ToolbarItem(placement: .confirmationAction) { doneButton }
            }
            .onAppear {
                if topic.name.isEmpty {
                    isTitleFieldFocused = true
                }
            }
        }
    }

    private var nameSetting: some View {
        LabeledContent {
            TextField(.topicName, text: $topic.name, prompt: Text(.topicName).foregroundColor(.secondary))
                .multilineTextAlignment(.trailing)
                .focused($isTitleFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    isTitleFieldFocused = false
                }
        } label: {
            Text(.name)
        }
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

    private var detailsSetting: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $topic.details)
                .frame(minHeight: 60)
                .focused($isDetailsFieldFocused)

            if topic.details.isEmpty {
                detailsPlaceholder
            }
        }
    }

    private var detailsPlaceholder: some View {
        Text(.enterADescription)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 5)
            .padding(.top, 8)
            .allowsHitTesting(false)
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
        Picker(.aggregator, selection: $topic.aggregator) {
            ForEach(ViewAggregator.allCases, id: \.self) { aggregator in
                Text(aggregator.localizedName)
            }
        }
        .pickerStyle(.segmented)
    }

    private var aggregatorSettingExplanation: some View {
        VStack(alignment: .leading) {
            Text(.aggregationExplanationShort)

            Button {
                isShowingLongAggregationExplanation = true
            } label: {
                Text(.learnMore)
                    .font(.footnote)
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

    private var zeroFillingSetting: some View {
        VStack(alignment: .leading) {
            Toggle(.displayEmptyPeriodsAsZero, isOn: $topic.treatsMissingAsZero)
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
    let topic = SettingsTopic(name: "Topic 1", details: "", palette: .arcticIce, aggregator: .average, treatsMissingAsZero: false)

    SettingsView(topic: topic, save: { _ in })
}
