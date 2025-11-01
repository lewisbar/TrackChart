//
//  PagedChartView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 31.10.25.
//

import SwiftUI
import Charts

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
                        .padding(.bottom, 44)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page)
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
            ZStack {
                Text(page.title)
                    .font(.caption).bold()

                Menu {
                    aggregatorButtons(for: span)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 8)

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
