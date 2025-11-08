//
//  PagedChartView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 31.10.25.
//

import SwiftUI
import Charts

struct PagedChartView<Placeholder: View>: View {
    @State private var pages: [ChartPage]
    @State private var selectedAggregator: ChartDataProvider
    @State private var selectedPage: String = ""

    private let rawEntries: [ChartEntry]
    private let span: TimeSpan
    private let palette: Palette
    private let placeholder: () -> Placeholder

    private let xLabel = "Date"
    private let yLabel = "Value"

    init(
        rawEntries: [ChartEntry],
        span: TimeSpan,
        defaultAggregator: ChartDataProvider,
        palette: Palette,
        placeholder: @escaping () -> Placeholder = ChartPlaceholderView.init
    ) {
        self.rawEntries = rawEntries
        self.span = span
        self.palette = palette
        self.placeholder = placeholder
        self._selectedAggregator = State(initialValue: defaultAggregator)
        self._pages = State(initialValue: ChartPageProvider.pages(
            for: rawEntries,
            span: span,
            aggregator: defaultAggregator
        ))
    }

    var body: some View {
        Group {
            if pages.isEmpty {
                placeholder()
            } else {
                TabView(selection: $selectedPage) {
                    ForEach(pages) { page in
                        chart(for: page)
                            .padding(.bottom, 24)
                            .padding(.horizontal, 4)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page)
                .onAppear {
                    selectedPage = pages.last?.id ?? ""
                }
            }
        }
        .onChange(of: rawEntries.count) { _, _ in  // might have to be changed to rawEntries once entries can be edited
            updatePages()
            selectedPage = pages.last?.id ?? ""
        }
        .onChange(of: selectedAggregator) { _, _ in
            updatePages()
            selectedPage = pages.last?.id ?? ""
        }
    }

    private func updatePages() {
        pages = ChartPageProvider.pages(
            for: rawEntries,
            span: span,
            aggregator: selectedAggregator
        )
    }

    // MARK: – Chart

    @ViewBuilder
    private func chart(for page: ChartPage) -> some View {
        VStack {
            ZStack {
                Text(page.title)
                    .font(.caption).bold()

                aggregatorMenu
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 8)

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
    }

    private var aggregatorMenu: some View {
        Menu {
            Picker("Select an aggregator type", selection: $selectedAggregator) {
                ForEach(span.availableDataProviders, id: \.self) {
                    Text($0.name)
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
        }
    }

    private func areaMark(for entry: ProcessedEntry) -> some ChartContent {
        AreaMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .foregroundStyle(areaGradient)
            .interpolationMethod(.catmullRom)
    }

    private func lineMark(for entry: ProcessedEntry) -> some ChartContent {
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

#Preview {
    let entries: [ChartEntry] = [
        .init(value: 2.3, timestamp: .now.advanced(by: -86_400 * 16)),
        .init(value: -2.3, timestamp: .now.advanced(by: -86_400 * 15)),
        .init(value: 2.5, timestamp: .now.advanced(by: -86_400 * 14)),
        .init(value: 1.3, timestamp: .now.advanced(by: -86_400 * 13)),
        .init(value: 0, timestamp: .now.advanced(by: -86_400 * 12)),
        .init(value: -1, timestamp: .now.advanced(by: -86_400 * 11)),
        .init(value: 2, timestamp: .now.advanced(by: -86_400 * 10)),
        .init(value: 1, timestamp: .now.advanced(by: -86_400 * 9)),
        .init(value: 2.3, timestamp: .now.advanced(by: -86_400 * 8)),
        .init(value: -2.3, timestamp: .now.advanced(by: -86_400 * 7)),
        .init(value: 2.5, timestamp: .now.advanced(by: -86_400 * 6)),
        .init(value: 1.3, timestamp: .now.advanced(by: -86_400 * 5)),
        .init(value: 0, timestamp: .now.advanced(by: -86_400 * 4)),
        .init(value: -1, timestamp: .now.advanced(by: -86_400 * 3)),
        .init(value: 0, timestamp: .now.advanced(by: -86_400 * 2)),
        .init(value: 2, timestamp: .now.advanced(by: -86_400 * 1.8)),
        .init(value: 4, timestamp: .now.advanced(by: -86_400 * 1.4)),
        .init(value: 1, timestamp: .now.advanced(by: -86_400 * 1)),
        .init(value: -1, timestamp: .now.advanced(by: -86_400 * 0.9)),
        .init(value: 3, timestamp: .now.advanced(by: -86_400 * 0.4))
    ]

    ScrollView {
        VStack {
            PagedChartView(rawEntries: entries, span: .week, defaultAggregator: .dailySum, palette: .arcticIce).card().frame(height: 250)
            PagedChartView(rawEntries: entries, span: .month, defaultAggregator: .dailySum, palette: .aurora).card().frame(height: 250)
            PagedChartView(rawEntries: entries, span: .sixMonths, defaultAggregator: .weeklySum, palette: .coralReef).card().frame(height: 250)
            PagedChartView(rawEntries: entries, span: .oneYear, defaultAggregator: .monthlySum, palette: .desertDune).card().frame(height: 250)
            PagedChartView(rawEntries: entries, span: .week, defaultAggregator: .dailyAverage, palette: .fire).card().frame(height: 250)
            PagedChartView(rawEntries: entries, span: .month, defaultAggregator: .dailyAverage, palette: .fire).card().frame(height: 250)
            PagedChartView(rawEntries: entries, span: .sixMonths, defaultAggregator: .weeklyAverage, palette: .lavenderField).card().frame(height: 250)
            PagedChartView(rawEntries: entries, span: .oneYear, defaultAggregator: .monthlyAverage, palette: .meadow).card().frame(height: 250)
        }
        .padding()
    }
}
