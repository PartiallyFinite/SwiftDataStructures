//
//  Deque.swift
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

private struct _DequeHead {

    let capacity: Int
    var count: Int
    var offset: Int

}

private final class _DequeBuffer<Element> : ManagedBuffer<_DequeHead, Element> {

    class func create(minimumCapacity: Int, count: Int, offset: Int) -> _DequeBuffer<Element> {
        return unsafeDowncast(_DequeBuffer<Element>.create(minimumCapacity) { proto in
            _DequeHead(capacity: proto.allocatedElementCount, count: count, offset: offset)
        })
    }

    class func create(minimumCapacity capacity: Int) -> _DequeBuffer<Element> {
        return create(capacity, count: 0, offset: 0)
    }

    class func create<C : CollectionType where C.Generator.Element == Element>(collection: C, minimumCapacity: Int = 0) -> _DequeBuffer<Element> {
        let count = Int(collection.count.toIntMax())
        let buf = create(max(count, minimumCapacity), count: count, offset: 0)
        buf.withUnsafeMutablePointerToElements {
            $0.initializeFrom(collection)
        }
        return buf
    }

    func _copy(minimumCapacity: Int, mover: UnsafeMutablePointer<Element> -> (UnsafeMutablePointer<Element>, count: Int) -> Void) -> _DequeBuffer<Element> {
        let capacity = max(minimumCapacity, value.capacity), count = value.count, offset = value.offset
        let new = _DequeBuffer<Element>.create(capacity, count: count, offset: 0)
        let headCount = min(value.capacity - offset, count)
        let tailCount = count - headCount
        withUnsafeMutablePointerToElements { old in
            new.withUnsafeMutablePointerToElements { new in
                mover(new)(old + offset, count: headCount)
                mover(new + headCount)(old, count: tailCount)
            }
        }
        return new
    }

    func copy(minimumCapacity: Int = 0) -> _DequeBuffer<Element> {
        return _copy(minimumCapacity, mover: UnsafeMutablePointer<Element>.initializeFrom)
    }

    func move(minimumCapacity: Int = 0) -> _DequeBuffer<Element> {
        return _copy(minimumCapacity, mover: UnsafeMutablePointer<Element>.moveInitializeFrom)
    }

    deinit {
        let offset = value.offset, head = min(value.capacity - offset, value.count), tail = value.count - head
        withUnsafeMutablePointerToElements { ptr in
            (ptr + offset).destroy(head)
            ptr.destroy(tail)
        }
    }

}

private let _DequeInitialCapacity = 8
private let _DequeExpansionFactor = 2

/// A double-ended queue that provides O(1) insertion and removal at both the start and the end, and O(1) random access.
public struct Deque<Element> {

    private typealias Buffer = _DequeBuffer<Element>

    private var buf: Buffer

    public var capacity: Int { return buf.value.capacity }
    public private(set) var count: Int {
        get { return buf.value.count }
        set { assert(0 ... capacity ~= newValue); buf.value.count = newValue }
    }
    private var offset: Int {
        get { return buf.value.offset }
        set { assert(0 ..< capacity ~= newValue); buf.value.offset = newValue }
    }

    public init() {
        self.init(minimumCapacity: 0)
    }

    public init(minimumCapacity: Int) {
        buf = Buffer.create(minimumCapacity: max(minimumCapacity, _DequeInitialCapacity))
    }

    public init(_ deque: Deque<Element>) {
        buf = deque.buf.copy()
    }

    public init<C : CollectionType where C.Generator.Element == Element>(_ collection: C, minimumCapacity: Int = _DequeInitialCapacity) {
        buf = Buffer.create(collection, minimumCapacity: minimumCapacity)
    }

    private mutating func ensureUnique() {
        if !isUniquelyReferenced(&buf) {
            buf = buf.copy()
        }
    }

    private mutating func expandIfFull() {
        guard count == capacity else { return }
        let newcap = capacity * _DequeExpansionFactor
        buf = (isUniquelyReferenced(&buf) ? buf.move : buf.copy)(newcap)
    }

}

extension Deque : ArrayLiteralConvertible {

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

}

extension Deque : CollectionType, MutableCollectionType {

    public var startIndex: Int { return 0 }

    public var endIndex: Int { return count }

    /// - Precondition: `indices ~= index`.
    public subscript(index: Int) -> Element {
        get {
            let i = (offset + index) % capacity
            return buf.withUnsafeMutablePointerToElements { $0[i] }
        }
        set {
            ensureUnique()
            let i = (offset + index) % capacity
            buf.withUnsafeMutablePointerToElements { $0[i] = newValue }
        }
    }

}

