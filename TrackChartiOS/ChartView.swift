//
//  ChartView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Charts
import Presentation

enum ChartMode {
    case paged(TimeSpan, defaultAggregator: ChartDataProvider)
    case preview
    case overview
}

struct ChartView: View {
    let rawEntries: [ChartEntry]
    let palette: Palette
    let mode: ChartMode

    var body: some View {
        switch mode {
        case .paged(let span, let agg):
            PagedChartView(rawEntries: rawEntries, span: span, defaultAggregator: agg, palette: palette)
        case .preview:
            PreviewChartView(rawEntries: rawEntries, palette: palette)
        case .overview:
            OverviewChartView(rawEntries: rawEntries, palette: palette)
        }
    }
}

//struct ChartView<Placeholder: View>: View {
//    private let pages: [ChartPage]
//    private let palette: Palette
//    private let highlightsExtrema: Bool
//    private let showsAxisLabels: Bool
//    @ViewBuilder private let placeholder: () -> Placeholder
//
//    private let xLabel = "Date"
//    private let yLabel = "Value"
//
//    init(
//        rawEntries: [ChartEntry],
//        palette: Palette,
//        highlightsExtrema: Bool = true,
//        showsAxisLabels: Bool = true,
//        placeholder: @escaping () -> Placeholder = { ChartPlaceholderView() }
//    ) {
//        self.pages = TimeSpanPager.pages(for: rawEntries)
//        self.palette = palette
//        self.highlightsExtrema = highlightsExtrema
//        self.showsAxisLabels = showsAxisLabels
//        self.placeholder = placeholder
//    }
//
//    var body: some View {
//        if pages.isEmpty {
//            placeholder()
//        } else {
//            TabView {
//                ForEach(pages) { page in
////                    VStack {
////                        Text(page.span.title)
////                            .font(.caption).bold()
////                            .padding(.bottom, 4)
//
//                        chart(for: page)
////                    }
////                    .padding()
//                }
//            }
//            .tabViewStyle(.page)
////            .indexViewStyle(.page(backgroundDisplayMode: .automatic))
//        }
//    }
//
//    private func chart(for page: ChartPage) -> some View {
//        Chart(page.entries) { entry in
//            chartContent(for: entry, on: page)
//        }
//        .chartXScale(domain: page.dateRange)
//        .chartXAxis(content: xAxisContent)
//        .chartYAxis(content: yAxisContent)
////        .frame(height: 160)
//    }
//
//    @ChartContentBuilder
//    private func chartContent(for entry: ProcessedEntry, on page: ChartPage) -> some ChartContent {
//        areaMark(for: entry)
//        lineMark(for: entry)
//        if shouldShowPointMark(for: entry, on: page) { pointMark(for: entry, on: page) }
//    }
//
//    private func areaMark(for entry: ProcessedEntry) -> some ChartContent {
//        AreaMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
//            .foregroundStyle(areaGradient)
//            .interpolationMethod(.catmullRom)
//    }
//
//    private var areaGradient: some ShapeStyle {
//        LinearGradient(
//            stops: [
//                .init(color: palette.top, location: 0.0),
//                .init(color: palette.mid, location: 0.5),
//                .init(color: palette.bottom, location: 1.0)
//            ],
//            startPoint: .top,
//            endPoint: .bottom
//        )
//    }
//
//    private func lineMark(for entry: ProcessedEntry) -> some ChartContent {
//        LineMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
//            .foregroundStyle(palette.primary)
//            .lineStyle(StrokeStyle(lineWidth: 2))
//            .shadow(color: palette.shadow, radius: 2)
//            .interpolationMethod(.catmullRom)
//    }
//
//    private func shouldShowPointMark(for entry: ProcessedEntry, on page: ChartPage) -> Bool {
//        page.entries.count == 1 || (highlightsExtrema && page.isExtremum(entry))
//    }
//
//    private func pointMark(for entry: ProcessedEntry, on page: ChartPage) -> some ChartContent {
//        PointMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
//            .symbol(symbol: pointSymbol)
//            .annotation(position: .top, spacing: 2) { maxPositiveValueAnnotation(for: entry, on: page) }
//            .annotation(position: .bottom, spacing: 2) { minNegativeValueAnnotation(for: entry, on: page) }
//    }
//
//    private func pointSymbol() -> some View {
//        ZStack {
//            Circle().fill(palette.pointFill)
//            Circle().stroke(palette.pointOutline, lineWidth: 2)
//        }
//        .frame(width: 6)
//    }
//
//    @ViewBuilder
//    private func maxPositiveValueAnnotation(for entry: ProcessedEntry, on page: ChartPage) -> some View {
//        if highlightsExtrema, page.isMaxPositiveEntry(entry) {
//            annotation(for: entry.value)
//        }
//    }
//
//    @ViewBuilder
//    private func minNegativeValueAnnotation(for entry: ProcessedEntry, on page: ChartPage) -> some View {
//        if highlightsExtrema, page.isMinNegativeEntry(entry) {
//            annotation(for: entry.value)
//        }
//    }
//
//    private func annotation(for value: Double) -> some View {
//        let formattedValue = ChartNumberFormatter.extremaAnnotation.string(from: NSNumber(value: value)) ?? "\(value)"
//
//        return Text("\(formattedValue)")
//            .font(.caption)
//            .foregroundColor(palette.pointOutline)
//    }
//
//    @AxisContentBuilder
//    private func xAxisContent() -> some AxisContent {
//        if showsAxisLabels {
//            AxisMarks(
//                // Align marks with the data points that belong to that day
//                preset: .aligned,
//                // One mark per day, starting at midnight
//                values: .stride(by: .day)
//            ) { mark in
//                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
//
//                // `mark.as(Date.self)` is always the *start* of the day
//                if let date = mark.as(Date.self) {
//                    AxisValueLabel(
//                        // Greedy = hide overlapping labels when the view is too narrow
//                        collisionResolution: .greedy()
//                    ) {
//                        Text(date, format: .dateTime
//                            .month(.abbreviated)
//                            .day()
//                        )
//                        .font(.caption2)
//                        .foregroundStyle(.gray)
//                        .padding(.top, 4)
//                    }
//                }
//            }
//        }
//    }
//
//    @AxisContentBuilder
//    private func yAxisContent() -> some AxisContent {
//        if showsAxisLabels {
//            AxisMarks(values: .automatic(desiredCount: 2, roundLowerBound: false, roundUpperBound: false)) { value in
//                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
//
//                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
//
//                AxisValueLabel()
//                    .foregroundStyle(.gray)
//                    .font(.caption)
//
//                if value.as(Int.self) == 0 {
//                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: []))
//                        .foregroundStyle(.black.opacity(0.5)) // Highlight y=0
//                }
//            }
//        }
//    }
//}
//
//private enum ChartNumberFormatter {
//    static let extremaAnnotation: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = 2
//        return formatter
//    }()
//}

