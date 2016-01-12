//
//  RedBlackTree.swift
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

private final class _RedBlackTreeNode<Key> : NonObjectiveCBase {

    var red = true
    var left, right: _RedBlackTreeNode?
    weak var parent: _RedBlackTreeNode?
    let key: Key

    init(key: Key) {
        self.key = key
    }

    init(deepCopy node: _RedBlackTreeNode, setParent p: _RedBlackTreeNode?) {
        key = node.key
        red = node.red
        parent = p
        super.init()
        if let l = node.left { left = _RedBlackTreeNode(deepCopy: l, setParent: self) }
        if let r = node.right { right = _RedBlackTreeNode(deepCopy: r, setParent: self) }
    }

    /// - Complexity: O(log count)
    func subtreeMin() -> _RedBlackTreeNode {
        var x = self
        while let l = x.left { x = l }
        return x
    }

    /// - Complexity: O(log count)
    func subtreeMax() -> _RedBlackTreeNode {
        var x = self
        while let r = x.right { x = r }
        return x
    }

    /// - Complexity: Amortised O(1)
    func successor() -> _RedBlackTreeNode? {
        // if the right subtree exists, the successor is the smallest item in it
        if let r = right { return r.subtreeMin() }
        // the successor is the first ancestor which has self in its left subtree
        var x = self, y = self.parent
        while x === y?.right { x = y!; y = x.parent }
        return y
    }

    /// - Complexity: Amortised O(1)
    func predecessor() -> _RedBlackTreeNode? {
        // if the left subtree exists, the predecessor is the largest item in it
        if let l = left { return l.subtreeMax() }
        // the predecessor is the first ancestor which has self in its right subtree
        var x = self, y = self.parent
        while x === y?.left { x = y!; y = x.parent }
        return y
    }

}

private struct Unowned<Value : AnyObject> {
    unowned var value: Value
    init(_ value: Value) { self.value = value }
}

private enum _RedBlackTreeIndexKind<Key> {
    case Node(Unowned<_RedBlackTreeNode<Key>>)
    case End(last: Unowned<_RedBlackTreeNode<Key>>)
    case Empty
}

public struct _RedBlackTreeIndex<Key> : BidirectionalIndexType {

    private typealias Node = _RedBlackTreeNode<Key>
    private typealias Kind = _RedBlackTreeIndexKind<Key>

    private let kind: Kind

    private init(node u: Unowned<Node>) { kind = .Node(u) }
    private init(node: Node) { self.init(node: Unowned(node)) }

    private init(end u: Unowned<Node>) {
        assert(u.value.successor() == nil, "Cannot make end index for a node that is not the end.")
        kind = .End(last: u)
    }
    private init(end last: Node) { self.init(end: Unowned(last)) }

    private init(empty: ()) { kind = .Empty }

    /// - Complexity: Amortised O(1)
    public func successor() -> _RedBlackTreeIndex {
        switch kind {
        case .Node(let u):
            guard let suc = u.value.successor() else { return _RedBlackTreeIndex(end: u) }
            return _RedBlackTreeIndex(node: suc)
        case .End(_): fallthrough
        case .Empty:
            preconditionFailure("Cannot get successor of the end index.")
        }
    }

    /// - Complexity: Amortised O(1)
    public func predecessor() -> _RedBlackTreeIndex {
        switch kind {
        case .Node(let u):
            guard let pre = u.value.predecessor() else { preconditionFailure("Cannot get predecessor of the start index.") }
            return _RedBlackTreeIndex(node: pre)
        case .End(last: let u):
            return _RedBlackTreeIndex(end: u)
        case .Empty:
            preconditionFailure("Cannot get predecessor of the start index.")
        }
    }

    /// Return whether the index is safe to subscript.
    public var _safe: Bool {
        if case .Node(_) = kind { return true }
        return false
    }

}

public func ==<Key>(lhs: _RedBlackTreeIndex<Key>, rhs: _RedBlackTreeIndex<Key>) -> Bool {
    switch (lhs.kind, rhs.kind) {
    case (.Node(let a), .Node(let b)): return a.value === b.value
    case (.End(let a), .End(let b)): return a.value === b.value
    case (.Empty, .Empty): return true
    default: return false
    }
}

/*
 A red-black tree is a binary tree that satisfies the following red-black properties:
 1. Every node is either red or black.
 2. The root is black.
 3. Every leaf (nil) is black.
 4. If a node is red, then both its children are black.
 5. For each node, all simple paths from the node to descendant leaves contain the same number of black nodes.
 */
public struct _RedBlackTree<Key : Comparable> {

    private typealias Node = _RedBlackTreeNode<Key>

    private var root: Node?
    private weak var firstNode, lastNode: Node?

    public private(set) var count = 0

    private mutating func ensureUnique() {
        if root != nil && !isUniquelyReferenced(&root!) {
            root = _RedBlackTreeNode(deepCopy: root!, setParent: nil)
        }
    }

