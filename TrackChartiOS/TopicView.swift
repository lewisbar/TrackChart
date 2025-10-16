//
//  TopicView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI
import Presentation

struct TopicView: View {
    @Bindable var model: TopicViewModel

    var body: some View {
        TopicViewContent(name: $model.name, entries: $model.entries, unsubmittedValue: $model.unsubmittedValue)
    }
}

private struct TopicViewContent: View {
    @Binding var name: String
    @Binding var entries: [ViewEntry]
    @Binding var unsubmittedValue: Double

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            TextField("Enter topic name", text: $name)
                .font(.largeTitle)
                .fontWeight(.medium)
                .minimumScaleFactor(0.5)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .focused($isTextFieldFocused)

            ChartView(values: entries.map(\.value).map(Int.init))

            CounterView(
                count: $unsubmittedValue,
                submitNewValue: { entries.append(ViewEntry(value: Double($0), timestamp: Date())) },
                deleteLastValue: { if !entries.isEmpty { entries.removeLast() } }
            )
            .padding(.vertical)
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .topBarLeading, content: chevronOnlyBackButton) }
    }

    private func chevronOnlyBackButton() -> some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    @Previewable @State var name = "A Name"
    @Previewable @State var values = [5, 6, 8, 2, 4, 3, 5, 2].map { ViewEntry(value: $0, timestamp: Date()) }
    @Previewable @State var unsubmittedValue = 0.0

    TopicViewContent(name: $name, entries: $values, unsubmittedValue: $unsubmittedValue)
        .padding()
}
