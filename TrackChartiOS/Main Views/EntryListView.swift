//
//  EntryListView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 12.11.25.
//

import SwiftUI

struct ListEntry: Identifiable {
    let id = UUID()
    let value: Double
    let timestamp: Date
}

struct EntryListView: View {
    @Binding var entries: [ListEntry]
    let deleteEntries: (IndexSet) -> Void
    @State private var isShowingInput = false
    @State private var selectedEntry: ListEntry?

    var body: some View {
        List {
            ForEach(entries) { entry in
                entryCell(for: entry)
                    .onTapGesture {
                        selectedEntry = entry
                        isShowingInput = true
                    }
            }
            .onDelete(perform: deleteEntries)
            .contentShape(Rectangle())
        }
        .sheet(isPresented: $isShowingInput) {
            DecimalInputView(
                initialValue: selectedEntry?.value ?? 0,
                initialTimestamp: selectedEntry?.timestamp,
                submit: { _, _ in },
                dismiss: { isShowingInput = false },
                dismissesOnSubmit: true
            )
            .presentationDetents([.fraction(0.45)])
        }
    }

    private func entryCell(for entry: ListEntry) -> some View {
        HStack {
            Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Text(entry.value.formatted(.number))
        }
    }
}

#Preview {
    @Previewable @State var entries: [ListEntry] = [
        .init(value: 2.1, timestamp: .now.advanced(by: -800)),
        .init(value: 1, timestamp: .now.advanced(by: -700)),
        .init(value: -1, timestamp: .now.advanced(by: -600)),
        .init(value: -2.2, timestamp: .now.advanced(by: -500)),
        .init(value: -3.4, timestamp: .now.advanced(by: -400)),
        .init(value: 0, timestamp: .now.advanced(by: -300)),
        .init(value: 2, timestamp: .now.advanced(by: -200)),
        .init(value: 4, timestamp: .now.advanced(by: -100))
    ]

    EntryListView(entries: $entries, deleteEntries: { entries.remove(atOffsets: $0) })
}
