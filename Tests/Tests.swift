//
//  SwiftDataStructuresTests.swift
//  SwiftDataStructuresTests
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

import XCTest
import SwiftDataStructures

class SwiftDataStructuresTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHeapSort() {
        let x = [5, 7, 98, -178, -15, 36]
        var a = x, b = x
        a.sortInPlace()
        b.heapsort(ascending: true)
        XCTAssertEqual(a, b)

        a = x
        b = x
        a[2...4].sortInPlace()
        b.heapsort(2...4, ascending: true)
        XCTAssertEqual(a, b)
    }

    func testPriorityQueue() {
        var q = PriorityQueue<Int>()
        q.insert(5)
        q.insert(7)
        q.insert(2)
        XCTAssertEqual(q.remove(), 7)
        XCTAssertEqual(q.remove(), 5)
        XCTAssertEqual(q.remove(), 2)
        XCTAssertEqual(q.pop(), nil)
        q.insert(-9)
        q.insert(8)
        XCTAssertEqual(q.top, 8)
        q.insert(17)
        q.insert(-4)
        XCTAssertEqual(q.remove(), 17)
        XCTAssertEqual(q.remove(), 8)
        XCTAssertEqual(q.remove(), -4)
        XCTAssertEqual(q.remove(), -9)
    }

    func testRBTree() {
        var nums = insertNumbers
        var t = _RBTree<Int, ()>()
        XCTAssert(t.first == nil)
        XCTAssertEqual(t.startIndex, t.endIndex)
        for i in nums {
            t.insert(i, with: ())
        }
        nums.sortInPlace()

        XCTAssert(t.map({ $0.0 }).elementsEqual(nums))
        XCTAssertEqual(t[t.find(3)!].0, 3)
        XCTAssertEqual(t.find(-1), nil)
        XCTAssertEqual(t[t.lowerBound(-5)].0, 0)
        XCTAssertEqual(t[t.lowerBound(32)].0, nums[nums.indexOf({ $0 >= 32 })!])
        XCTAssertEqual(t[t.upperBound(3)].0, nums[nums.indexOf({ $0 > 3 })!])
        XCTAssertEqual(t[t.upperBound(73)].0, nums[nums.indexOf({ $0 > 73 })!])
        XCTAssertEqual(t.upperBound(100), t.endIndex)
        XCTAssertEqual(t.lowerBound(101), t.endIndex)
        XCTAssertEqual(t.minKey, 0)
        XCTAssertEqual(t.maxKey, 100)

        for _ in 0..<300 {
            t.remove(t.endIndex.predecessor())
        }

        for n in nums[700..<1000] {
            t.insert(n, with: ())
        }

        XCTAssert(nums.elementsEqual(t.map { $0.0 }))

        for i in removeIndices {
            let it = t.find(nums[i])!
            XCTAssertEqual(t[it].0, nums[i])
            t.remove(it)
            nums.removeAtIndex(i)
            XCTAssertEqual(t.count, nums.count)
            XCTAssertEqual(t.last?.0, nums.last)
            XCTAssertEqual(t.first?.0, nums.first)
            XCTAssert(t.map({ $0.0 }).elementsEqual(nums))
        }
    }

    func testRBTreeIndexing() {
        var a = _RBTree<Int, ()>([1, 2, 3, 4, 5].map { ($0, ()) })
        let i = a.find(3)!, j = a.find(2)!, k = a.find(5)!
        a.remove(i)
        XCTAssertEqual(a[j].0, 2)
        XCTAssertEqual(a[k].0, 5)
        var b = a
        XCTAssertEqual(b[j].0, 2)
        XCTAssertEqual(b[k].0, 5)
        b.remove(j)
        XCTAssert(b.elementsEqual([1, 4, 5].map { ($0, ()) }, isEquivalent: { $0.0 == $1.0 }))
    }

    func testOrderedDictionary() {
        var a: OrderedDictionary = [5: "hello", 6: "aoeu", -1: ""]
        XCTAssertEqual(a[5], "hello")
        XCTAssertEqual(a[6], "aoeu")
        XCTAssertEqual(a[-1], "")
        a[2] = "htns"
        XCTAssertEqual(a[2], "htns")
        a[5] = "bye"
        XCTAssertEqual(a[5], "bye")
        a.removeValueForKey(6)
        XCTAssertEqual(a.count, 3)
    }

    func testLinkedList() {
        var a: List<Int> = [1, 2, 4, 8]
        a.append(16)
        XCTAssertEqual(a.count, 5)
        var b = a
        a.removeAtIndex(a.startIndex.advancedBy(2))
        XCTAssert(a.elementsEqual([1, 2, 8, 16]))
        b.insert(20, atIndex: b.startIndex.advancedBy(2))
        XCTAssert(b.elementsEqual([1, 2, 20, 4, 8, 16]))
    }

    func testDequeMisc() {
        var a = [1, 2, 3, 4, 5] as Deque<Int>
        a.removeLast()
        XCTAssert(a.elementsEqual(1...4))
        a.prepend(0)
        XCTAssert(a.elementsEqual(0...4))
        a.append(5)
        XCTAssert(a.elementsEqual(0...5))

        var b = a
        a.removeFirst()
        XCTAssert(a.elementsEqual(1...5))
        b.replaceRange(2...4, with: 2...82)
        b.removeLast()
        XCTAssert(b.elementsEqual(0...82))

        b.removeAll(keepCapacity: true)
        b.prepend(1)
        XCTAssert(b.elementsEqual(1...1))

        a.removeAll(keepCapacity: false)
        a.appendContentsOf([5, 6, 7, 8])
        XCTAssert(a.elementsEqual(5...8))
    }

    func testDequeRangeReplace() {
        var d = Deque<Int>()
        var a = Array<Int>()
        for (_, (s, t, v)) in rangeReplaceInstructions.enumerate() {
            a.replaceRange(s..<t, with: v)
            d.replaceRange(s..<t, with: v)
            if !a.elementsEqual(d) {
                XCTFail("\(d) not equal to \(a).")
            }
        }
    }

}
