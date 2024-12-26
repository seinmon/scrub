//
//  Operation.swift
//
//
//  Created by Hossein Monjezi on 17.08.24.
//

import Foundation
import ArgumentParser

/// Supported operations by Scrub command-line tool.
public enum Operation: String, Codable, CaseIterable, ExpressibleByArgument {
    case uninstall = "uninstall"
    case list = "list"
    case clean = "clean"
}
