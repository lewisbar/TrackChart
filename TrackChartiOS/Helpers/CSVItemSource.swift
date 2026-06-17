//
//  CSVItemSource.swift
//  TrackChartiOS
//
//  Created by Lennart Wisbar on 25.10.25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

final class CSVItemSource: NSObject, UIActivityItemSource {
    private let content: String
    private let filename: String

    init(content: String, filename: String) {
        self.content = content
        self.filename = filename
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return filename
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // Write to a temporary file with the exact desired filename (including .csv).
        // This ensures "Save to Files", AirDrop, etc. receive a properly named file.
        // Using temporaryDirectory means the file is not a permanent user document
        // and will be cleaned up by the system.
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            // Rare (e.g. temp dir unwritable). Fall back to content string so data is not lost.
            // Filename is still advertised via placeholderItem and subject.
            return content
        }
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return filename
    }

    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return UTType.commaSeparatedText.identifier
    }
}
