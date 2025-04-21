//
//  Searcher.swift
//
//
//  Created by Hossein Monjezi on 11.08.24.
//

import Foundation

/// Searches and lists locations related to a target.
final public class Searcher: BasicAction {
    override public func perform() throws {
        let locations = try locate(searchQuery: getQuery(using: targetFile))

        guard !locations.isEmpty else {
            print("No files found!")
            return
        }

        for file in locations {
            print(file.path())
        }
    }
}
