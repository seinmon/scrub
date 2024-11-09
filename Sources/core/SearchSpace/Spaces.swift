//
//  Spaces.swift
//  
//
//  Created by Hossein Monjezi on 17.08.24.
//

import Foundation

// This helps us change underlying structure of Spaces.
/// A representation of spaces file.
public struct Spaces: PropertyList, Sequence {
    let data: Set<URL>

    public func makeIterator() -> Set<URL>.Iterator {
        return data.makeIterator()
    }
}
