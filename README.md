# SwiftDataStructures

Pure Swift implementations of useful data structures absent from the standard library.

Data structures:

- `PriorityQueue`: a min- or max- priority queue

In alignment with Swift's standard library, all data structures are implemented as structs with copy-on-write optimisation.

Lower-level API:

- `_PriorityQueueImpl`: backing class used by `PriorityQueue`
- `_RBTree`: Red-black binary tree

