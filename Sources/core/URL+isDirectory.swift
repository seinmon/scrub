//
//  URL+isDirectory.swift
//
//
//  Created by Hossein Monjezi on 25.07.24.
//

import Foundation

extension URL {

    /// Indicates whether or not the `URL` is a directory.
    ///
    /// Evaluates to `true` if the `URL` is a directory, otherwise `False`. It returns `nil` when the attributes relevant for
    /// evaluation do not exists.
    var isDirectory: Bool? {
        get throws {
            return try resourceValues(forKeys: [.isDirectoryKey]).isDirectory
        }
    }
}
