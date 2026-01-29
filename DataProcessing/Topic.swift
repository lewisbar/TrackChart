//
//  Topic.swift
//  DataProcessing
//
//  Created by Lennart Wisbar on 29.01.26.
//

public struct Topic {
    public let entries: [Entry]
    
    public init(entries: [Entry]) {
        self.entries = entries
    }
    
    public var sum: Double {
        entries.map(\.value).reduce(0, +)
    }
    
    public var average: Double? {
        let count = Double(entries.count)
        return count > 0 ? sum / count : nil
    }
    
    public var highest: Double? {
        entries.map(\.value).max()
    }
    
    public var lowest: Double? {
        entries.map(\.value).min()
    }
}
