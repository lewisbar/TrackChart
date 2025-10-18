//
//  Topic+Info.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 18.10.25.
//

import Foundation
import Presentation

extension Topic {
    var info: String {
        let infoPostfix = entryCount == 1 ? "entry" : "entries"
        return "\(entryCount) \(infoPostfix)"
    }
}
