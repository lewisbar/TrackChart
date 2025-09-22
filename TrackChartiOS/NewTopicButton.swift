//
//  NewTopicButton.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 20.09.25.
//

import SwiftUI

struct NewTopicButton: View {
    @ScaledMetric(relativeTo: .title2) var baseSize: CGFloat = 24

    var body: some View {
        NavigationLink(value: "create new topic") {
            Image(systemName: "plus")
                .foregroundStyle(.blue)
                .font(.title2)
                .frame(minWidth: baseSize, minHeight: baseSize)
                .padding(10)
                .background(Circle().fill(.white).shadow(radius: 2))
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom)
        }
    }
}

#Preview {
    NewTopicButton()
}
