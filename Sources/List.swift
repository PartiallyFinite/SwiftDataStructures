//
//  List.swift
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

public final class ListNode<Element> : BidirectionalIndexType {

    private var value: Element!
    private var next: ListNode!
    private var prev: Unowned<ListNode>! // don't create strong reference cycles

    private init(value: Element!) { self.value = value }

    public func successor() -> ListNode {
        precondition(next != nil, "Cannot get successor of end index.")
        return next
    }

    public func predecessor() -> ListNode {
        precondition(prev != nil, "Cannot get predecessor of start index.")
        return prev.value
    }

}

public func ==<Element>(lhs: ListNode<Element>, rhs: ListNode<Element>) -> Bool {
    return lhs === rhs
}

private class ListOwner<Element> : NonObjectiveCBase {

    var head: ListNode<Element>?

}

/// A doubly-linked list with copy-on-write optimisation.
public struct List<Element> : ArrayLiteralConvertible, CollectionType, MutableCollectionType {

    public typealias Index = ListNode<Element>
    private typealias Node = Index

    private var owner = ListOwner<Element>()
    private var head: ListNode<Element>? {
        get { return owner.head }
        set { assert(isUniquelyReferenced(&owner)); owner.head = newValue }
    }

    /// Create an empty list.
    public init() { }

    /// - Complexity: O(n), where n is the length of `sequence`.
    public init<S : SequenceType where S.Generator.Element == Element>(_ sequence: S) {
        for v in sequence {
            append(v)
        }
    }

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    private var needsUnique: Bool {
        unowned var o = owner
        return !isUniquelyReferenced(&o)
    }

    private mutating func makeUnique() {
        assert(needsUnique)
        guard head != nil else { return }
        var node = head! // get strong reference
        owner = ListOwner()
        self.endIndex = Index(value: nil)
        while node.value != nil {
            append(node.value)
            node = node.next
        }
    }

    private mutating func uniqueTransferringIndex(index: Index) -> Index {
        // uniquing is O(n), so this is fine
        let offset = startIndex.distanceTo(index)
        makeUnique()
        return startIndex.advancedBy(offset)
    }

    /// - Complexity: O(1).
    public var startIndex: Index {
        return head ?? endIndex
    }

    /// - Complexity: O(1).
    public var endIndex = Index(value: nil)

    /// If this is the *first* modification to the list since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(1).
    public subscript(index: Index) -> Element {
        get {
            return index.value
        }
        set {
            let index = needsUnique ? uniqueTransferringIndex(index) : index
            index.value = newValue
        }
    }

}

extension List {

    /// Insert `newElement` before the element at `index`.
    ///
    /// If this is the *first* modification to the list since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(1).
    public mutating func insert(newElement: Element, atIndex index: Index) {
        let index = needsUnique ? uniqueTransferringIndex(index) : index
        let node = Node(value: newElement)
        node.next = index
        node.prev = index.prev
        if index.prev != nil {
            index.prev.value.next = node
        }
        else {
            assert(head == nil)
            head = node
        }
        index.prev = Unowned(node)
    }

    /// Remove and return the element at `index`.
    ///
    /// If this is the *first* modification to the list since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(1).
    public mutating func removeAtIndex(index: Index) -> Element {
        let index = needsUnique ? uniqueTransferringIndex(index) : index
        let prev = index.prev, next = index.next
        next.prev = prev
        if prev != nil {
            prev.value.next = next
        }
        else {
            assert(index == head)
            head = next
        }
        return index.value
    }

    /// Add `newElement` to the end of the list.
    ///
    /// If this is the *first* modification to the list since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(1).
    public mutating func append(newElement: Element) {
        insert(newElement, atIndex: endIndex)
    }

    /// Remove and return the last element in the list.
    ///
    /// If this is the *first* modification to the list since creation or copying, invalidates all indices with respect to `self`.
    ///
    /// - Complexity: O(1).
    public mutating func removeLast() -> Element {
        return removeAtIndex(endIndex.predecessor())
    }

}
