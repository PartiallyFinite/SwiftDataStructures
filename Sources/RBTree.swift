//
//  RBTree.swift
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

private final class _RBTreeNode<Key> : NonObjectiveCBase {

    var red = true
    var left, right: _RBTreeNode!
    weak var parent: _RBTreeNode!
    let key: Key!

    init(sentinel: ()) {
        red = false
        key = nil
        super.init()
    }

    init(key: Key, sentinel: _RBTreeNode) {
        self.key = key
        assert(sentinel.isSentinel)
        left = sentinel; right = sentinel; parent = sentinel
    }

    init(deepCopy node: _RBTreeNode, sentinel: _RBTreeNode, setParent: _RBTreeNode? = nil) {
        key = node.key
        red = node.red
        parent = setParent ?? sentinel
        super.init()
        left = node.left.isSentinel ? sentinel : _RBTreeNode(deepCopy: node.left, sentinel: sentinel, setParent: self)
        right = node.right.isSentinel ? sentinel : _RBTreeNode(deepCopy: node.right, sentinel: sentinel, setParent: self)
    }

    var isSentinel: Bool {
        return key == nil
    }

    /// Check whether the subtree (including `self`) includes `other`.
    /// - Complexity: O(log count)
    func contains(other: _RBTreeNode) -> Bool {
        assert(!other.isSentinel)
        var x = other
        while !x.isSentinel && x != self { x = x.parent }
        return x == self
    }

    /// - Complexity: O(log count)
    func subtreeMin() -> _RBTreeNode {
        guard !self.isSentinel else { return self }
        var x = self
        while !x.left.isSentinel { x = x.left }
        assert(!x.isSentinel)
        return x
    }

    /// - Complexity: O(log count)
    func subtreeMax() -> _RBTreeNode {
        guard !self.isSentinel else { return self }
        var x = self
        while !x.right.isSentinel { x = x.right }
        assert(!x.isSentinel)
        return x
    }

    /// - Complexity: Amortised O(1)
    func successor() -> _RBTreeNode? {
        if isSentinel { return nil }
        // if the right subtree exists, the successor is the smallest item in it
        if !right.isSentinel { return right.subtreeMin() }
        // the successor is the first ancestor which has self in its left subtree
        var x = self, y = x.parent
        while !y.isSentinel && x == y.right { x = y; y = x.parent }
        return y.isSentinel ? nil : y
    }

    /// - Complexity: Amortised O(1)
    func predecessor() -> _RBTreeNode? {
        if isSentinel { return nil }
        // if the left subtree exists, the predecessor is the largest item in it
        if !left.isSentinel { return left.subtreeMax() }
        // the predecessor is the first ancestor which has self in its right subtree
        var x = self, y = x.parent
        while !y.isSentinel && x == y.left { x = y; y = x.parent }
        return y.isSentinel ? nil : y
    }

}

@inline(__always)
private func ==<Key>(lhs: _RBTreeNode<Key>, rhs: _RBTreeNode<Key>) -> Bool {
    return lhs === rhs
}

extension _RBTreeNode : Equatable { }

private struct Unowned<Value : AnyObject> {
    unowned var value: Value
    init(_ value: Value) { self.value = value }
}

private enum _RBTreeIndexKind<Key> {
    case Node(Unowned<_RBTreeNode<Key>>)
    case End(last: Unowned<_RBTreeNode<Key>>)
    case Empty
}

// TODO: store strong references to nodes and a storage wrapper class; find a scheme to avoid index invalidation upon modification (until the referred element is removed)

/// Used to access elements of a `_RBTree<Key>`.
public struct _RBTreeIndex<Key> : BidirectionalIndexType {

    private typealias Node = _RBTreeNode<Key>
    private typealias Kind = _RBTreeIndexKind<Key>

    private let kind: Kind

    private init(node u: Unowned<Node>) { kind = .Node(u) }
    private init(node: Node) { self.init(node: Unowned(node)) }

    private init(end u: Unowned<Node>) {
        assert(u.value.successor() == nil, "Cannot make end index for a node that is not the end.")
        kind = .End(last: u)
    }
    private init(end last: Node) { self.init(end: Unowned(last)) }

