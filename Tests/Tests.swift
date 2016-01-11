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
@testable import SwiftDataStructures

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

}
