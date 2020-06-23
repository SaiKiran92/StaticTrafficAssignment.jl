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
        add_link!, rem_link!, add_zone!, rem_zone!,
        idx, numzones, numlinks, numsources, numsinks,
        sources, sinks, links, zones,
        outneighbors, inneighbors, outdegree, indegree, fstar, bstar,
        upn, dwn, props,
        id, issource, issink, throughflowallowed, src, net

export
        SimpleNetwork, SimpleLink, SimpleZone, SimpleBush

# cost functions
export CostFunction, CostFunctionUE, CostFunctionSO, TimeFunctionContainer, BPR

# algorithms
export dijkstra, allornothing, msa, frankwolfe, conjugatefrankwolfe, algorithmB

include("utils.jl")

# i/o
include("data_parsers/utils.jl")
include("data_parsers/tntp_parser.jl")

# interface and simple types
include("interface.jl")

include("SimpleNetworks/SimpleNetworks.jl")
using .SimpleNetworks

#import SimpleNetworks

#include("simplenetworks/simplelink.jl")
#include("simplenetworks/simplezone.jl")
#include("simplenetworks/simplenetwork.jl")

# costs
include("costfunctions/utils.jl")
include("costfunctions/time_function_container.jl")
include("costfunctions/generator.jl")
include("costfunctions/bpr.jl")

# algorithms
include("algorithms/utils.jl")
include("algorithms/shortestpaths/dijkstra.jl")
include("algorithms/allornothing.jl")

include("algorithms/linkbased/msa.jl")
include("algorithms/linkbased/frankwolfe.jl")
include("algorithms/linkbased/conjugatefrankwolfe.jl")

include("algorithms/bushbased/algorithmB.jl")


end # module StaticTrafficAssignment