    public mutating func insert(k: Key) -> Index {
        ensureUnique()

        let z = Node(key: k)
        do {
            var y = root?.parent
            assert(y == nil)
            var x = root
            // find a leaf (nil) node x to replace with z, and its parent y
            while x != nil {
                y = x
                // move left if z sorts before x, right otherwise
                x = z.key < x!.key ? x!.left : x!.right
            }
            z.parent = y
            if let y = y {
                // attach z to left or right of y, depending on sort order
                if z.key < y.key { y.left = z }
                else { y.right = z }
            }
            else { root = z } // y is only nil if x is the root
        };

        // fix violated red-black properties (rebalance the tree)
        do {
            var z = z
            while let zp = z.parent where zp.red {
                assert(z.red)
                assert(zp !== root) // if zp is the root, then zp is black

                let zpp = zp.parent! // zp is red, so cannot be the root

                // if z's parent is a right child, swap left and right operations
                // further comments that mention left/right assume left
                let left = zp === zpp.left

                if let y = left ? zpp.right : zpp.left where y.red {
                    // case 1: z's uncle y is red
                    zp.red = false
                    y.red = false
                    zpp.red = true
                    z = zpp
                }
                else {
                    // if z is a right child
                    if z === (left ? zp.right : zp.left) {
                        // case 2: z's uncle y is black and z is a right child
                        z = zp
                        left ? rotateLeft(z) : rotateRight(z)
                        // z is now a left child
                    }
                    let zp = z.parent!, zpp = zp.parent!
                    // case 3: z's uncle y is black and z is a left child
                    zp.red = false
                    zpp.red = true
                    left ? rotateRight(zpp) : rotateLeft(zpp)
                }
            }
            root!.red = false
        }

        count += 1
        if firstNode == nil || z.key < firstNode!.key { firstNode = z }
        assert(firstNode?.predecessor() == nil)
        if lastNode == nil || z.key >= lastNode!.key { lastNode = z }
        assert(lastNode?.successor() == nil)

        return Index(node: z)
    }

    /**
     Perform the following structure conversion:

           |                |
           x                y
          / \      ->      / \
         a   y            x   c
            / \          / \
           b   c        a   b
     */
    private mutating func rotateLeft(x: Node) {
        // ensureUnique() is not called here since this function does not affect any externally visible interface (elements remain in same order, index objects stay valid, etc.)

        let y = x.right
        // move b
        x.right = y?.left
        // set b's parent
        x.right?.parent = x

        y?.parent = x.parent
        // if x was not the root, update its parent
        if let xp = x.parent {
            // check if x was left or right child and update appropriately
            if x === xp.left { xp.left = y }
            else { xp.right = y }
        }
        // x was the root
        else { root = y }
        // put x on y's left
        y?.left = x
        x.parent = y
    }

    /// Perform the reverse structure conversion to `rotateLeft`.
    private mutating func rotateRight(y: Node) {
        let x = y.left
        // move b
        y.left = x?.right
        // set b's parent
        y.left?.parent = y

        x?.parent = y.parent
        // if y was not the root, update its parent
        if let yp = y.parent {
            // check if y was left or right child and update appropriately
            if y === yp.left { yp.left = x }
            else { yp.right = x }
        }
        // y was the root
        else { root = x }
        // put y on x's right
        x?.right = y
        y.parent = x
    }

}

extension _RedBlackTree {

    /// Return the index of the first element *not less* than `k`, or `endIndex` if not found.
    /// - Complexity: O(log `count`)
    public func lowerBound(k: Key) -> Index {
        // early return if the largest element is smaller
        guard var nl = lastNode where k <= nl.key else { return endIndex }
        var x = root
        while x != nil {
            if k <= x!.key {
                nl = x!
                x = x!.left
            }
            else { x = x!.right }
        }
        assert(k <= nl.key)
        assert(nl.predecessor() == nil || nl.predecessor()!.key < k)
        return Index(node: nl)
    }

    /// Return the index of the first element *greater* than `k`, or `endIndex` if not found.
    /// - Complexity: O(log `count`)
    public func upperBound(k: Key) -> Index {
        // early return if the largest element is smaller
        guard var nl = lastNode where k < nl.key else { return endIndex }
        var x = root
        while x != nil {
            if k < x!.key {
                nl = x!
                x = x!.left
            }
            else { x = x!.right }
        }
        assert(k < nl.key)
        assert(nl.predecessor() == nil || nl.predecessor()!.key <= k)
        return Index(node: nl)
    }

}

extension _RedBlackTree : CollectionType {

    public typealias Index = _RedBlackTreeIndex<Key>

    /// - Complexity: O(1)
    public var startIndex: Index {
        guard let start = firstNode else { return Index(empty: ()) }
        return Index(node: start)
    }

    /// - Complexity: O(1)
    public var endIndex: Index {
        guard let last = lastNode else { return Index(empty: ()) }
        return Index(end: last)
    }

    /// - Complexity: O(1)
    public subscript(index: Index) -> Key {
        guard case .Node(let u) = index.kind else { preconditionFailure("Cannot subscript an out-of-bounds index.") }
        return u.value.key
    }

}

extension _RedBlackTree {

    /// - Complexity: O(1)
    public var first: Key? {
        return firstNode?.key
    }

    /// - Complexity: O(1)
    public var last: Key? {
        return lastNode?.key
    }

    /// - Complexity: O(1)
    public func maxElement() -> Key? {
        return last
    }

    /// - Complexity: O(1)
    public func minElement() -> Key? {
        return first
    }

    /// - Complexity: O(log `count`)
    public func indexOf(element: Key) -> Index? {
        let i = lowerBound(element)
        return i._safe && self[i] == element ? i : nil
    }

}
