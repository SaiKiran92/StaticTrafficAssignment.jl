module StaticTrafficAssignment

using CSV: read
using DataFrames: DataFrameRow, nrow
using LightGraphs: AbstractGraph, AbstractEdge
using Distributed: @distributed
using DataStructures: PriorityQueue, dequeue!
using LinearAlgebra: Diagonal

import Base: show

# i/o
export readtntpdata

# types
export
        AbstractNework, AbstractLink, AbstractZone, AbstractBush,
        has_link, add_link!, rem_link!, add_zone!, rem_zone!,
        idx, numnodes, numzones, numlinks, numsources, numsinks,
        sources, sinks, links, zones,
        outneighbors, inneighbors, outdegree, indegree, fstar, bstar,
        upn, dwn, props,
        id, issource, issink, throughflowallowed, src, net, topo_order

export SimpleNetwork, SimpleLink, SimpleZone, SimpleBush

# cost functions
export CostFunction, CostFunctionUE, CostFunctionSO, TimeFunctionContainer, BPR

# algorithms
export
        dijkstra, topologicalorder, orderednodes, acyclic,
        allornothing, msa, frankwolfe, conjugatefrankwolfe, algorithmB

include("utils.jl")

# i/o
include("data_parsers/utils.jl")
include("data_parsers/tntp_parser.jl")

# interface
include("interface.jl")

# costs
include("costfunctions/utils.jl")
include("costfunctions/time_function_container.jl")
include("costfunctions/generator.jl")
include("costfunctions/bpr.jl")

# algorithms
include("algorithms/utils.jl")
include("algorithms/shortestpaths/dijkstra.jl")
include("algorithms/topologicalorder.jl")
include("algorithms/shortestpaths/acyclic.jl")
include("algorithms/allornothing.jl")

include("algorithms/linkbased/msa.jl")
include("algorithms/linkbased/frankwolfe.jl")
include("algorithms/linkbased/conjugatefrankwolfe.jl")

include("algorithms/bushbased/algorithmB.jl")

include("SimpleNetworks/SimpleNetworks.jl")
using .SimpleNetworks

end # module StaticTrafficAssignment
