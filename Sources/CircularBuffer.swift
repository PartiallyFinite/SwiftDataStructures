//
//  CircularBuffer.swift
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

private struct _CircularBufferHead {

    let capacity: Int
    var count: Int
    var offset: Int

}

private final class _CircularManagedBuffer<Element> : ManagedBuffer<_CircularBufferHead, Element> {

    class func create(minimumCapacity: Int, initialHead: (ManagedProtoBuffer<_CircularBufferHead, Element>) -> _CircularBufferHead) -> _CircularManagedBuffer<Element> {
        return unsafeDowncast(_CircularManagedBuffer<Element>.create(minimumCapacity, initialValue: initialHead))
    }

    class func create(minimumCapacity capacity: Int) -> _CircularManagedBuffer<Element> {
        return create(capacity) { proto in
            _CircularBufferHead(capacity: proto.allocatedElementCount, count: 0, offset: 0)
        }
    }

    class func create<C : CollectionType where C.Generator.Element == Element>(collection: C, minimumCapacity: Int = 0) -> _CircularManagedBuffer<Element> {
        let count = Int(collection.count.toIntMax())
        let buf = create(max(count, minimumCapacity)) { proto in
            _CircularBufferHead(capacity: proto.allocatedElementCount, count: count, offset: 0)
        }
        buf.withUnsafeMutablePointerToElements {
            $0.initializeFrom(collection)
        }
        return buf
    }

    func copy() -> _CircularManagedBuffer<Element> {
        let capacity = value.capacity, count = value.count, offset = value.offset
        let new = _CircularManagedBuffer<Element>.create(capacity) { proto in
            _CircularBufferHead(capacity: capacity, count: count, offset: 0)
        }
        let headCount = min(capacity - offset, count)
        let tailCount = count - headCount
        withUnsafeMutablePointerToElements { old in
            new.withUnsafeMutablePointerToElements { new in
                new.initializeFrom(old + offset, count: headCount)
                (new + headCount).initializeFrom(old, count: tailCount)
            }
        }
        return new
    }

    deinit {
        let offset = value.offset, head = min(value.capacity - offset, value.count), tail = value.count - head
        withUnsafeMutablePointerToElements { ptr in
            (ptr + offset).destroy(head)
            ptr.destroy(tail)
        }
    }

}

/// A fixed-capacity circular buffer with copy-on-write optimisation. Provides O(1) insertion and removal at both the start and the end, and O(1) random access.
public struct _CircularBuffer<Element> {

    private typealias Buffer = _CircularManagedBuffer<Element>

    private var buf: Buffer

    public var capacity: Int { return buf.value.capacity }
    public private(set) var count: Int {
        get { return buf.value.count }
        set { assert(isUniquelyReferenced(&buf)); buf.value.count = newValue }
    }
    private var offset: Int {
        get { return buf.value.offset }
        set { assert(isUniquelyReferenced(&buf)); buf.value.offset = newValue }
    }

    public init(minimumCapacity: Int) {
        buf = Buffer.create(minimumCapacity: minimumCapacity)
    }

    public init(_ circularBuffer: _CircularBuffer<Element>) {
        buf = circularBuffer.buf.copy()
    }

    public init<C : CollectionType where C.Generator.Element == Element>(_ collection: C, minimumCapacity: Int = 0) {
        buf = Buffer.create(collection, minimumCapacity: minimumCapacity)
    }

    private mutating func ensureUnique() {
        if !isUniquelyReferenced(&buf) {
            buf = buf.copy()
        }
    }

    public mutating func append(newElement: Element) {
        precondition(count < capacity, "Cannot insert into a circular buffer that is full.")
        ensureUnique()
        let i = (offset + count) % capacity
        buf.withUnsafeMutablePointerToElements { ($0 + i).initialize(newElement) }
        count += 1
    }

    public mutating func prepend(newElement: Element) {
        precondition(count < capacity, "Cannot insert into a circular buffer that is full.")
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
            let rem = ptr.memory
            ptr.destroy()
            return rem
        }
    }

    public mutating func removeFirst() -> Element {
        precondition(count > 0, "Cannot remove from an empty circular buffer.")
        ensureUnique()
        let rem: Element = buf.withUnsafeMutablePointerToElements {
            let ptr = $0 + self.offset
            let rem = ptr.memory
            ptr.destroy()
            return rem
        }
        count -= 1
        offset += 1
        if offset == capacity { offset = 0 }
        return rem
    }

}

extension _CircularBuffer : CollectionType, MutableCollectionType {

    public var startIndex: Int { return 0 }

    public var endIndex: Int { return count }

    /// - Precondition: `indices ~= index`.
    public subscript(index: Int) -> Element {
        get {
            let i = (offset + index) % capacity
            return buf.withUnsafeMutablePointerToElements { $0[i] }
        }
        set {
            let i = (offset + index) % capacity
            buf.withUnsafeMutablePointerToElements { $0[i] = newValue }
        }
    }

}

extension _CircularBuffer {

    public var first: Element? { return count > 0 ? self[0] : nil }
    public var last: Element? { return count > 0 ? self[count - 1] : nil }

    public mutating func popFirst() -> Element? { return count > 0 ? removeFirst() : nil }
    public mutating func popLast() -> Element? { return count > 0 ? removeLast() : nil }

}