extension Deque : RangeReplaceableCollectionType {

    private func _parts(range: Range<Int>) -> (head: Range<Int>, tail: Range<Int>) {
        let head = min(offset + range.startIndex, capacity) ..< min(offset + range.endIndex, capacity)
        let tail = max(range.startIndex - (capacity - offset), 0) ..< max(range.endIndex - (capacity - offset), 0)
        assert(0 ..< capacity ~= head.startIndex || head.startIndex == head.endIndex)
        assert(0 ... capacity ~= head.endIndex)
        assert(0 ..< capacity ~= tail.startIndex || tail.startIndex == tail.endIndex)
        assert(0 ... capacity ~= tail.endIndex)
        return (head, tail)
    }

    /// Moves `range` (in external indexing) by `shift`, assuming that this will not result in moving into initialised memory.
    private mutating func _moveRange(range: Range<Int>, by shift: Int) {
        let newOffset = range.startIndex == startIndex ? (offset + shift + capacity) % capacity : offset
        defer { offset = newOffset }
        guard range.count != 0 else { return }
        assert(range != indices)
        guard shift != 0 else { return }
        let (head, tail) = _parts(range)
        buf.withUnsafeMutablePointerToElements { ptr in
            if shift > 0 {
                // move the tail down
                (ptr + tail.startIndex + shift).moveInitializeBackwardFrom(ptr + tail.startIndex, count: tail.count)
                // move the piece of head that rolls over
                let rollUpper = self.capacity - shift
                let rollStart = max(rollUpper, head.startIndex), rollCount = max(head.endIndex - rollStart, 0)
                if rollCount > 0 {
                    (ptr + rollStart - rollUpper).moveInitializeFrom(ptr + rollStart, count: rollCount)
                }
                // move the rest of the head down
                (ptr + head.startIndex + shift).moveInitializeBackwardFrom(ptr + head.startIndex, count: head.count - rollCount)
            }
            else {
                // move the piece of head that rolls over
                let headRoll: Int
                if head.startIndex + shift < 0 {
                    headRoll = min(-(head.startIndex + shift), head.count)
                    (ptr + (head.startIndex + shift + self.capacity)).moveInitializeFrom(ptr + head.startIndex, count: headRoll)
                } else { headRoll = 0 }
                // move the rest of the head up
                (ptr + (head.startIndex + headRoll + shift)).moveInitializeFrom(ptr + (head.startIndex + headRoll), count: head.count - headRoll)
                // move the piece of tail that rolls over
                let tailRoll: Int
                if tail.startIndex + shift < 0 {
                    tailRoll = min(-(tail.startIndex + shift), tail.count)
                    (ptr + (tail.startIndex + shift + self.capacity)).moveInitializeFrom(ptr + tail.startIndex, count: tailRoll)
                } else { tailRoll = 0 }
                // move the rest of the tail up
                (ptr + (tail.startIndex + tailRoll) + shift).moveInitializeFrom(ptr + (tail.startIndex + tailRoll), count: tail.count - tailRoll)
            }
        }
    }

    /// Destroys the elements in `range` (in external indexing).
    private mutating func _destroyRange(range: Range<Int>) {
        let (head, tail) = _parts(range)
        buf.withUnsafeMutablePointerToElements { ptr in
            (ptr + head.startIndex).destroy(head.count)
            (ptr + tail.startIndex).destroy(tail.count)
        }
    }

    private mutating func _initialiseRange<C : CollectionType where C.Generator.Element == Element>(range: Range<Int>, elements: C) {
        assert(range.count.toIntMax() == elements.count.toIntMax())
        let (head, tail) = _parts(range)
        let mid = elements.startIndex.advancedBy(numericCast(head.count))
        buf.withUnsafeMutablePointerToElements { ptr in
            (ptr + head.startIndex).initializeFrom(CollectionSlice(base: elements, bounds: elements.startIndex..<mid))
            (ptr + tail.startIndex).initializeFrom(CollectionSlice(base: elements, bounds: mid..<elements.endIndex))
        }
    }

