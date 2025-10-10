//
//  ChartView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI
import Charts

struct ChartView: View {
    private struct DataPoint: Identifiable, Equatable {
        let id = UUID()
        let value: Int
        let label: Int
    }

    private let dataPoints: [DataPoint]

    @State private var xPosition = fallbackValue
    @State private var visibleLength = 10
    private let maxVisibleLength = 10
    private var homePosition: Int { dataPoints.last?.label ?? Self.fallbackValue }
    private var totalPoints: Int { dataPoints.count }
    private let xLabel = "Data point"
    private let yLabel = "Count"
    fileprivate static let fallbackValue = 1

    private let primaryColor = Color.blue
    private var topColor: Color { primaryColor.opacity(0.5) }
    private var midColor: Color { .cyan.opacity(0.3) }
    private var bottomColor: Color { .teal.opacity(0.1) }
    private var pointOutlineColor: Color { .cyan }
    private var pointFillColor: Color { .white }
    private let showPointMarks = false
    private let annotateExtrema = false

    init(values: [Int]) {
        self.dataPoints = values.enumerated().map { index, value in DataPoint(value: value, label: index + 1) }
    }

    var body: some View {
        Chart(dataPoints, content: chartContent)
            .chartXScale(domain: 1...dataPoints.count)
            .chartXAxis(content: xAxisContent)
            .chartYAxis(content: yAxisContent)
    }

    @ChartContentBuilder
    private func chartContent(for dataPoint: DataPoint) -> some ChartContent {
        areaMark(for: dataPoint)
        lineMark(for: dataPoint)
        if showPointMarks { pointMark(for: dataPoint) }
    }

    private func areaMark(for dataPoint: DataPoint) -> some ChartContent {
        AreaMark(x: .value(xLabel, dataPoint.label), y: .value(yLabel, dataPoint.value))
            .foregroundStyle(
                LinearGradient(
                    stops: [
                        .init(color: topColor, location: 0.0),
                        .init(color: midColor, location: 0.5),
                        .init(color: bottomColor, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
    }

    private func lineMark(for dataPoint: DataPoint) -> some ChartContent {
        LineMark(x: .value(xLabel, dataPoint.label), y: .value(yLabel, dataPoint.value))
            .foregroundStyle(primaryColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .shadow(color: primaryColor.opacity(0.3), radius: 2)
            .interpolationMethod(.catmullRom)
    }

    private func pointMark(for dataPoint: DataPoint) -> some ChartContent {
        PointMark(x: .value(xLabel, dataPoint.label), y: .value(yLabel, dataPoint.value))
            .foregroundStyle(pointFillColor)
            .symbol {
                ZStack {
                    Circle()
                        .fill(pointFillColor)
                    Circle()
                        .stroke(pointOutlineColor, lineWidth: 2)
                }
                .frame(width: 6)
            }
            .annotation(position: .top, spacing: 5) { maxPositiveValueAnnotation(for: dataPoint) }
            .annotation(position: .bottom, spacing: 5) { minNegativeValueAnnotation(for: dataPoint) }
    }

    @ViewBuilder
    private func maxPositiveValueAnnotation(for dataPoint: DataPoint) -> some View {
        if annotateExtrema, isMaxPositiveValue(dataPoint.value) {
            annotation(for: dataPoint.value)
        }
    }

    @ViewBuilder
    private func minNegativeValueAnnotation(for dataPoint: DataPoint) -> some View {
        if annotateExtrema, isMinNegativeValue(dataPoint.value) {
            annotation(for: dataPoint.value)
        }
    }

    private func isMaxPositiveValue(_ value: Int) -> Bool {
        value > 0 && value == dataPoints.map(\.value).max()
    }

    private func isMinNegativeValue(_ value: Int) -> Bool {
        value < 0 && value == dataPoints.map(\.value).min()
    }

    private func annotation(for value: Int) -> some View {
        Text("\(value)")
            .font(.caption)
            .foregroundColor(primaryColor)
            .padding(4)
            .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 4))
    }

    private func xAxisContent() -> some AxisContent {
        AxisMarks(preset: .aligned, values: .automatic(desiredCount: 4, roundLowerBound: false, roundUpperBound: false)) {
            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
            AxisValueLabel()
                .foregroundStyle(.gray)
                .font(.caption)
        }
    }

    private func yAxisContent() -> some AxisContent {
        AxisMarks(values: .automatic(desiredCount: 2)) { value in
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

#Preview {
    VStack(spacing: 32) {
        VStack {
            Text("Chart 1")
            ChartView(values: [0, 2, 1, 2, 3, 4, 3, 5, 8, 7])
        }
        .card()

        VStack {
            Text("Chart 2")
            ChartView(values: [0, -2, -1, -2, -3, -4, -3, -5, -8, -7])
        }
        .card()

        VStack {
            Text("Chart 2")
            ChartView(values: [0, 2, 1, 2, 3, 4, 3, -1, -2, -3, -4, 5, 8, 7, 2, 1, 2, 3, 4, 3, -1, -2, -3, -4, 5, 8, 7])
        }
        .card()
    }
    .padding()
}
