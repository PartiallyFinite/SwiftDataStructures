//
//  OrderedCollections.swift
//  SwiftDataStructures
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Greg Omelaenko
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
//

public struct OrderedSetIndex<Element : Comparable> : BidirectionalIndexType {

    private let index: _RBTreeIndex<Element, ()>

    private init(_ index: _RBTreeIndex<Element, ()>) { self.index = index }

    public func successor() -> OrderedSetIndex {
        return OrderedSetIndex(index.successor())
    }

    public func predecessor() -> OrderedSetIndex {
        return OrderedSetIndex(index.predecessor())
    }

}

public func ==<Element : Comparable>(lhs: OrderedSetIndex<Element>, rhs: OrderedSetIndex<Element>) -> Bool {
    return lhs.index == rhs.index
}

/// An ordered collection of unique `Element` instances.
public struct OrderedSet<Element : Comparable> : CollectionType, ArrayLiteralConvertible {

    private var tree: _RBTree<Element, ()>

    public typealias Index = OrderedSetIndex<Element>

    /// Create an empty set.
    public init() {
        tree = _RBTree()
    }

    /// Create a set from a finite sequence of items.
    ///
    /// - Complexity: O(n log n), where n is the length of `sequence`.
    public init<S : SequenceType where S.Generator.Element == Element>(_ sequence: S) {
        tree = _RBTree(sequence.lazy.map { ($0, ()) })
    }

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    /// The position of the first element in a non-empty set.
    ///
    /// This is identical to `endIndex` in an empty set.
    ///
    /// - Complexity: O(1).
    public var startIndex: Index {
        return Index(tree.startIndex)
    }

    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always reachable from `startIndex` by zero or more applications of `successor()`.
    ///
    /// - Complexity: O(1).
    public var endIndex: Index {
        return Index(tree.endIndex)
    }

    /// Returns `true` if the set contains `member`.
    ///
    /// - Complexity: O(log `count`).
    @warn_unused_result
    public func contains(member: Element) -> Bool {
        return tree.contains(member)
    }

    /// Returns the `Index` of a given member, or `nil` if the member is not present in the set.
    ///
    /// - Complexity: O(log `count`).
    @warn_unused_result
    public func indexOf(member: Element) -> Index? {
        let i = tree.find(member)
        return i != nil ? Index(i!) : nil
    }

    /// Insert a member into the set.
    ///
    /// If this is the *first* modification to the set since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func insert(member: Element) {
        guard !tree.contains(member) else { return }
        tree.insert(member, with: ())
    }

    /// Remove the member from the set and return it if it was present.
    ///
    /// If this is the *first* modification to the set since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func remove(member: Element) -> Element? {
        guard let i = tree.find(member) else { return nil }
        return removeAtIndex(Index(i))
    }

    /// Remove the member referenced by the given index and return it.
    ///
    /// If this is the *first* modification to the set since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func removeAtIndex(index: Index) -> Element {
        let r = tree[index.index].0
        tree.remove(index.index)
        return r
    }

    /// The number of members in the set.
    ///
    /// - Complexity: O(1).
    public var count: Int {
        return tree.count
    }

    /// Access the member at `position`.
    ///
    /// - Complexity: O(1).
    public subscript (position: OrderedSetIndex<Element>) -> Element {
        return tree[position.index].0
    }

    /// Remove the smallest member from the set and return it.
    ///
    /// If this is the *first* modification to the set since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Requires: `count > 0`.
    /// - Complexity: O(log `count`).
    public mutating func removeFirst() -> Element {
        return removeAtIndex(startIndex)
    }

    /// Remove the greatest member from the set and return it.
    ///
    /// If this is the *first* modification to the set since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Requires: `count > 0`.
    /// - Complexity: O(log `count`).
    public mutating func removeLast() -> Element {
        return removeAtIndex(endIndex.predecessor())
    }

    /// If `!self.isEmpty`, return the smallest element in the set, otherwise return `nil`
    ///
    /// If this is the *first* modification to the set since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func popFirst() -> Element? {
        return isEmpty ? nil : removeFirst()
    }

    /// If `!self.isEmpty`, return the smallest element in the set, otherwise return `nil`
    ///
    /// If this is the *first* modification to the set since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func popLast() -> Element? {
        return isEmpty ? nil : removeLast()
    }

    /// The smallest element in the set.
    ///
    /// - Complexity: O(1).
    public var first: Element? {
        return tree.first?.0
    }

    /// The greatest element in the set.
    ///
    /// - Complexity: O(1).
    public var last: Element? {
        return tree.last?.0
    }

    /// Return the smallest element in the set.
    ///
    /// - Complexity: O(1).
    public func minElement() -> Element? {
        return first
    }

    /// Return the greatest element in the set.
    ///
    /// - Complexity: O(1).
    public func maxElement() -> Element? {
        return last
    }

}

public struct OrderedDictionaryIndex<Key : Comparable, Value> : BidirectionalIndexType {

    private let index: _RBTreeIndex<Key, Value>

    private init(_ index: _RBTreeIndex<Key, Value>) { self.index = index }

    public func successor() -> OrderedDictionaryIndex {
        return OrderedDictionaryIndex(index.successor())
    }

    public func predecessor() -> OrderedDictionaryIndex {
        return OrderedDictionaryIndex(index.predecessor())
    }

}

public func ==<Key : Comparable, Value>(lhs: OrderedDictionaryIndex<Key, Value>, rhs: OrderedDictionaryIndex<Key, Value>) -> Bool {
    return lhs.index == rhs.index
}