    public mutating func replaceRange<C : CollectionType where C.Generator.Element == Element>(subRange: Range<Int>, with newElements: C) {
        let nnew = Int(newElements.count.toIntMax())
        let newCount = count - subRange.count + nnew
        if newCount > capacity || !isUniquelyReferenced(&buf) {
            // expand and move/copy
            let index = subRange.startIndex
            let headEnd = min(offset + count, capacity)
            // the part of the head before subRange
            let headA = offset ..< min(offset + index, headEnd)
            // the part of the head after subRange
            let headB = min(offset + subRange.endIndex, headEnd) ..< headEnd
            // the length of a full head
            let fullHeadLength = capacity - offset
            // the part of the tail before subRange (implicitly assumes there is a complete head which doesn't contain subRange)
            let tailA = 0 ..< max(subRange.startIndex - fullHeadLength, 0)
            // the part of the tail after subRange
            let tailB = max(subRange.endIndex - fullHeadLength, 0) ..< max(count - fullHeadLength, 0)
            
            assert(headB.isEmpty || tailA.isEmpty)
            
            let newbuf = Buffer.create(ceilToPowerOf2(newCount), count: newCount, offset: 0)
            let mover = isUniquelyReferenced(&buf) ? UnsafeMutablePointer<Element>.moveInitializeFrom : UnsafeMutablePointer<Element>.initializeFrom
            buf.withUnsafeMutablePointerToElements { old in
                newbuf.withUnsafeMutablePointerToElements { new in
                    var i = 0
                    mover(new)(old + headA.startIndex, count: headA.count); i += headA.count
                    mover(new + i)(old + tailA.startIndex, count: tailA.count); i += tailA.count
                    (new + i).initializeFrom(newElements); i += nnew
                    mover(new + i)(old + headB.startIndex, count: headB.count); i += headB.count
                    mover(new + i)(old + tailB.startIndex, count: tailB.count); i += tailB.count
                }
            }
            buf = newbuf
        }
        else {
            let shift = nnew - subRange.count
            _destroyRange(subRange)
            if subRange.startIndex <= count / 2 { // move front forward/backward depending on shift
                _moveRange(startIndex ..< subRange.startIndex, by: -shift)
            }
            else { // move back backward/forward depending on shift
                _moveRange(subRange.endIndex ..< endIndex, by: shift)
            }
            _initialiseRange(subRange.startIndex ..< (subRange.startIndex + nnew), elements: newElements)
            count = newCount
        }
    }

    public mutating func removeAll(keepCapacity keepCapacity: Bool) {
        if keepCapacity {
            _destroyRange(indices)
            count = 0
            offset = 0
        }
        else {
            buf = Buffer.create(minimumCapacity: _DequeInitialCapacity)
        }
    }

}

extension Deque {

    public mutating func append(newElement: Element) {
        expandIfFull()
        ensureUnique()
        let i = (offset + count) % capacity
        buf.withUnsafeMutablePointerToElements { ($0 + i).initialize(newElement) }
        count += 1
    }

    public mutating func prepend(newElement: Element) {
        expandIfFull()
        ensureUnique()
        let i = offset != 0 ? offset - 1 : capacity - 1
        buf.withUnsafeMutablePointerToElements { ($0 + i).initialize(newElement) }
        offset = i
        count += 1
    }

    public mutating func removeLast() -> Element {
        precondition(count > 0, "Cannot remove from an empty circular buffer.")
        ensureUnique()
        count -= 1
        let i = (offset + count) % capacity
        return buf.withUnsafeMutablePointerToElements {
            let ptr = $0 + i
            return ptr.move()
        }
    }

    public mutating func removeFirst() -> Element {
        precondition(count > 0, "Cannot remove from an empty circular buffer.")
        ensureUnique()
        let rem: Element = buf.withUnsafeMutablePointerToElements {
            let ptr = $0 + self.offset
            return ptr.move()
        }
        count -= 1
        offset += 1
        if offset == capacity { offset = 0 }
        return rem
    }

}

extension Deque {

    public var first: Element? { return count > 0 ? self[0] : nil }
    public var last: Element? { return count > 0 ? self[count - 1] : nil }

    public mutating func popFirst() -> Element? { return count > 0 ? removeFirst() : nil }
    public mutating func popLast() -> Element? { return count > 0 ? removeLast() : nil }

}

extension Deque : CustomReflectable {

    public func customMirror() -> Mirror {
        return Mirror(self, unlabeledChildren: self, displayStyle: .Collection)
    }

}

extension Deque : CustomStringConvertible {

    public var description: String {
        return "[" + map({ String($0) }).joinWithSeparator(", ") + "]"
    }

}
