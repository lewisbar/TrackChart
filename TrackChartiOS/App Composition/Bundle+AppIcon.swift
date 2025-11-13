//
//  Bundle+AppIcon.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 13.11.25.
//

import Foundation
import UIKit

extension Bundle {
    var appIcon: UIImage? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return nil
        }

        let imageName = lastIcon
        return UIImage(named: imageName)
    }
}
