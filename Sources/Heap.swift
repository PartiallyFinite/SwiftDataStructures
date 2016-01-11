//
//  Heap.swift
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

/// Implements a binary heap in a given range in any compatible container.
public struct _Heap<Container : MutableCollectionType where Container.Index : RandomAccessIndexType, Container.Index.Distance : IntegerArithmeticType> {

    typealias Element = Container.Generator.Element
    typealias Index = Container.Index

    public private(set) var range: Range<Index>
    public let before: (Element, Element) -> Bool

    /// `range.startIndex`
    public var startIndex: Index { return range.startIndex }
    /// `range.endIndex`
    public var endIndex: Index { return range.endIndex }
    /// `range.count`
    public var count: Index.Distance { return range.count }

    private init(inout container cont: Container, range: Range<Index>? = nil, comparator before: (Element, Element) -> Bool) {
        let range = range ?? cont.startIndex ..< cont.endIndex
        self.range = range
        self.before = before

        // fix the upper half of the heap (the lower half does not have children, so is already correctly ordered)
        for i in (range.startIndex ..< range.startIndex.advancedBy(range.count / 2)).reverse() {
            fix(&cont, index: i)
        }
    }

    /// Make a valid binary heap rooted at `i`.
    /// - Precondition: `i * 2 + 1` and `i * 2 + 2` are roots of valid binary heaps.
    /// - Postcondition: `i` is the root of a valid binary heap.
    /// - Complexity: O(log(`count`))
    private mutating func fix(inout cont: Container, index i: Index) {
        precondition(range ~= i, "Heap range \(range) does not contain index \(i).")

        let l = i + startIndex.distanceTo(i) + 1
        let r = l + 1
        var mi: Index
        // if l exists and sorts before i
        if l < endIndex && before(cont[l], cont[i]) { mi = l }
        else { mi = i }
        // if r exists and sorts before the greatest of i and l (mi)
        if r < endIndex && before(cont[r], cont[mi]) { mi = r }

        // if something needs to change, swap and fix
        if mi != i {
            swap(&cont[i], &cont[mi])
            fix(&cont, index: mi)
        }
    }

    private mutating func top(inout cont: Container) -> Element? {
        return range.count > 0 ? cont[startIndex] : nil
    }

    private mutating func pop(inout cont: Container) -> Element {
        precondition(range.count > 0, "Cannot pop from empty heap.")
        range.endIndex -= 1
        if range.count > 0 {
            // swap the popped (first) element with the one that just went out of range
            swap(&cont[range.startIndex], &cont[range.endIndex])
            // fix the heap from the top to correct the ordering
            fix(&cont, index: startIndex)
        }
        return cont[range.endIndex]
    }

    private mutating func update(inout cont: Container, value: Element? = nil, atIndex i: Index) {
        precondition(range ~= i, "Index \(i) outside of heap range \(range).")
        if let value = value {
            precondition(!before(cont[i], value), "New value must sort equal or before previous value.")
            cont[i] = value
        }
        func parent(i: Index) -> Index {
            // floor(i - 1) / 2
            return startIndex.advancedBy((startIndex.distanceTo(i) - 1) / 2)
        }
        // repeatedly swap the new node upwards until it no longer sorts before its parent
        var i = i
        while i > startIndex && before(cont[i], cont[parent(i)]) {
            swap(&cont[parent(i)], &cont[i])
            i = parent(i)
        }
    }

    private mutating func expand(inout cont: Container) {
        // expand the range to include the new element and run value update
        range.endIndex += 1
        update(&cont, atIndex: endIndex - 1)
    }

}

extension MutableCollectionType where Index : RandomAccessIndexType, Index.Distance : IntegerArithmeticType {

    /// Construct a binary heap in `range`.
    /// - Postcondition: `self[range]` forms a valid binary heap.
    /// - Complexity: O(`range.count`)
    @warn_unused_result
    public mutating func _makeHeapIn(range: Range<Index>, comparator before: (Generator.Element, Generator.Element) -> Bool) -> _Heap<Self> {
        return _Heap(container: &self, range: range, comparator: before)
    }

    /// Return the top of `heap`, or `nil` if the heap is empty.
    /// - Complexity: O(1)
    @warn_unused_result
    public mutating func _heapTop(inout heap: _Heap<Self>) -> Generator.Element? {
        return heap.top(&self)
    }

    /// Remove and return the top of `heap`, leaving the popped element at position `heap.endIndex` (after this function returns). The count of `self` is unchanged.
    /// - Complexity: O(log `heap.count`).
    public mutating func _popHeap(inout heap: _Heap<Self>) -> Generator.Element {
        return heap.pop(&self)
    }

    /// Update the value of the element at index `i` in `heap` to `value` (if given), which compares *before or equal* to the previous value.
    /// - Precondition: `!heap.before(self[i], value)`
    /// - Complexity: O(log `heap.count`)
    public mutating func _heapUpdate(inout heap: _Heap<Self>, value: Generator.Element? = nil, atIndex i: Index) {
        heap.update(&self, value: value, atIndex: i)
    }

    /// Expand the tail of the heap to include one additional element.
    /// - Complexity: O(log `heap.count`)
    public mutating func _heapExpand(inout heap: _Heap<Self>) {
        heap.expand(&self)
    }

    /// Sort the elements in `range` in-place using `comparator`.
    /// - Parameter range: The range to sort. Defaults to `startIndex..<endIndex`.
    /// - Parameter ascending: Sort ascending instead of descending. Defaults to `true`.
    /// - Complexity: O(`range.count`)
    public mutating func heapsort(range: Range<Index>? = nil, comparator before: (Generator.Element, Generator.Element) -> Bool) {
        let range = range ?? startIndex..<endIndex
        var heap = _makeHeapIn(range, comparator: before)
        while heap.count > 0 {
            _popHeap(&heap)
        }
    }

}

extension MutableCollectionType where Index : RandomAccessIndexType, Index.Distance : IntegerArithmeticType, Generator.Element : Comparable {

    /// Sort the elements in `range` in-place.
    /// - Parameter range: The range to sort. Defaults to `startIndex..<endIndex`.
    /// - Parameter ascending: Sort ascending instead of descending. Defaults to `true`.
    /// - Complexity: O(`range.count`)
    public mutating func heapsort(range: Range<Index>? = nil, ascending: Bool = true) {
        heapsort(range, comparator: ascending ? (>) : (<))
    }

}
