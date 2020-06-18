# StaticTrafficAssignment

[![Build Status](https://travis-ci.org/SaiKiran92/StaticTrafficAssignment.jl.svg?branch=master)](https://travis-ci.org/SaiKiran92/StaticTrafficAssignment.jl)
[![Coverage](https://codecov.io/gh/SaiKiran92/StaticTrafficAssignment.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SaiKiran92/StaticTrafficAssignment.jl)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://SaiKiran92.github.io/StaticTrafficAssignment.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://SaiKiran92.github.io/StaticTrafficAssignment.jl/dev)


This package contains functions to load road network data in TNTP format. Check out [this GitHub repository](https://github.com/bstabler/TransportationNetworks) to learn more about the format and download some standard networks.

I have implemented four algorithms: All-Or-Nothing and Method of Successive Averages, Frank-Wolfe and Conjugate Frank-Wolfe. More will be coming soon.

Custom delay functions are supported. Both UE and SO assignments can be easily calculated.

Sorry about the lack of documentation. But I think the package is pretty readable for anyone with some experience with Julia. Will try to add a couple more examples soon.

## Coming soon
### Algorithms

- Biconjugate Frank-Wolfe
- Algorithm B
