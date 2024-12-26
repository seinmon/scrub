//
//  Spaces.swift
//  
//
//  Created by Hossein Monjezi on 17.08.24.
//

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
