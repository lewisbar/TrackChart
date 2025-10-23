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
    private struct Entry: Identifiable {
        let id = UUID()
        let value: Double
        let timestamp: Date

        init(from chartEntry: ChartEntry) {
            self.value = chartEntry.value
            self.timestamp = chartEntry.timestamp
        }
    }

    private let entries: [Entry]

    private let xLabel = "Date"
    private let yLabel = "Value"

    private let primaryColor = Color.blue
    private var topColor: Color { primaryColor.opacity(0.5) }
    private var midColor: Color { .cyan.opacity(0.3) }
    private var bottomColor: Color { .teal.opacity(0.1) }
    private var pointOutlineColor: Color { .cyan }
    private var pointFillColor: Color { .white }
    private let showPointMarks: Bool
    private let annotateExtrema: Bool
    private let showAxisLabels: Bool
    @ViewBuilder private let placeholder: () -> Placeholder

    /// Disabling `showPointMarks` also disables extrema annotation
    init(
        entries: [ChartEntry],
        showPointMarks: Bool = true,
        annotateExtrema: Bool = true,
        showAxisLabels: Bool = true,
        placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init
    ) {
        self.entries = entries.map(Entry.init)
        self.showPointMarks = showPointMarks
        self.annotateExtrema = annotateExtrema
        self.showAxisLabels = showAxisLabels
        self.placeholder = placeholder
    }

    var body: some View {
        if !entries.isEmpty {
            Chart(entries, content: chartContent)
                .chartXScale(domain: 1...entries.count)
                .chartXAxis(content: xAxisContent)
                .chartYAxis(content: yAxisContent)
        } else {
            placeholder()
        }
    }

    @ChartContentBuilder
    private func chartContent(for entry: Entry) -> some ChartContent {
        areaMark(for: entry)
        lineMark(for: entry)
        if showPointMarks || entries.count == 1 { pointMark(for: entry) }
    }

    private func areaMark(for entry: Entry) -> some ChartContent {
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

    private func lineMark(for entry: Entry) -> some ChartContent {
        LineMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .foregroundStyle(primaryColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .shadow(color: primaryColor.opacity(0.3), radius: 2)
            .interpolationMethod(.catmullRom)
    }

    private func pointMark(for entry: Entry) -> some ChartContent {
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
    private func maxPositiveValueAnnotation(for entry: Entry) -> some View {
        if annotateExtrema, isMaxPositiveValue(entry.value) {
            annotation(for: entry.value)
        }
    }

    @ViewBuilder
    private func minNegativeValueAnnotation(for entry: Entry) -> some View {
        if annotateExtrema, isMinNegativeValue(entry.value) {
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
        Text("\(value)")
            .font(.caption)
            .foregroundColor(pointOutlineColor)
    }

    @AxisContentBuilder
    private func xAxisContent() -> some AxisContent {
        if showAxisLabels {
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
        if showAxisLabels {
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

#Preview {
    let entries1 = [0, 2, 1, 2, 3, 4, 3, 5, 8, 7].enumerated().map { index, value in
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
                    entries: entries1
                )
            }
            .card()
            .frame(height: 200)

            VStack {
                Text("Chart 2")
                ChartView(
                    entries: entries2
                )
            }
            .card()
            .frame(height: 200)

            VStack {
                Text("Chart 3")
                ChartView(
                    entries: entries3
                )
            }
            .card()
            .frame(height: 200)

            VStack {
                Text("Chart 4")
                ChartView(entries: [], placeholder: { ChartPlaceholderView().font(.callout).padding(.bottom)})
            }
            .card()
            .frame(height: 200)
        }
        .padding()
    }
}
