import Foundation

// This enables us to change underlying structure of Spaces without breaking the functionality.
/// A plist representation of spaces file.
public struct Spaces: PropertyList, Sequence {

    /// Underlying spaces collection.
    let data: Set<URL>

    public func makeIterator() -> Set<URL>.Iterator {
        return data.makeIterator()
    }
}
