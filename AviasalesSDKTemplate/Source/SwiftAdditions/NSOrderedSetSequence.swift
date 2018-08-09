//
//  NSOrderedSetSequence.swift
//  Aviasales iOS Apps
//
//  Created by Denis Chaschin on 14.12.15.
//  Copyright © 2015 aviasales. All rights reserved.
//

import Foundation

struct NSOrderedSetSequence<T>: Sequence {
    let orderedSet: NSOrderedSet

    init(orderedSet: NSOrderedSet) {
        self.orderedSet = orderedSet.copy() as! NSOrderedSet
    }

    typealias Iterator = NSOrderedSetSequenceGenerator<T>

    func makeIterator() -> Iterator {
        return NSOrderedSetSequenceGenerator<T>(generator: orderedSet.makeIterator())
    }
}

struct NSOrderedSetSequenceGenerator<T>: IteratorProtocol {
    private var generator: NSFastEnumerationIterator

    init(generator: NSFastEnumerationIterator) {
        self.generator = generator
    }

    typealias Element = T

    mutating func next() -> Element? {
        return generator.next() as! T?
    }
}

extension NSOrderedSetSequence: Collection {
    public func index(after index: Int) -> Int {
        return index + 1
    }

    var startIndex: Int {
        return 0
    }

    var endIndex: Int {
        return orderedSet.count
    }

    subscript(position: Int) -> T {
        return orderedSet.object(at: position) as! T
    }
}

extension NSOrderedSetSequence {
    var last: T? {
        return orderedSet.lastObject as! T?
    }
}

extension NSOrderedSetSequence: CustomDebugStringConvertible {
    var debugDescription: String {
        return orderedSet.debugDescription
    }
}

extension NSOrderedSet {
    func asSequence<T>() -> NSOrderedSetSequence<T> {
        return NSOrderedSetSequence(orderedSet: self)
    }
}

extension NSSet {
    func orderedRandomly<T>() -> NSOrderedSetSequence<T> {
        return NSOrderedSetSequence(orderedSet: NSOrderedSet(set: self as! Set<AnyHashable>))
    }
}
