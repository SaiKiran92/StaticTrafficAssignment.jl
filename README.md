# StaticTrafficAssignment

[![Build Status](https://travis-ci.org/SaiKiran92/StaticTrafficAssignment.jl.svg?branch=master)](https://travis-ci.org/SaiKiran92/StaticTrafficAssignment.jl)
[![Coverage](https://codecov.io/gh/SaiKiran92/StaticTrafficAssignment.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SaiKiran92/StaticTrafficAssignment.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SaiKiran92.github.io/StaticTrafficAssignment.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SaiKiran92.github.io/StaticTrafficAssignment.jl/dev)


This package contains functions to load road network data in TNTP format. Check out [this GitHub repository](https://github.com/bstabler/TransportationNetworks) to learn more about the format and download some standard networks.


## Installation
Installation is straightforward: enter Pkg mode by hitting `]`, and then
```julia-repl
(v1.0) pkg> add StaticTrafficAssignment
```

## Available
### Algorithms
1. All-Or-Nothing
2. Method of Successive Averages
3. Frank-Wolfe
4. Conjugate Frank-Wolfe
5. Algorithm B

### Other supported features
1. Custom delay functions

## To Do
- Implement a couple more bush-based algorithms.
- Provide support for user-heterogeneity (or multi-class models) and some advanced applications of traffic assignment problems.

## Documentation and Testing
Will be made available soon.
