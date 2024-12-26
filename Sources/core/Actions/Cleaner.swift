//
//  Cleaner.swift
//  scrub
//
//  Created by Hossein Monjezi on 14.07.24.
//

import Foundation

/// Deletes files and directories.
final public class Cleaner: DestructiveAction {
    override public func perform() throws {
        let locations = try locate(searchQuery: getQuery(using: targetFile))

        if locations.isEmpty {
            print("Nothing to clean!")
        }

        for file in locations {
            try delete(file, force: force)
        }
    }
}
