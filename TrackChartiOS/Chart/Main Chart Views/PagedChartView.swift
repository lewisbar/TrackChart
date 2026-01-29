//
//  PagedChartView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 31.10.25.
//

import SwiftUI
import Foundation
import Charts
import Presentation

struct PagedChartView<Placeholder: View>: View {
    @State private var selectedPage: String = ""

    private let pages: [ChartViewPage]
    private let aggregator: ViewAggregator
    private let palette: Palette
    private let placeholder: () -> Placeholder

    private let xLabel = String(localized: .date)
    private let yLabel = String(localized: .value)

    init(
        pages: [ChartViewPage],
        aggregator: ViewAggregator,
        palette: Palette,
        placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init
    ) {
        self.pages = pages
        self.aggregator = aggregator
        self.palette = palette
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if pages.isEmpty {
                placeholder()
            } else {
                pagedTabView
            }
        }
    }

    private var pagedTabView: some View {
        TabView(selection: $selectedPage) {
            ForEach(pages) { page in
                chart(for: page)
                    .tag(page.id)
            }
        }
        .tabViewStyle(.page)
        .onAppear {
            selectedPage = pages.last?.id ?? ""
        }
    }

    // MARK: – Chart

    @ViewBuilder
    private func chart(for page: ChartViewPage) -> some View {
        VStack {
            titleRow(for: page)
                .padding(.bottom)

            Chart(page.entries) { entry in
                areaMark(for: entry)
                lineMark(for: entry)
                PagedPointMarks(palette: palette, xLabel: xLabel, yLabel: yLabel)
                    .pointMark(for: entry, on: page)
            }
            .chartXScale(domain: page.dateRange)
            .chartXAxis(content: xAxisContent)
        }
        .padding()
        .padding(.bottom, 24)
        .padding(.horizontal, 4)
    }

    private func titleRow(for page: ChartViewPage) -> some View {
        HStack {
            Text(page.title)
                .font(.caption).bold()

            Spacer()

            Text(page.aggregator == .sum ? .pageTotal(page.aggregate.compactTwoDecimals) : .avg(page.aggregate.compactTwoDecimals))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func areaMark(for entry: ViewEntry) -> some ChartContent {
        AreaMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .foregroundStyle(areaGradient)
            .interpolationMethod(.catmullRom)
    }

    private func lineMark(for entry: ViewEntry) -> some ChartContent {
        LineMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .foregroundStyle(palette.primary)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .shadow(color: palette.shadow, radius: 2)
            .interpolationMethod(.catmullRom)
    }

    // MARK: – Styling
    
    private var areaGradient: LinearGradient {
        LinearGradient(stops: [
            .init(color: palette.top, location: 0),
            .init(color: palette.mid, location: 0.5),
            .init(color: palette.bottom, location: 1)
        ], startPoint: .top, endPoint: .bottom)
    }

    @AxisContentBuilder
    private func xAxisContent() -> some AxisContent {
            AxisMarks(
                // Align marks with the data points that belong to that day
                preset: .aligned,
                // One mark per day, starting at midnight
                values: .stride(by: .day)
            ) { mark in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))

                // `mark.as(Date.self)` is always the *start* of the day
                if let date = mark.as(Date.self) {
                    AxisValueLabel(
                        // Greedy = hide overlapping labels when the view is too narrow
                        collisionResolution: .greedy()
                    ) {
                        Text(date, format: .dateTime
                            .month(.abbreviated)
                            .day()
                        )
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .padding(.top, 4)
                    }
                }
        }
    }
}
