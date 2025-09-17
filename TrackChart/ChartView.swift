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
    private let maxVisibleLength = 10
    private var visibleLength: Int { dataPoints.isEmpty ? 1 : max(0, min(totalPoints, maxVisibleLength)) }
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
            visibleLength: visibleLength,
            xPosition: $xPosition,
            homePosition: homePosition
        )
    }
}

private extension View {
    func applyScrollingBehavior(
        xLabels: [String],
        visibleLength: Int,
        xPosition: Binding<String>,
        homePosition: String
    ) -> some View {
        self.modifier(
            ScrollingBehaviorModifier(
                xLabels: xLabels,
                visibleLength: visibleLength,
                xPosition: xPosition,
                homePosition: homePosition
            )
        )
    }
}

private struct ScrollingBehaviorModifier: ViewModifier {
    let xLabels: [String]
    let visibleLength: Int
    @Binding var xPosition: String
    let homePosition: String

    func body(content: Content) -> some View {
        content
            .chartXScale(domain: xLabels.isEmpty ? [ChartView.fallbackValue] : xLabels)
            .chartXVisibleDomain(length: visibleLength)
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(x: $xPosition)
            .onAppear { xPosition = homePosition }
            .onChange(of: xLabels) { xPosition = homePosition }
    }
}

#Preview {
    ChartView(values: [0, 2, 1, 3, 4, 3, 5, 8, 7])
}
