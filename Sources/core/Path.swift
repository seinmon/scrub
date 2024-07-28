//
//  Path.swift
//  
//
//  Created by Hossein Monjezi on 27.07.24.
//

import Foundation

/// A enum representing paths.
protocol Path: CaseIterable, RawRepresentable where Self.RawValue: StringProtocol {

    /// The `URL` of the paths.
    var url: URL { get }
}
