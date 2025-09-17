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

    init(values: [Int]) {
        self.dataPoints = values.enumerated().map { index, value in DataPoint(value: value, name: "\(index)") }
    }

    var body: some View {
        Chart(dataPoints) { dataPoint in
            LineMark(x: .value(xLabel, dataPoint.name), y: .value(yLabel, dataPoint.value))
            PointMark(x: .value(xLabel, dataPoint.name), y: .value(yLabel, dataPoint.value))
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
            .gesture(MagnificationGesture()
                .onChanged { delta in
                    let newLength = max(5, min(totalPoints, Int(Double(visibleLength) / delta)))
                    visibleLength = newLength
                })
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
    ChartView(values: [0, 2, 1, 3, 4, 3, 5, 8, 7])
}
