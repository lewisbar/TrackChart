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

    private let xLabel = "Date"
    private let yLabel = "Value"

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
            .onChange(of: selectedAggregator) { _, newAggregator in
                pages = ChartPageProvider.pages(for: rawEntries, span: span, aggregator: newAggregator)
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
                    Picker("Select an aggregator type", selection: $selectedAggregator) {
                        ForEach(span.availableDataProviders, id: \.self) {
                            Text($0.name)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 8)

            Chart(page.entries) { entry in
                AreaMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                    .foregroundStyle(areaGradient)
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
                    .foregroundStyle(palette.primary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .shadow(color: palette.shadow, radius: 2)
                    .interpolationMethod(.catmullRom)
                if shouldShowPointMark(for: entry, on: page) { pointMark(for: entry, on: page) }
            }
            .chartXScale(domain: page.dateRange)
            .chartXAxis(content: xAxisContent)
        }
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

    // MARK: - Point Marks and Annotations

    private func shouldShowPointMark(for entry: ProcessedEntry, on page: ChartPage) -> Bool {
        page.entries.count == 1 || page.isExtremum(entry)
    }

    private func pointMark(for entry: ProcessedEntry, on page: ChartPage) -> some ChartContent {
        PointMark(x: .value(xLabel, entry.timestamp), y: .value(yLabel, entry.value))
            .symbol(symbol: pointSymbol)
            .annotation(position: .top, spacing: 2) { maxPositiveValueAnnotation(for: entry, on: page) }
            .annotation(position: .bottom, spacing: 2) { minNegativeValueAnnotation(for: entry, on: page) }
    }

    private func pointSymbol() -> some View {
        ZStack {
            Circle().fill(palette.pointFill)
            Circle().stroke(palette.pointOutline, lineWidth: 2)
        }
        .frame(width: 6)
    }

    @ViewBuilder
    private func maxPositiveValueAnnotation(for entry: ProcessedEntry, on page: ChartPage) -> some View {
        if page.isMaxPositiveEntry(entry) {
            annotation(for: entry.value)
        }
    }

    @ViewBuilder
    private func minNegativeValueAnnotation(for entry: ProcessedEntry, on page: ChartPage) -> some View {
        if page.isMinNegativeEntry(entry) {
            annotation(for: entry.value)
        }
    }

    private func annotation(for value: Double) -> some View {
        let formattedValue = ChartNumberFormatter.extremaAnnotation.string(from: NSNumber(value: value)) ?? "\(value)"

        return Text("\(formattedValue)")
            .font(.caption)
            .foregroundColor(palette.pointOutline)
    }
}

private enum ChartNumberFormatter {
    static let extremaAnnotation: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