/// A mapping from `Key` to `Value` instances, ordered by key.
public struct OrderedDictionary<Key : Comparable, Value> : CollectionType, DictionaryLiteralConvertible {

    private var tree: _RBTree<Key, Value>

    public typealias Element = (Key, Value)
    public typealias Index = OrderedDictionaryIndex<Key, Value>

    /// Create an empty dictionary.
    public init() {
        tree = _RBTree()
    }

    /// Create a dictionary from a finite sequence of key-value pairs.
    ///
    /// - Complexity: O(n log n), where n is the length of `sequence`.
    public init<S : SequenceType where S.Generator.Element == Element>(_ sequence: S) {
        tree = _RBTree(sequence)
    }

    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }

    /// The position of the first element in a non-empty dictionary.
    ///
    /// Identical to `endIndex` in an empty dictionary.
    ///
    /// - Complexity: O(1).
    public var startIndex: Index {
        return Index(tree.startIndex)
    }

    /// The collection's "past the end" position.
    ///
    /// `endIndex` is not a valid argument to `subscript`, and is always reachable from `startIndex` by zero or more applications of `successor()`.
    ///
    /// - Complexity: O(1).
    public var endIndex: Index {
        return Index(tree.endIndex)
    }

    /// Returns the index for the given key, or `nil` if the key is not present in the dictionary.
    ///
    /// - Complexity: O(log `count`).
    @warn_unused_result
    public func indexForKey(key: Key) -> Index? {
        guard let i = tree.find(key) else { return nil }
        return Index(i)
    }

    /// Access the key-value pair at `position`.
    ///
    /// - Complexity: O(1).
    public subscript(position: Index) -> Element {
        return tree[position.index]
    }

    /// Access the value associated with the given key.
    ///
    /// Reading a key that is not present in `self` yields `nil`. Writing `nil` as the value for a given key erases that key from `self`.
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public subscript(key: Key) -> Value? {
        get {
            guard let i = tree.find(key) else { return nil }
            return tree[i].1
        }
        set {
            if let i = tree.find(key) {
                if let v = newValue { tree.updateValue(v, atIndex: i) }
                else { tree.remove(i) }
            }
            else if let v = newValue {
                tree.insert(key, with: v)
            }
        }
    }

    /// Update the value stored in the dictionary for the given key, or, if they key does not exist, add a new key-value pair to the dictionary.
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Returns: The value that was replaced, or `nil` if a new key-value pair was added.
    ///
    /// - Complexity: O(log `count`).
    public mutating func updateValue(value: Value, forKey key: Key) -> Value? {
        if let i = tree.find(key) {
            return tree.updateValue(value, atIndex: i)
        }
        else {
            tree.insert(key, with: value)
            return nil
        }
    }

    /// Remove and return the key-value pair at `index`.
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func removeAtIndex(index: Index) -> Element {
        let v = tree[index.index]
        tree.remove(index.index)
        return v
    }

    /// Remove a given key and the associated value from the dictionary.
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Returns: The value that was removed, or `nil` if the key was not present in the dictionary.
    /// - Complexity: O(log `count`).
    public mutating func removeValueForKey(key: Key) -> Value? {
        if let i = tree.find(key) {
            let v = tree[i].1
            tree.remove(i)
            return v
        }
        return nil
    }

    /// The number of entries in the dictionary.
    ///
    /// - Complexity: O(1).
    public var count: Int {
        return tree.count
    }

    /// A collection containing just the keys of `self`.
    ///
    /// Keys appear in the same order as they occur as the `.0` member of key-value pairs in `self`.  Each key in the result has a unique value.
    public var keys: LazyMapCollection<OrderedDictionary, Key> {
        return LazyMapCollection(self) { $0.0 }
    }

    /// A collection containing just the values of `self`.
    ///
    /// Values appear in the same order as they occur as the `.1` member of key-value pairs in `self`.
    public var values: LazyMapCollection<OrderedDictionary, Value> {
        return LazyMapCollection(self) { $0.1 }
    }

    /// Remove the key-value pair with the smallest key from the dictionary and return it.
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Requires: `count > 0`.
    /// - Complexity: O(log `count`).
    public mutating func removeFirst() -> Element {
        return removeAtIndex(startIndex)
    }

    /// Remove the key-value pair with the greatest key from the dictionary and return it.
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Requires: `count > 0`.
    /// - Complexity: O(log `count`).
    public mutating func removeLast() -> Element {
        return removeAtIndex(endIndex.predecessor())
    }

    /// If `!self.isEmpty`, return the key-value pair with the smallest key in the dictionary, otherwise return `nil`
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func popFirst() -> Element? {
        return isEmpty ? nil : removeFirst()
    }

    /// If `!self.isEmpty`, return the key-value pair with the greatest key in the dictionary, otherwise return `nil`
    ///
    /// If this is the *first* modification to the dictionary since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(log `count`).
    public mutating func popLast() -> Element? {
        return isEmpty ? nil : removeLast()
    }

    /// The key-value pair with the smallest key in the dictionary.
    ///
    /// - Complexity: O(1).
    public var first: Element? {
        return tree.first
    }

    /// The key-value pair with the greatest key in the dictionary.
    ///
    /// - Complexity: O(1).
    public var last: Element? {
        return tree.last
    }

    /// Return the key-value pair with the smallest key in the dictionary.
    ///
    /// - Complexity: O(1).
    public func minElement() -> Element? {
        return first
    }

    /// Return the key-value pair with the greatest key in the dictionary.
    ///
    /// - Complexity: O(1).
    public func maxElement() -> Element? {
        return last
    }

}
