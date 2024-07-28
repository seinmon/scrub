//
//  PropertyList.swift
//
//
//  Created by Hossein Monjezi on 24.07.24.
//

import Foundation

/// Handles read and write operations to PropertyList files.
struct PropertyList {

    /// Singleton instance to handle PropertyLists.
    static let handler = PropertyList()

    private init() { }

    /// Read from a PropertyList file.
    ///
    /// - Parameters:
    ///   - type: The data type to read from the PropertyList file.
    ///   - url: The file `URL` of the PropertyList file to read.
    ///
    /// - Returns: An object representing the PropertyList file.
    func read<T>(_ type: T.Type, from url: URL) throws -> T where T: Decodable {
        let data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode(type, from: data)
    }

    /// Write to a PropertyList file.
    ///
    /// - Parameters:
    ///   - value: The value to write to PropertyList file.
    ///   - url: The file `URL` of the PropertyList file to write.
    ///   - outputFormat: The format of the PropertyList file. Uses XML by default.
    func write<T>(_ value: T,
                  to url: URL,
                  outputFormat: PropertyListSerialization.PropertyListFormat = .xml
    ) throws where T: Encodable {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(value)
        try data.write(to: url)
    }
}
