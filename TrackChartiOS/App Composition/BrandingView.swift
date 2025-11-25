//
//  BrandingView.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.11.25.
//

import SwiftUI

struct BrandingView: View {
    var body: some View {
        HStack {
            if let icon = Bundle.main.appIcon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            }

            Text(.trackChart)
                .font(.title3)
                .fontDesign(.monospaced)
        }
        .padding(.leading)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(.trackChartLogo)
    }
}

#Preview {
    BrandingView()
}
