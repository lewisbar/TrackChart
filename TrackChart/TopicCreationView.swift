//
//  TopicCreationView.swift
//  TrackChart
//
//  Created by LennartWisbar on 19.09.25.
//

import SwiftUI

struct TopicCreationView: View {
    let createTopic: (String) -> Void
    @State private var topicName = "New Topic"
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack {
            TextField("Enter a name for your topic", text: $topicName)
                .focused($isTextFieldFocused)
            submitButton
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .presentationDetents([.fraction(0.2), .fraction(0.4), .medium, .fraction(0.7), .fraction(0.8), .large])
        .presentationCompactAdaptation(.none)
        .onAppear { isTextFieldFocused = true }
    }

    private var submitButton: some View {
        CircleButton(
            action: { createTopic(topicName) },
            image: Image(systemName: "checkmark"),
            color: .green
        )
    }
}

#Preview {
    TopicCreationView(createTopic: { _ in })
}
