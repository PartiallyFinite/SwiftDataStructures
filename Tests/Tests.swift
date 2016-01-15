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
        var nums = [1, 94, 3, 96, 73, 78, 31, 30, 19, 60, 49, 88, 85, 77, 40, 56, 76, 90, 97, 86, 51, 65, 99, 50, 33, 6, 43, 92, 74, 93, 67, 19, 28, 25, 12, 78, 57, 17, 100, 40, 81, 78, 91, 70, 17, 26, 30, 9, 89, 59, 55, 87, 6, 31, 69, 55, 68, 25, 10, 74, 21, 17, 15, 55, 66, 68, 32, 64, 37, 19, 59, 7, 32, 99, 54, 36, 34, 46, 95, 54, 93, 89, 97, 9, 33, 43, 69, 61, 80, 82, 10, 6, 82, 21, 32, 13, 66, 38, 5, 38, 50, 75, 12, 73, 91, 62, 34, 98, 60, 92, 55, 96, 37, 8, 14, 41, 77, 100, 93, 90, 4, 79, 45, 42, 75, 98, 91, 56, 12, 28, 1, 85, 88, 65, 56, 74, 9, 63, 22, 75, 97, 16, 90, 75, 83, 99, 79, 82, 79, 4, 5, 66, 60, 46, 27, 72, 18, 62, 14, 34, 34, 98, 23, 99, 77, 90, 57, 43, 56, 95, 14, 29, 97, 37, 6, 86, 97, 25, 67, 80, 56, 29, 92, 71, 59, 74, 98, 31, 11, 50, 86, 85, 85, 38, 67, 100, 92, 96, 60, 85, 1, 93, 50, 32, 82, 73, 33, 26, 55, 76, 30, 98, 19, 43, 38, 49, 69, 100, 73, 35, 24, 55, 23, 48, 21, 52, 39, 71, 70, 98, 35, 100, 1, 86, 11, 46, 92, 63, 47, 2, 78, 18, 74, 76, 42, 99, 25, 80, 43, 43, 94, 61, 98, 82, 34, 50, 59, 42, 14, 71, 69, 1, 0, 68, 60, 14, 73, 15, 37, 30, 96, 43, 42, 19, 75, 77, 33, 79, 67, 24, 36, 6, 1, 97, 81, 58, 21, 82, 20, 1, 30, 38, 75, 64, 70, 51, 80, 35, 34, 83, 79, 15, 43, 15, 43, 55, 85, 100, 61, 73, 45, 45, 31, 66, 61, 58, 88, 35, 77, 72, 37, 73, 78, 68, 43, 55, 43, 18, 16, 44, 100, 20, 20, 100, 6, 17, 4, 41, 79, 1, 99, 14, 6, 38, 74, 33, 47, 44, 55, 32, 20, 21, 89, 81, 63, 46, 76, 28, 52, 7, 69, 66, 37, 4, 29, 6, 77, 6, 90, 13, 24, 99, 56, 8, 71, 99, 32, 25, 33, 46, 79, 90, 5, 94, 77, 41, 31, 64, 36, 73, 82, 97, 48, 93, 74, 94, 67, 12, 24, 88, 55, 90, 35, 74, 72, 91, 17, 55, 38, 62, 39, 51, 87, 20, 65, 76, 14, 88, 24, 67, 14, 57, 42, 99, 94, 6, 97, 35, 27, 46, 70, 61, 73, 23, 7, 68, 91, 93, 93, 6, 27, 25, 74, 64, 29, 97, 9, 47, 40, 0, 50, 12, 60, 94, 23, 58, 84, 33, 62, 55, 100, 80, 86, 10, 83, 12, 6, 73, 21, 87, 52, 47, 97, 6, 85, 37, 18, 96, 22, 11, 70, 36, 7, 53, 14, 45, 0, 91, 42, 43, 51, 68, 86, 67, 80, 100, 53, 10, 65, 22, 45, 18, 61, 44, 95, 7, 28, 36, 86, 42, 39, 71, 55, 44, 36, 63, 77, 41, 73, 45, 7, 94, 10, 57, 52, 72, 93, 24, 95, 48, 15, 8, 57, 76, 4, 49, 46, 17, 3, 74, 92, 10, 80, 19, 97, 79, 36, 0, 64, 84, 60, 44, 3, 28, 76, 16, 98, 45, 33, 63, 3, 74, 28, 20, 69, 31, 6, 64, 37, 39, 91, 17, 59, 95, 61, 59, 98, 92, 62, 85, 89, 79, 20, 47, 6, 9, 94, 8, 0, 22, 72, 56, 18, 50, 90, 95, 46, 72, 16, 19, 41, 73, 32, 15, 78, 80, 16, 46, 68, 65, 72, 39, 7, 7, 93, 25, 99, 80, 6, 87, 18, 67, 58, 65, 9, 7, 65, 22, 42, 54, 82, 44, 34, 70, 99, 27, 94, 13, 83, 83, 57, 56, 94, 92, 30, 15, 97, 21, 47, 69, 3, 14, 46, 77, 66, 97, 21, 96, 67, 6, 82, 71, 48, 54, 95, 23, 13, 86, 34, 9, 55, 23, 46, 73, 22, 14, 41, 26, 20, 54, 10, 65, 96, 9, 10, 92, 43, 28, 53, 50, 45, 22, 2, 0, 87, 85, 27, 0, 86, 47, 14, 59, 65, 23, 11, 79, 42, 8, 23, 60, 87, 51, 28, 70, 75, 25, 61, 53, 63, 24, 41, 17, 74, 59, 74, 18, 52, 7, 33, 97, 56, 93, 29, 75, 77, 48, 25, 30, 43, 12, 58, 31, 24, 72, 48, 1, 94, 25, 36, 76, 76, 79, 98, 58, 33, 20, 21, 65, 87, 25, 32, 78, 92, 20, 49, 70, 88, 14, 95, 77, 40, 77, 99, 2, 89, 15, 48, 91, 23, 33, 98, 27, 69, 25, 85, 61, 71, 58, 86, 37, 70, 70, 33, 17, 59, 34, 72, 75, 11, 70, 94, 24, 71, 27, 82, 27, 32, 9, 41, 64, 61, 79, 84, 94, 13, 15, 23, 71, 88, 27, 7, 24, 52, 18, 45, 22, 13, 9, 20, 58, 11, 54, 7, 26, 45, 22, 43, 41, 80, 91, 31, 29, 47, 12, 36, 60, 44, 55, 6, 71, 24, 35, 28, 32, 82, 93, 51, 61, 36, 40, 96, 55, 4, 13, 19, 90, 7, 32, 26, 36, 12, 91, 84, 28, 95, 95, 4, 35, 44, 28, 98, 26, 21, 14, 8, 54, 35, 74, 25, 39, 29, 55, 64, 59, 0, 88, 93, 34, 68, 40, 65, 9, 38, 11, 14, 21, 38, 68, 76, 66, 61, 85, 45, 13, 28, 70, 67, 13, 23, 21, 23, 66, 75, 98, 71, 13, 29, 46, 25, 4, 77, 93, 19, 7, 70, 8, 61, 99, 100, 72, 3, 85, 26, 48, 13, 19, 86, 23, 44, 24, 74, 60, 75, 36, 41, 91, 73, 48, 44, 70, 21, 81, 55, 75, 8, 60, 36, 28, 84, 44, 19, 97, 48, 22, 42, 42, 11, 71, 96, 87, 33, 50, 29, 56, 64, 39, 19, 45, 41, 29, 39, 23, 64, 61, 38, 96, 62, 13, 88, 15]
        var t = _RBTree<Int>()
        XCTAssertEqual(t.first, nil)
        XCTAssertEqual(t.startIndex, t.endIndex)
        for i in nums {
            t.insert(i)
        }
        nums.sortInPlace()
        XCTAssert(t.elementsEqual(nums))
        XCTAssertEqual(t[t.indexOf(3)!], 3)
        XCTAssertEqual(t.indexOf(-1), nil)
        XCTAssertEqual(t[t.lowerBound(-5)], 0)
        XCTAssertEqual(t[t.lowerBound(32)], nums[nums.indexOf({ $0 >= 32 })!])
        XCTAssertEqual(t[t.upperBound(3)], nums[nums.indexOf({ $0 > 3 })!])
        XCTAssertEqual(t[t.upperBound(73)], nums[nums.indexOf({ $0 > 73 })!])
        XCTAssertEqual(t.upperBound(100), t.endIndex)
        XCTAssertEqual(t.lowerBound(101), t.endIndex)
        XCTAssertEqual(t.minElement(), 0)
        XCTAssertEqual(t.maxElement(), 100)

        for _ in 0..<300 {
            t.remove(t.endIndex.predecessor())
        }

        for n in nums[700..<1000] {
            t.insert(n)
        }

        XCTAssert(nums.elementsEqual(t))

        let rmi = [803, 994, 589, 286, 5, 935, 749, 553, 616, 702, 985, 133, 649, 611, 257, 340, 839, 916, 728, 597, 339, 199, 584, 16, 369, 341, 937, 905, 708, 414, 261, 617, 451, 639, 932, 823, 213, 875, 699, 37, 0, 162, 653, 377, 601, 668, 936, 694, 755, 222, 30, 125, 728, 709, 194, 551, 120, 746, 552, 858, 828, 354, 262, 679, 281, 308, 302, 330, 194, 268, 669, 852, 702, 622, 387, 488, 420, 361, 132, 813, 411, 794, 898, 385, 461, 404, 337, 231, 128, 574, 327, 122, 881, 543, 417, 275, 94, 839, 287, 805, 506, 553, 71, 254, 61, 472, 673, 271, 559, 750, 402, 283, 623, 818, 27, 272, 691, 701, 729, 507, 545, 544, 24, 80, 686, 511, 242, 598, 793, 371, 345, 615, 80, 366, 599, 69, 720, 194, 240, 226, 35, 731, 669, 739, 790, 33, 277, 682, 505, 202, 589, 534, 354, 711, 34, 457, 374, 122, 50, 427, 479, 168, 371, 220, 557, 196, 249, 681, 88, 512, 733, 240, 174, 458, 486, 222, 709, 711, 98, 693, 100, 330, 228, 122, 362, 242, 106, 95, 684, 220, 163, 156, 28, 207, 180, 460, 361, 235, 512, 426, 631, 312, 493, 528, 508, 344, 793, 475, 702, 430, 780, 768, 9, 605, 666, 240, 205, 585, 247, 184, 241, 196, 546, 637, 569, 389, 315, 193, 568, 312, 562, 367, 659, 566, 165, 331, 747, 238, 682, 635, 712, 721, 364, 699, 311, 311, 189, 1, 729, 25, 545, 659, 625, 312, 245, 688, 18, 467, 479, 221, 382, 623, 631, 333, 60, 187, 469, 341, 160, 467, 133, 111, 640, 378, 44, 409, 398, 73, 643, 215, 639, 599, 317, 160, 195, 679, 476, 554, 653, 495, 336, 224, 531, 189, 625, 96, 230, 154, 110, 379, 148, 23, 351, 350, 33, 39, 451, 649, 323, 430, 397, 347, 542, 216, 125, 28, 70, 63, 374, 300, 349, 320, 111, 47, 412, 277, 347, 608, 258, 419, 355, 200, 467, 258, 249, 538, 303, 411, 619, 185, 184, 385, 425, 599, 101, 258, 485, 154, 141, 289, 512, 388, 274, 300, 119, 554, 131, 101, 331, 537, 239, 244, 396, 582, 163, 201, 345, 411, 149, 366, 339, 167, 110, 513, 531, 498, 413, 61, 251, 195, 34, 449, 78, 279, 423, 426, 168, 412, 366, 79, 187, 397, 482, 603, 140, 494, 161, 203, 139, 21, 482, 534, 12, 19, 55, 569, 302, 324, 130, 266, 486, 541, 227, 317, 183, 376, 151, 33, 186, 365, 24, 549, 265, 442, 296, 215, 433, 237, 375, 297, 122, 460, 4, 90, 61, 390, 400, 542, 92, 387, 254, 109, 37, 218, 362, 237, 446, 382, 1, 105, 86, 121, 392, 220, 160, 474, 72, 493, 107, 533, 92, 416, 432, 138, 27, 323, 299, 532, 82, 167, 160, 241, 77, 157, 444, 314, 44, 268, 304, 318, 122, 412, 168, 195, 420, 182, 505, 346, 136, 156, 29, 330, 18, 469, 107, 496, 312, 102, 389, 268, 476, 365, 336, 426, 31, 315, 470, 189, 159, 173, 73, 466, 435, 437, 464, 219, 389, 113, 407, 328, 375, 270, 59, 265, 3, 245, 306, 233, 400, 160, 278, 356, 259, 213, 387, 6, 210, 93, 34, 310, 299, 163, 81, 369, 281, 91, 172, 257, 269, 166, 333, 198, 390, 109, 409, 239, 372, 115, 340, 59, 243, 95, 274, 16, 102, 267, 7, 309, 392, 10, 181, 357, 77, 142, 167, 24, 36, 192, 384, 417, 407, 106, 97, 101, 171, 49, 361, 239, 325, 386, 149, 366, 347, 268, 187, 80, 13, 238, 3, 163, 278, 104, 318, 218, 133, 236, 154, 198, 115, 60, 242, 22, 136, 301, 137, 383, 203, 365, 9, 366, 358, 208, 257, 13, 362, 17, 300, 183, 306, 190, 258, 52, 277, 36, 246, 344, 165, 151, 126, 242, 44, 317, 308, 19, 291, 346, 282, 212, 328, 29, 44, 306, 327, 245, 76, 200, 223, 87, 210, 40, 83, 281, 221, 50, 6, 214, 129, 308, 185, 311, 131, 239, 111, 156, 0, 116, 59, 256, 246, 301, 73, 86, 48, 245, 83, 254, 97, 178, 240, 275, 237, 89, 66, 64, 200, 241, 162, 7, 238, 252, 274, 36, 90, 83, 101, 218, 281, 105, 49, 77, 200, 60, 278, 262, 43, 168, 179, 105, 210, 252, 40, 114, 132, 15, 132, 5, 118, 235, 126, 134, 129, 249, 109, 208, 127, 120, 156, 41, 98, 40, 79, 181, 194, 147, 173, 229, 87, 118, 51, 178, 109, 138, 247, 51, 3, 51, 37, 157, 190, 6, 25, 213, 170, 218, 124, 185, 145, 95, 181, 220, 134, 25, 189, 37, 190, 0, 112, 151, 114, 28, 218, 27, 137, 90, 17, 32, 1, 19, 72, 140, 84, 37, 23, 29, 162, 130, 14, 108, 190, 7, 82, 152, 23, 172, 25, 135, 82, 88, 101, 69, 73, 186, 20, 178, 57, 172, 98, 2, 116, 68, 5, 164, 50, 26, 27, 94, 27, 154, 133, 105, 3, 1, 35, 55, 7, 142, 104, 89, 111, 17, 98, 139, 14, 24, 97, 37, 31, 88, 90, 116, 46, 97, 40, 145, 67, 15, 122, 100, 58, 81, 30, 61, 59, 90, 117, 106, 115, 30, 130, 49, 129, 105, 105, 41, 119, 2, 86, 117, 113, 101, 87, 61, 106, 30, 11, 87, 2, 71, 5, 97, 84, 54, 90, 22, 0, 35, 42, 59, 56, 70, 26, 6, 94, 78, 61, 26, 44, 43, 71, 25, 18, 19, 54, 22, 22, 3, 20, 9, 41, 15, 29, 22, 35, 21, 57, 65, 19, 3, 31, 51, 35, 45, 20, 15, 40, 6, 63, 11, 43, 27, 25, 33, 49, 55, 18, 16, 26, 51, 21, 23, 49, 24, 46, 11, 4, 15, 16, 36, 33, 25, 19, 2, 2, 23, 11, 5, 23, 22, 20, 0, 13, 8, 18, 21, 23, 2, 15, 7, 9, 2, 14, 1, 14, 11, 15, 0, 4, 8, 11, 7, 0, 1, 4, 5, 4, 1, 0, 0, 0, 0]
        for i in rmi {
            let it = t.indexOf(nums[i])!
            XCTAssertEqual(t[it], nums[i])
            t.remove(it)
            nums.removeAtIndex(i)
            XCTAssertEqual(t.count, nums.count)
            XCTAssertEqual(t.last, nums.last)
            XCTAssertEqual(t.first, nums.first)
            XCTAssert(t.elementsEqual(nums))
        }
    }

    func testRBTreeIndexing() {
        var a: _RBTree = [1, 2, 3, 4, 5]
        let i = a.indexOf(3)!, j = a.indexOf(2)!, k = a.indexOf(5)!
        a.remove(i)
        XCTAssertEqual(a[j], 2)
        XCTAssertEqual(a[k], 5)
        var b = a
        XCTAssertEqual(b[j], 2)
        XCTAssertEqual(b[k], 5)
        b.remove(j)
        XCTAssert(b.elementsEqual([1, 4, 5]))
    }

}