//#Preview {
//    let entries1 = [0, 2, 1, 2, 3, 4, 3, 5, 8.437, 7].enumerated().map { index, value in
//        ChartEntry(
//            value: Double(value),
//            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
//        )
//    }
//
//    let entries2 = [0, -2, -1, -2, -3, -4, -3, -5, -8, -7].enumerated().map { index, value in
//        ChartEntry(
//            value: Double(value),
//            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
//        )
//    }
//
//    let entries3 = [0, 2, 1, 2, 3, 4, 3, -1, -2, -3, -4, 5, 8, 7, 2, 1, 2, 3, 4, 3, -1, -2, -3, -4, 5, 8, 7].enumerated().map { index, value in
//        ChartEntry(
//            value: Double(value),
//            timestamp: .now.advanced(by: 86_400 * Double(index) - 40 * 86_400)
//        )
//    }
//
//    ScrollView {
//        VStack(spacing: 32) {
//            VStack {
//                Text("Chart 1")
//                ChartView(
//                    rawEntries: entries1, palette: .ocean
//                )
//            }
//            .card()
//            .frame(height: 200)
//
//            VStack {
//                Text("Chart 2")
//                ChartView(
//                    rawEntries: entries2, palette: .fire
//                )
//            }
//            .card()
//            .frame(height: 200)
//
//            VStack {
//                Text("Chart 3")
//                ChartView(
//                    rawEntries: entries3, palette: .forest
//                )
//            }
//            .card()
//            .frame(height: 200)
//
//            VStack {
//                Text("Chart 4")
//                ChartView(rawEntries: [], palette: .sunset, placeholder: { ChartPlaceholderView().font(.callout).padding(.bottom)})
//            }
//            .card()
//            .frame(height: 200)
//        }
//        .padding()
//    }
//}