    private init(empty: ()) {
        kind = .Empty
    }

    /// - Complexity: Amortised O(1)
    public func successor() -> _RBTreeIndex {
        switch kind {
        case .Node(let u):
            guard let suc = u.value.successor() else { return _RBTreeIndex(end: u) }
            return _RBTreeIndex(node: suc)
        case .End(_): fallthrough
        case .Empty:
            preconditionFailure("Cannot get successor of the end index.")
        }
    }

    /// - Complexity: Amortised O(1)
    public func predecessor() -> _RBTreeIndex {
        switch kind {
        case .Node(let u):
            guard let pre = u.value.predecessor() else { preconditionFailure("Cannot get predecessor of the start index.") }
            return _RBTreeIndex(node: pre)
        case .End(last: let u):
            return _RBTreeIndex(node: u)
        case .Empty:
            preconditionFailure("Cannot get predecessor of the start index.")
        }
    }

    /// Return whether the index is safe to subscript.
    public var _safe: Bool {
        if case .Node(_) = kind { return true }
        return false
    }

    private var node: Node? {
        if case .Node(let u) = kind { return u.value }
        return nil
    }

}

public func ==<Key>(lhs: _RBTreeIndex<Key>, rhs: _RBTreeIndex<Key>) -> Bool {
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

/// Implements a red-black binary tree.
///
/// Provides O(log `count`) insertion, search, and removal, as well as O(`count`) iteration.
///
/// **Index validity note**: Indexes are invalidated upon *any* modification to the data structure. Attempting to access them afterwards, or using their member functions, may result in a crash or undefined behaviour.
///
/// No runtime validity checks are performed when subscripting or removing indexes from a tree due to the overhead of implementing such checks. Using indexes from a different tree will result in undefined behaviour.
public struct _RBTree<Key : Comparable> {

    private typealias Node = _RBTreeNode<Key>

    private var sentinel = Node(sentinel: ())
    private var root: Node
    private unowned var firstNode, lastNode: Node

    public private(set) var count = 0

    /// Copy-on-write optimisation. Return `true` if the tree was copied.
    /// - Complexity: Expected O(1), O(`count`) if the structure was copied and modified.
    private mutating func ensureUnique() {
        if _slowPath(root != sentinel && !isUniquelyReferenced(&root)) {
            sentinel = Node(sentinel: ())
            root = _RBTreeNode(deepCopy: root, sentinel: sentinel)
            firstNode = root.subtreeMin()
            lastNode = root.subtreeMax()
        }
        assert(root == sentinel || isUniquelyReferenced(&root))
    }

    public init() {
        root = sentinel
        firstNode = sentinel
        lastNode = sentinel
    }

    // TODO: initialiser that takes a sorted sequence and constructs a tree in O(n) time

    /// - Complexity: O(n log n), where n = `seq.count`.
    public init<S : SequenceType where S.Generator.Element == Key>(_ seq: S) {
        self.init()
        for k in seq { insert(k) }
    }

    private func loopSentinel() {
        assert(sentinel.isSentinel)
        assert(!sentinel.red)
        assert(sentinel.left == nil)
        assert(sentinel.right == nil)
        assert(sentinel.parent == nil)
        sentinel.left = sentinel
        sentinel.right = sentinel
        sentinel.parent = sentinel
    }

    private func fixSentinel() {
        assert(sentinel.isSentinel)
        assert(!sentinel.red)
        sentinel.left = nil
        sentinel.right = nil
        sentinel.parent = nil
    }

    /// - Complexity: O(log `count`)
    public mutating func insert(k: Key) -> Index {
        ensureUnique()
        loopSentinel()

        let z = Node(key: k, sentinel: sentinel)
        do {
            var y = sentinel
            var x = root
            // find a leaf (nil) node x to replace with z, and its parent y
            while x != sentinel {
                y = x
                // move left if z sorts before x, right otherwise
                x = z.key < x.key ? x.left : x.right
            }
            z.parent = y
            // y is only nil if x is the root
            if y == sentinel { root = z }
            // attach z to left or right of y, depending on sort order
            else if z.key < y.key { y.left = z }
            else { y.right = z }
        }

        // fix violated red-black properties (rebalance the tree)
        do {
            var z = z
            while z.parent.red {
                let zp = z.parent
                assert(z.red)
                assert(zp != root) // if zp is the root, then zp is black

                let zpp = zp.parent // zp is red, so cannot be the root

                // if z's parent is a right child, swap left and right operations
                // further comments that mention left/right assume left
                let left = zp === zpp.left

                let y = left ? zpp.right : zpp.left
                if y.red {
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
                    let zp = z.parent, zpp = zp.parent
                    // case 3: z's uncle y is black and z is a left child
                    zp.red = false
                    zpp.red = true
                    left ? rotateRight(zpp) : rotateLeft(zpp)
                }
            }
            root.red = false
        }

        fixSentinel()

        count += 1
        if firstNode == sentinel || z.key < firstNode.key { firstNode = z }
        assert(firstNode.predecessor() == nil)
        if lastNode == sentinel || z.key >= lastNode.key { lastNode = z }
        assert(lastNode.successor() == nil)

        return Index(node: z)
    }

    /// - Complexity: O(log `count`)
    public mutating func remove(i: Index) {
        let z: Node
        do {
            precondition(i._safe, "Cannot remove an index that is out of range.")

            ensureUnique() // call this before creating additional references to nodes

            let node = i.node! // get the node
            
            /*
            If indexes change to remain valid after modification, indexes from previous trees will need to be located in this one using similar code to this.
            Note that if the tree has since changed, simply retracing the same path (as here) will not work.
            // the index was in a previous tree, find it in this one
            if !root.contains(node) {
                // make a path of left (true) / right turns from the root
                var path = ContiguousArray<Bool>()
                // the other tree has a different sentinel
                let old = node
                while !node.parent.isSentinel {
                    path.append(node == node.parent.left)
                    node = node.parent
                }
                node = root
                for left in path.reverse() {
                    node = left ? node.left : node.right
                }
                assert(node.key == old.key)
            }
            */
            loopSentinel()
            z = node
        }

        count -= 1
        if z == firstNode { firstNode = firstNode.successor() ?? sentinel }
        if z == lastNode { lastNode = lastNode.predecessor() ?? sentinel }

        var ored = z.red
        let x: Node

        if z.left == sentinel {
            // replace z with its only right child, or the sentinel if it has no children
            x = z.right
            transplant(z, with: z.right)
        }
        else if z.right == sentinel {
            // replace z with its only left child
            x = z.left
            transplant(z, with: z.left)
        }
        else {
            // 2 children
            let y = z.right.subtreeMin()
            ored = y.red
            // y has no left child (successor is leftmost in subtree)
            x = y.right
            // y === r, move r's right subtree under y
            if y.parent == z { x.parent = y }
            else {
                // replace y with its right subtree
                transplant(y, with: y.right)
                // move z's right subtree under y
                y.right = z.right
                y.right.parent = y
            }
            // replace z with y
            transplant(z, with: y)
            // place z's left subtree on y's left
            y.left = z.left
            y.left.parent = y
            y.red = z.red
        }

        // fix violated red-black properties (rebalance)
        if !ored {
            var x = x
            while x != root && !x.red {
                // mirror directional operations if x is a right child
                let left = x == x.parent.left

                var w: Node = left ? x.parent.right : x.parent.left
                assert(w != sentinel)
                if w.red {
                    // case 1
                    w.red = false
                    x.parent.red = true
                    left ? rotateLeft(x.parent) : rotateRight(x.parent)
                    w = left ? x.parent.right : x.parent.left
                    assert(w != sentinel)
                }
                if !w.left.red && !w.right.red {
                    // case 2
                    w.red = true
                    x = x.parent
                }
                else {
                    if left ? !w.right.red : !w.left.red {
                        // case 3
                        left ? (w.left.red = false) : (w.right.red = false)
                        w.red = true
                        left ? rotateRight(w) : rotateLeft(w)
                        w = left ? x.parent.right : x.parent.left
                        assert(w != sentinel)
                    }
                    // case 4: w's right child is red
                    assert(left ? w.right.red : w.left.red)
                    w.red = x.parent.red
                    x.parent.red = false
                    left ? (w.right.red = false) : (w.left.red = false)
                    left ? rotateLeft(x.parent) : rotateRight(x.parent)
                    x = root
                }
            }
            x.red = false
        }

        fixSentinel()

        assert((count == 0) == (root == sentinel))
        assert(firstNode.predecessor() == nil)
        assert(lastNode.successor() == nil)
    }

    /// Replace subtree `u` with subtree `v`.
    private mutating func transplant(u: Node, with v: Node) {
        if u.parent == sentinel { root = v }
        else if u == u.parent.left { u.parent.left = v }
        else { u.parent.right = v }
        v.parent = u.parent
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
        x.right = y.left
        // set b's parent
        if y.left != sentinel { y.left.parent = x }

        y.parent = x.parent
        // update x's parent
        if x.parent == sentinel { root = y }
        // check if x was left or right child and update appropriately
        else if x == x.parent.left { x.parent.left = y }
        else { x.parent.right = y }
        // put x on y's left
        y.left = x
        x.parent = y
    }

    /// Perform the reverse structure conversion to `rotateLeft`.
    private mutating func rotateRight(y: Node) {
        let x = y.left
        // move b
        y.left = x.right
        // set b's parent
        if x.right != sentinel { x.right.parent = y }

        x.parent = y.parent
        // update y's parent
        if y.parent == sentinel { root = x }
        // check if y was left or right child and update appropriately
        else if y == y.parent.left { y.parent.left = x }
        else { y.parent.right = x }
        // put y on x's right
        x.right = y
        y.parent = x
    }

}

extension _RBTree {

    /// Return the index of the first element *not less* than `k`, or `endIndex` if not found.
    /// - Complexity: O(log `count`)
    public func lowerBound(k: Key) -> Index {
        // early return if the largest element is smaller
        var nl = lastNode
        guard k <= nl.key else { return endIndex }
        var x = root
        while x != sentinel {
            if k <= x.key {
                nl = x
                x = x.left
            }
            else { x = x.right }
        }
        assert(k <= nl.key)
        assert(nl.predecessor() == nil || nl.predecessor()!.key < k)
        return Index(node: nl)
    }

    /// Return the index of the first element *greater* than `k`, or `endIndex` if not found.
    /// - Complexity: O(log `count`)
    public func upperBound(k: Key) -> Index {
        // early return if the largest element is smaller
        var nl = lastNode
        guard k < nl.key else { return endIndex }
        var x = root
        while x != sentinel {
            if k < x.key {
                nl = x
                x = x.left
            }
            else { x = x.right }
        }
        assert(k < nl.key)
        assert(nl.predecessor() == nil || nl.predecessor()!.key <= k)
        return Index(node: nl)
    }

}

extension _RBTree : CollectionType {

    public typealias Index = _RBTreeIndex<Key>

    /// - Complexity: O(1)
    public var startIndex: Index {
        guard firstNode != sentinel else { assert(count == 0 && root == sentinel); return Index(empty: ()) }
        assert(firstNode.predecessor() == nil)
        return Index(node: firstNode)
    }

    /// - Complexity: O(1)
    public var endIndex: Index {
        guard lastNode != sentinel else { assert(count == 0 && root == sentinel); return Index(empty: ()) }
        assert(lastNode.successor() == nil)
        return Index(end: lastNode)
    }

    /// - Complexity: O(1)
    public subscript(index: Index) -> Key {
        guard case .Node(let u) = index.kind else { preconditionFailure("Cannot subscript an out-of-bounds index.") }
        return u.value.key
    }

}

extension _RBTree {

    /// - Complexity: O(1)
    public var first: Key? {
        return firstNode.key
    }

    /// - Complexity: O(1)
    public var last: Key? {
        return lastNode.key
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

extension _RBTree : ArrayLiteralConvertible {

    public init(arrayLiteral elements: Key...) {
        self.init(elements)
    }

}
