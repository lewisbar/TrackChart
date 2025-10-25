//
//  ChartView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Charts
import Presentation

struct ChartView<Placeholder: View>: View {
    private let dataProvider: ChartDataProvider
    private let rawEntries: [ChartEntry]
    private var entries: [ProcessedEntry] { dataProvider.processedEntries(from: rawEntries) }
    private let highlightsExtrema: Bool
    private let showsAxisLabels: Bool
    @ViewBuilder private let placeholder: () -> Placeholder

    private let xLabel = "Date"
    private let yLabel = "Value"

    private let primaryColor = Color.blue
    private var topColor: Color { primaryColor.opacity(0.5) }
    private var midColor: Color { .cyan.opacity(0.3) }
    private var bottomColor: Color { .teal.opacity(0.1) }
    private var pointOutlineColor: Color { .cyan }
    private var pointFillColor: Color { .white }

    init(
        rawEntries: [ChartEntry],
        dataProvider: ChartDataProvider = .raw,
        highlightsExtrema: Bool = true,
        showsAxisLabels: Bool = true,
        placeholder: @escaping () -> Placeholder = { ChartPlaceholderView() }
    ) {
        self.rawEntries = rawEntries
        self.dataProvider = dataProvider
        self.highlightsExtrema = highlightsExtrema
        self.showsAxisLabels = showsAxisLabels
        self.placeholder = placeholder
    }

    var body: some View {
        if !entries.isEmpty {
            Chart(entries, content: chartContent)
                .chartXScale(domain: dateRange)
                .chartXAxis(content: xAxisContent)
                .chartYAxis(content: yAxisContent)
        } else {
            placeholder()
        }
    }

    private var dateRange: ClosedRange<Date> {
        let dates = entries.map(\.timestamp)
        guard let minDate = dates.min(), let maxDate = dates.max() else {
            // Fallback range if entries are empty (shouldn't happen since we check !entries.isEmpty)
            let now = Date()
            return now...now
        }
        return minDate...maxDate
    }

    @ChartContentBuilder
    private func chartContent(for entry: ProcessedEntry) -> some ChartContent {
        areaMark(for: entry)
        lineMark(for: entry)
        if shouldShowPointMark(for: entry) { pointMark(for: entry) }
    }

    private func areaMark(for entry: ProcessedEntry) -> some ChartContent {
        AreaMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .foregroundStyle(areaGradient)
            .interpolationMethod(.catmullRom)
    }

    private var areaGradient: some ShapeStyle {
        LinearGradient(
            stops: [
                .init(color: topColor, location: 0.0),
                .init(color: midColor, location: 0.5),
                .init(color: bottomColor, location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func lineMark(for entry: ProcessedEntry) -> some ChartContent {
        LineMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .foregroundStyle(primaryColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .shadow(color: primaryColor.opacity(0.3), radius: 2)
            .interpolationMethod(.catmullRom)
    }

    private func shouldShowPointMark(for entry: ProcessedEntry) -> Bool {
        entries.count == 1 || (highlightsExtrema && isExtremum(entry))
    }

    private func isExtremum(_ entry: ProcessedEntry) -> Bool {
        isMaxPositiveValue(entry.value) || isMinNegativeValue(entry.value)
    }

    private func pointMark(for entry: ProcessedEntry) -> some ChartContent {
        PointMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .symbol(symbol: pointSymbol)
            .annotation(position: .top, spacing: 2) { maxPositiveValueAnnotation(for: entry) }
            .annotation(position: .bottom, spacing: 2) { minNegativeValueAnnotation(for: entry) }
    }

    private func pointSymbol() -> some View {
        ZStack {
            Circle().fill(pointFillColor)
            Circle().stroke(pointOutlineColor, lineWidth: 2)
        }
        .frame(width: 6)
    }

    @ViewBuilder
    private func maxPositiveValueAnnotation(for entry: ProcessedEntry) -> some View {
        if highlightsExtrema, isMaxPositiveValue(entry.value) {
            annotation(for: entry.value)
        }
    }

    @ViewBuilder
    private func minNegativeValueAnnotation(for entry: ProcessedEntry) -> some View {
        if highlightsExtrema, isMinNegativeValue(entry.value) {
            annotation(for: entry.value)
        }
    }

    private func isMaxPositiveValue(_ value: Double) -> Bool {
        value > 0 && value == entries.map(\.value).max()
    }

    private func isMinNegativeValue(_ value: Double) -> Bool {
        value < 0 && value == entries.map(\.value).min()
    }

    private func annotation(for value: Double) -> some View {
        let formattedValue = ChartNumberFormatter.extremaAnnotation.string(from: NSNumber(value: value)) ?? "\(value)"

        return Text("\(formattedValue)")
            .font(.caption)
            .foregroundColor(pointOutlineColor)
    }

    @AxisContentBuilder
    private func xAxisContent() -> some AxisContent {
        if showsAxisLabels {
            AxisMarks(preset: .aligned, values: .automatic(desiredCount: 4, roundLowerBound: false, roundUpperBound: false)) {
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))

                AxisValueLabel()
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        }
    }

    @AxisContentBuilder
    private func yAxisContent() -> some AxisContent {
        if showsAxisLabels {
            AxisMarks(values: .automatic(desiredCount: 2, roundLowerBound: false, roundUpperBound: false)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))

                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))

                AxisValueLabel()
                    .foregroundStyle(.gray)
                    .font(.caption)

                if value.as(Int.self) == 0 {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: []))
                        .foregroundStyle(.black.opacity(0.5)) // Highlight y=0
                }
            }
        }
    }
}

private enum ChartNumberFormatter {
    static let extremaAnnotation: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

#Preview {
    let entries1 = [0, 2, 1, 2, 3, 4, 3, 5, 8.437, 7].enumerated().map { index, value in
        ChartEntry(
            value: Double(value),
            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
        )
    }

    let entries2 = [0, -2, -1, -2, -3, -4, -3, -5, -8, -7].enumerated().map { index, value in
        ChartEntry(
            value: Double(value),
            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
        )
    }

    let entries3 = [0, 2, 1, 2, 3, 4, 3, -1, -2, -3, -4, 5, 8, 7, 2, 1, 2, 3, 4, 3, -1, -2, -3, -4, 5, 8, 7].enumerated().map { index, value in
        ChartEntry(
            value: Double(value),
            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
        )
    }

    ScrollView {
        VStack(spacing: 32) {
            VStack {
                Text("Chart 1")
                ChartView(
                    rawEntries: entries1
                )
            }
            .card()
            .frame(height: 200)

            VStack {
                Text("Chart 2")
                ChartView(
                    rawEntries: entries2
                )
            }
            .card()
            .frame(height: 200)

            VStack {
                Text("Chart 3")
                ChartView(
                    rawEntries: entries3
                )
            }
            .card()
            .frame(height: 200)

            VStack {
                Text("Chart 4")
                ChartView(rawEntries: [], placeholder: { ChartPlaceholderView().font(.callout).padding(.bottom)})
            }
            .card()
            .frame(height: 200)
        }
        .padding()
    }
}
