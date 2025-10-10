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
        let name: String
    }

    private let dataPoints: [DataPoint]

    @State private var xPosition = fallbackValue
    @State private var visibleLength = 10
    private let maxVisibleLength = 10
    private var homePosition: String { dataPoints.last?.name ?? Self.fallbackValue }
    private var totalPoints: Int { dataPoints.count }
    private let xLabel = "Data point"
    private let yLabel = "Count"
    fileprivate static let fallbackValue = "0"
    private let primaryColor = Color.blue

    init(values: [Int]) {
        self.dataPoints = values.enumerated().map { index, value in DataPoint(value: value, name: "\(index)") }
    }

    var body: some View {
        Chart(dataPoints) { dataPoint in
            AreaMark(x: .value(xLabel, dataPoint.name), y: .value(yLabel, dataPoint.value))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryColor.opacity(0.4), primaryColor.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            LineMark(x: .value(xLabel, dataPoint.name), y: .value(yLabel, dataPoint.value))
                .foregroundStyle(primaryColor)
                .lineStyle(StrokeStyle(lineWidth: 1))
            PointMark(x: .value(xLabel, dataPoint.name), y: .value(yLabel, dataPoint.value))
                .foregroundStyle(primaryColor)
                .symbolSize(20)
        }
        .applyScrollingBehavior(
            xLabels: dataPoints.map(\.name),
            visibleLength: $visibleLength,
            xPosition: $xPosition,
            homePosition: homePosition
        )
        .applyZoomingBehavior(visibleLength: $visibleLength, totalPoints: totalPoints)
    }
}

private extension View {
    func applyScrollingBehavior(
        xLabels: [String],
        visibleLength: Binding<Int>,
        xPosition: Binding<String>,
        homePosition: String
    ) -> some View {
        self.modifier(ScrollingBehaviorModifier(
            xLabels: xLabels,
            visibleLength: visibleLength,
            xPosition: xPosition,
            homePosition: homePosition
        ))
    }

    func applyZoomingBehavior(
        visibleLength: Binding<Int>,
        totalPoints: Int
    ) -> some View {
        self.modifier(ZoomingBehaviorModifier(
            visibleLength: visibleLength,
            totalPoints: totalPoints
        ))
    }
}

private struct ScrollingBehaviorModifier: ViewModifier {
    let xLabels: [String]
    @Binding var visibleLength: Int
    @Binding var xPosition: String
    let homePosition: String

    func body(content: Content) -> some View {
        content
            .chartXScale(domain: xLabels.isEmpty ? [ChartView.fallbackValue] : xLabels)
            .chartXVisibleDomain(length: max(visibleLength, 1))
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(x: $xPosition)
            .onAppear { xPosition = homePosition }
            .onChange(of: xLabels) { xPosition = homePosition }
    }
}

private struct ZoomingBehaviorModifier: ViewModifier {
    @Binding var visibleLength: Int
    let totalPoints: Int

    func body(content: Content) -> some View {
        content
            .highPriorityGesture(
                MagnificationGesture()
                    .onChanged { delta in
                        let sensitivity = 2.0
                        let step = 2.0 // Fixed step size for consistent changes
                        let adjustedDelta = delta > 0 ? pow(delta, 0.3) : 1.0 // Stronger dampening for large deltas
                        let change = (adjustedDelta - 1.0) * sensitivity * step
                        let newLength = max(5, min(totalPoints, Int(Double(visibleLength) - change.rounded())))
                        visibleLength = newLength
                    },
                including: .all
            )
//          .chartXAxis {
//                AxisMarks(values: stride(from: 0, to: totalPoints, by: max(1, visibleLength / 5)).map { String($0) }) { value in
//                    if let index = Int(value.as(String.self) ?? ChartView.fallbackValue) {
//                        AxisValueLabel("\(index)", anchor: .bottom)
//                        AxisGridLine()
//                        AxisTick()
//                    }
//                }
//            }
    }
}

#Preview {
    ChartView(values: [0, 2, 1, -2, 3, 4, 3, 5, 8, 7])
}
