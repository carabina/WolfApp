//
//  ResourceUtils.swift
//  WolfApp
//
//  Created by Wolf McNally on 6/25/17.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import WolfPipe
import ExtensibleEnumeratedName
import WolfFoundation
import WolfOSBridge

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public func loadData(named name: String, withExtension anExtension: String? = nil, subdirectory subpath: String? = nil, in bundle: Bundle? = nil) throws -> Data {
    let url = try (bundle ?? Bundle.main) |> Bundle.urlForResource(name, withExtension: anExtension, subdirectory: subpath)
    return try Data(contentsOf: url)
}

public struct ResourceReference: ExtensibleEnumeratedName, Reference {
    public let rawValue: String
    public let type: String?
    public let bundle: Bundle

    public init(_ rawValue: String, ofType type: String? = nil, in bundle: Bundle? = nil) {
        self.rawValue = rawValue
        self.type = type
        self.bundle = bundle ?? Bundle.main
    }

    // RawRepresentable
    public init?(rawValue: String) { self.init(rawValue) }

    // Reference
    public var referent: URL {
        return URL(fileURLWithPath: bundle.path(forResource: rawValue, ofType: type)!)
    }
}

public postfix func ® (lhs: ResourceReference) -> URL {
    return lhs.referent
}

#if !os(Linux)

public func loadStoryboard(named name: String, in bundle: Bundle? = nil) -> OSStoryboard {
    let bundle = bundle ?? Bundle.main
    #if os(macOS)
        return NSStoryboard(name: name, bundle: bundle)
    #else
        return UIStoryboard(name: name, bundle: bundle)
    #endif
}

public func loadNib(named name: String, in bundle: Bundle? = nil) -> OSNib {
    let bundle = bundle ?? Bundle.main
    #if os(macOS)
        return NSNib(nibNamed: name, bundle: bundle)!
    #else
        return UINib(nibName: name, bundle: bundle)
    #endif
}

public func loadView<T: OSView>(fromNibNamed name: String, in bundle: Bundle? = nil, owner: AnyObject? = nil) -> T {
    let nib = loadNib(named: name, in: bundle)
    #if os(macOS)
        var objs: NSArray? = nil
        nib.instantiate(withOwner: owner, topLevelObjects: &objs)
        return objs![0] as! T
    #else
        return nib.instantiate(withOwner: owner, options: nil)[0] as! T
    #endif
}

#endif
