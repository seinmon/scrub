import Foundation
import ArgumentParser

/// Supported operations by Scrub command-line tool.
public enum Operation: String, Codable, CaseIterable, ExpressibleByArgument {
    case uninstall = "uninstall"
    case list = "list"
    case clean = "clean"
}
