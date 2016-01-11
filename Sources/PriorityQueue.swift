//
//  PriorityQueue.swift
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

/// Implements a priority queue using any compatible container and a given comparator function.
public final class _PriorityQueueImpl<Container : MutableCollectionType where Container.Index : RandomAccessIndexType, Container.Index.Distance : IntegerArithmeticType, Container : RangeReplaceableCollectionType> : NonObjectiveCBase {

    public typealias Element = Container.Generator.Element

    private var container = Container()
    private var heap: _Heap<Container>

    public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S, comparator before: (Element, Element) -> Bool) {
        container.appendContentsOf(seq)
        heap = container._makeHeapIn(container.startIndex ..< container.endIndex, comparator: before)
    }

    public convenience init(comparator before: (Element, Element) -> Bool) {
        self.init(EmptyCollection<Element>(), comparator: before)
    }

    public init(_ other: _PriorityQueueImpl<Container>) {
        container.appendContentsOf(other.container)
        heap = other.heap
    }

    public var count: Container.Index.Distance {
        return container.count
    }

    public func insert(v: Element) {
        container.append(v)
        container._heapExpand(&heap)
    }

    public var top: Element? {
        return container._heapTop(&heap)
    }

    public func removeTop() -> Element {
        let top = container._popHeap(&heap)
        container.removeLast()
        return top
    }

}

/// Implements a priority queue.
public struct PriorityQueue<Element : Comparable> {

    private var impl: _PriorityQueueImpl<ContiguousArray<Element>>

    private mutating func ensureUnique() {
        if !isUniquelyReferenced(&impl) {
            impl = _PriorityQueueImpl(impl)
        }
    }

    /// Construct a priority queue containing the items in `seq`.
    /// A max-priority queue is constructed unless `max` is specified as `false`.
    public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S, max: Bool = true) {
        impl = _PriorityQueueImpl(seq, comparator: max ? (>) : (<))
    }

    /// Construct an empty priority queue.
    /// A max-priority queue is constructed unless `max` is specified as `false`.
    public init(max: Bool = true) {
        self.init(EmptyCollection<Element>(), max: max)
    }

    /// The number of items currently in the priority queue.
    public var count: Int {
        return impl.count
    }

    /// Insert `v` into the queue.
    public mutating func insert(v: Element) {
        ensureUnique()
        impl.insert(v)
    }

    /// The top of the queue, or `nil` if the queue is empty.
    public var top: Element? {
        return impl.top
    }

    /// Remove and return the top element of the queue.
    /// - Precondition: `count > 0`
    public mutating func remove() -> Element {
        ensureUnique()
        return impl.removeTop()
    }

    /// Remove and return the top element of the queue, or return `nil` if the queue is empty.
    public mutating func pop() -> Element? {
        return count > 0 ? remove() : nil
    }

}
