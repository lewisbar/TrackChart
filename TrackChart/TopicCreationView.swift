//
//  TopicCreationView.swift
//  TrackChart
//
//  Created by LennartWisbar on 19.09.25.
//

import SwiftUI

struct TopicCreationView: View {
    let createTopic: (String) -> Void
    @State private var topicName = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack {
            TextField("Enter a name for your topic", text: $topicName).focused($isTextFieldFocused)
            submitButton
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
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
