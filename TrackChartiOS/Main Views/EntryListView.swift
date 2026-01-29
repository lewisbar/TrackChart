//
//  EntryListView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 12.11.25.
//

import SwiftUI
import Presentation

struct EntryListView: View {
    let topicName: String
    let addEntry: (ViewEntry) -> Void
    let updateEntry: (ViewEntry) -> Void
    let deleteEntries: (IndexSet) -> Void
    let entries: [ViewEntry]
    @State private var isShowingInput = false
    @State private var selectedEntry: ViewEntry?
    @Environment(\.dismiss) private var dismiss

    init(
        topicName: String,
        addEntry: @escaping (ViewEntry) -> Void,
        entries: [ViewEntry],
        updateEntry: @escaping (ViewEntry) -> Void,
        deleteEntries: @escaping (IndexSet) -> Void
    ) {
        self.topicName = topicName
        self.addEntry = addEntry
        self.entries = entries
        self.updateEntry = updateEntry
        self.deleteEntries = deleteEntries
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                explanationView
                list
            }
            plusButton
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(topicName)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: chevronOnlyBackButton)
        }
        .onChange(of: selectedEntry) { _, newValue in
            guard newValue != nil else { return }
            showNumpad()
        }
        .sheet(isPresented: $isShowingInput) {
            inputView(for: selectedEntry)
        }
    }

    private var explanationView: some View {
        Text(.tapToEditSwipeLeftToDelete)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var list: some View {
        List {
            ForEach(entries) { entry in
                entryCell(for: entry)
            }
            .onDelete(perform: deleteEntries)
            .contentShape(Rectangle())
        }
        .safeAreaInset(edge: .bottom) {
            // Make room for the plus button
            Color.clear.frame(height: 36)
        }
    }

    private func entryCell(for entry: ViewEntry) -> some View {
        Button {
            selectedEntry = entry
        } label: {
            HStack {
                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.value.compactTwoDecimals)
            }
            .contentShape(Rectangle())
        }
        .tint(.primary)
        .accessibilityHint(.tapToEditEntry)
    }

    private func chevronOnlyBackButton() -> some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
        }
        .tint(.secondary)
    }

    private func inputView(for entry: ViewEntry?) -> some View {
        DecimalInputView(
            initialValue: entry?.value ?? 0,
            initialTimestamp: entry?.timestamp,
            submit: { value, timestamp in submitEntry(withID: entry?.id ?? UUID(), value: value, timestamp: timestamp) },
            dismiss: dismissNumpad,
            dismissesOnSubmit: entry != nil
        )
    }

    private func submitEntry(withID id: UUID, value: Double, timestamp: Date) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            updateEntry(atIndex: index, id: id, value: value, timestamp: timestamp)
        } else {
            addEntry(withID: id, value: value, timestamp: timestamp)
        }
    }

    private func updateEntry(atIndex index: Int, id: UUID, value: Double, timestamp: Date) {
        let updatedEntry = ViewEntry(id: id, value: value, timestamp: timestamp)
        withAnimation {
            updateEntry(updatedEntry)
        }
    }

    private func addEntry(withID id: UUID, value: Double, timestamp: Date) {
        let newEntry = ViewEntry(id: id, value: value, timestamp: timestamp)
        withAnimation {
            addEntry(newEntry)
        }
    }

    private var plusButton: some View {
        VStack {
            Spacer()
            CircleButton(action: showNumpad, image: Image(systemName: "plus"), color: .blue)
                .padding(.bottom)
        }
        .accessibilityHint(.addANewEntry)
    }

    private func showNumpad() {
        isShowingInput = true
    }

    private func dismissNumpad() {
        selectedEntry = nil
        isShowingInput = false
    }
}

#Preview {
    @Previewable @State var entries: [ViewEntry] = [
        .init(id: UUID(), value: 2.1, timestamp: .now.advanced(by: -800)),
        .init(id: UUID(), value: 1, timestamp: .now.advanced(by: -700)),
        .init(id: UUID(), value: -1, timestamp: .now.advanced(by: -600)),
        .init(id: UUID(), value: -2.2, timestamp: .now.advanced(by: -500)),
        .init(id: UUID(), value: -3.4, timestamp: .now.advanced(by: -400)),
        .init(id: UUID(), value: 0, timestamp: .now.advanced(by: -300)),
        .init(id: UUID(), value: 2, timestamp: .now.advanced(by: -200)),
        .init(id: UUID(), value: 4, timestamp: .now.advanced(by: -100))
    ]

    EntryListView(
        topicName: "Topic 1",
        addEntry: { entries.append($0) },
        entries: entries,
        updateEntry: { updatedEntry in
            guard let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) else { return }
            entries[index] = updatedEntry
        },
        deleteEntries: { entries.remove(atOffsets: $0) })
}
