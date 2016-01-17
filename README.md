# SwiftDataStructures

Pure Swift implementations of useful data structures absent from the standard library.

Data structures:

- `PriorityQueue`: a min- or max- priority queue
- `OrderedSet`: an ordered set
- `OrderedDictionary`: an ordered dictionary
- `List`: doubly-linked list
- `Deque`: double-ended queue with O(1) random access

In alignment with Swift's standard library, all data structures are implemented as structs with copy-on-write optimisation.

Lower-level API:

- `_PriorityQueueImpl`: backing class used by `PriorityQueue`
- `_RBTree`: Red-black binary tree

