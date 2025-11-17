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
                Text("Color Palette")
                Spacer()
                Text(palette.name)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Selected color palette: \(palette.name)")

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
        .accessibilityLabel("\(availablePalette.name)\(palette == availablePalette ? " , selected" : "")")
        .accessibilityHint("Selects this color palette for chart rendering", isEnabled: palette != availablePalette)
    }

    private var aggregatorSetting: some View {
        VStack(alignment: .leading) {
            Text("Aggregation method")

            Picker("Aggregator", selection: $aggregator) {
                ForEach(Aggregator.allCases, id: \.self) { aggregator in
                    Text(aggregator.name)
                }
            }
            .pickerStyle(.segmented)

            Text(aggregationExplanationShort)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)

            Button {
                isShowingLongAggregationExplanation = true
            } label: {
                Text("Learn more")
                    .font(.caption)
                    .padding(.horizontal, 8)
            }
            .sheet(isPresented: $isShowingLongAggregationExplanation) {
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Aggregation Explained")
                            .font(.title)

                        Text(aggregationExplanationLong)
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

    private let aggregationExplanationShort =
        """
        Entries are aggregated using the selected method.
        - Sum makes more sense for data that accumulates, like pushups or pages read.
        - Average makes more sense for data that doesn't accumulate, like your weight.
        """

    private let aggregationExplanationLong =
        """
        Entries are aggregated using the selected method to reduce the number of visible data points, making the chart easier to analyze and improving rendering performance. Week view and month view both aggregate all entries of a day into a single data point. Year view aggregates all entries of a month into a single data point.
        
        For example, in week view, if you have entered the values 1, 2, and 3 all in the same day, if you choose the sum method, this day will have a value of 1+2+3=6. But if you choose the average method, it's (1+2+3)/3=2, which is that day's average.
        
        Sum makes more sense for data that accumulates, like pushups or pages read. For example, if you track how many pages you read, and you read 5 pages in the morning, 10 in the afternoon, and 15 in the evening, it's probably more interesting to know you read 30 pages total that day (sum) than the fact that the average entry that day was 10.
        
        Average makes more sense for data that doesn't accumulate, like your weight. If you weigh 75 kg in week 1, 80 in week 2, and 85 in week 3, you probably don't want to know that you weighed 240 kg that month (sum), but that you weighed 80 kg on average.
        """

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
