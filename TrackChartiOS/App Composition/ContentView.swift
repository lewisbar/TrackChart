//
//  ContentView.swift
//  TrackChart
//
//  Created by Lennart Wisbar on 15.09.25.
//

import SwiftUI

struct ContentView<MainView: View>: View {
    @ViewBuilder let mainView: () -> MainView

    var body: some View {
        mainView()
    }
}
