import Foundation

/// An object representing a PropertyList files in the file system.
protocol PropertyList where Self: Codable {

    /// Read the PropertyList file.
    ///
    /// - Parameters:
    ///   - url: The file `URL` of the PropertyList file to read.
    ///
    /// - Returns: An object representing the PropertyList file.
    static func read(from url: URL) throws -> Self

    /// Write the PropertyList file.
    ///
    /// - Parameters:
    ///   - url: The file `URL` of the PropertyList file to write.
    ///   - outputFormat: The format of the PropertyList file. Uses XML by default.
    func write(to url: URL, outputFormat: PropertyListSerialization.PropertyListFormat) throws
}

extension PropertyList {
    static func read(from url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode(Self.self, from: data)
    }

    func write(to url: URL,
               outputFormat: PropertyListSerialization.PropertyListFormat = .xml) throws {
        // Ensures the provided url exists.
        try FileSystem.shared.createDirectory(at: url.deletingLastPathComponent(),
                                              withIntermediateDirectories: true)
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(self)
        try data.write(to: url)
    }
}
