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
    private static let fallbackValue = "0"

    init(values: [Int]) {
        self.dataPoints = values.enumerated().map { index, value in DataPoint(value: value, name: "\(index)") }
    }

    var body: some View {
        Chart(dataPoints) { dataPoint in
            LineMark(x: .value("Data point", dataPoint.name), y: .value("Count", dataPoint.value))
            PointMark(x: .value("Data point", dataPoint.name), y: .value("Count", dataPoint.value))
        }
        .chartXScale(domain: dataPoints.isEmpty ? [Self.fallbackValue] : dataPoints.map { $0.name })
        .chartXVisibleDomain(length: visibleLength)
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: $xPosition)
        .onAppear { xPosition = homePosition }
        .onChange(of: dataPoints) { xPosition = homePosition }
    }
}

#Preview {
    ChartView(values: [0, 2, 1, 3, 4, 3, 5, 8, 7])
}
