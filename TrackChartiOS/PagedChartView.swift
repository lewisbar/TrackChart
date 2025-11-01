//
//  PagedChartView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 31.10.25.
//

import SwiftUI
import Charts
import Presentation

struct PagedChartView: View {
    @State private var pages: [ChartPage]
    @State private var selectedAggregator: ChartDataProvider
    @State private var selectedPage = UUID()

    private let rawEntries: [ChartEntry]
    private let span: TimeSpan
    private let palette: Palette

    init(
        rawEntries: [ChartEntry],
        span: TimeSpan,
        defaultAggregator: ChartDataProvider,
        palette: Palette
    ) {
        self.rawEntries = rawEntries
        self.span = span
        self.palette = palette
        self._selectedAggregator = State(initialValue: defaultAggregator)
        self._pages = State(initialValue: ChartPageProvider.pages(
            for: rawEntries,
            span: span,
            aggregator: defaultAggregator
        ))
    }

    var body: some View {
        if pages.isEmpty {
            ChartPlaceholderView()
        } else {
            TabView(selection: $selectedPage) {
                ForEach(pages) { page in
                    chart(for: page)
                        .frame(height: 180)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .overlay(alignment: .topTrailing) {
                Menu {
                    aggregatorButtons(for: span)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .padding(8)
                }
                .padding()
            }
            .onAppear {
                selectedPage = pages.last?.id ?? UUID()
            }
            .onChange(of: pages) { _, newPages in
                selectedPage = newPages.last?.id ?? UUID()
            }
        }
    }

    // MARK: – Chart
    @ViewBuilder
    private func chart(for page: ChartPage) -> some View {
        VStack {
            Text(page.title)
                .font(.caption).bold()
                .padding(.bottom, 4)

            Chart(page.entries) { entry in
                AreaMark(x: .value("Date", entry.timestamp), y: .value("Value", entry.value))
                    .foregroundStyle(areaGradient)
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Date", entry.timestamp), y: .value("Value", entry.value))
                    .foregroundStyle(palette.primary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .shadow(color: palette.shadow, radius: 2)
                    .interpolationMethod(.catmullRom)
            }
            .chartXScale(domain: page.dateRange)
            .chartXAxis(content: xAxisContent)
        }
    }

    // MARK: – Aggregator Menu
    @ViewBuilder
    private func aggregatorButtons(for span: TimeSpan) -> some View {
        switch span {
        case .week, .month:
            Button("Daily Sum") { updateAggregator(.dailySum) }
            Button("Daily Average") { updateAggregator(.dailyAverage) }
        case .sixMonths:
            Button("Weekly Sum") { updateAggregator(.weeklySum) }
            Button("Weekly Average") { updateAggregator(.weeklyAverage) }
        case .oneYear:
            Button("Monthly Sum") { updateAggregator(.monthlySum) }
            Button("Monthly Average") { updateAggregator(.monthlyAverage) }
        }
    }

    private func updateAggregator(_ agg: ChartDataProvider) {
        selectedAggregator = agg
        pages = ChartPageProvider.pages(for: rawEntries, span: span, aggregator: agg)
    }

    // MARK: – Styling
    private var areaGradient: LinearGradient {
        LinearGradient(stops: [
            .init(color: palette.top, location: 0),
            .init(color: palette.mid, location: 0.5),
            .init(color: palette.bottom, location: 1)
        ], startPoint: .top, endPoint: .bottom)
    }

    private func xAxisContent() -> some AxisContent {
        AxisMarks(values: .stride(by: .day)) { _ in
            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
        }
    }

//    @AxisContentBuilder
//    private func xAxisContent() -> some AxisContent {
////        if showsAxisLabels {
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
////            }
//        }
//    }

    @AxisContentBuilder
    private func yAxisContent() -> some AxisContent {
//        if showsAxisLabels {
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
//        }
    }
}
