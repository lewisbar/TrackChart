//
//  ChartView.swift
//  TrackChart
//
//  Created by LennartWisbar on 15.09.25.
//

import SwiftUI
import Charts

struct ChartView: View {
    private struct DataPoint: Identifiable {
        let id = UUID()
        let value: Int
        let name: String
    }

    private let dataPoints: [DataPoint]

    init(values: [Int]) {
        self.dataPoints = values.enumerated().map { index, value in DataPoint(value: value, name: "\(index)") }
    }

    var body: some View {
        Chart {
            ForEach(dataPoints) { dataPoint in
                LineMark(x: .value("Day", dataPoint.name), y: .value("Count", dataPoint.value))
            }
        }
    }
}

#Preview {
    ChartView(values: [0, 2, 1, 3, 4, 3, 5, 8, 7])
}
