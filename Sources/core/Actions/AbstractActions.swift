//
//  AbstractActions.swift
//
//
//  Created by Hossein Monjezi on 11.08.24.
//

import Foundation

public protocol Action {
    func perform() throws
}

public class BasicAction: Action {
    let targetFile: String
    let searchSpace: SearchSpace
    let force: Bool

    public init(for targetFile: String, in searchSpace: SearchSpace, withForce force: Bool) {
        self.targetFile = targetFile
        self.searchSpace = searchSpace
        self.force = force
    }

    public func perform() throws {
        fatalError("Cannot perform an an abstract action.")
    }

    func getQuery(using target: String) throws -> Regex<Substring> {
        return try Regex("[A-Za-z0-9_.]*\(target)[A-Za-z0-9_.]*")
    }

    func locate(searchQuery: Regex<Substring>) throws -> Set<URL> {
        let fs = FileSystem()
        var locations = Set<URL>()

        for space in searchSpace {
            locations = locations.union(try fs.locate(searchQuery, in: space))
        }

        return locations
    }
}

public class DestructiveAction: BasicAction {
    func delete(_ file: URL, force: Bool) throws {
        if !force {
            while true {
                print("Delete \(file.path())? (Y/n)")

                if let response = readLine()?.first?.lowercased() {
                    if response == "y" {
                        break
                    } else if response == "n" {
                        print("Skipping \(file.path())")
                        return
                    } else {
                        print("Unrecognized input.")
                    }
                }
            }
        }

        try FileSystem().delete(file)
    }
}
