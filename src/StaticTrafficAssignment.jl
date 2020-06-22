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
        AbstractNework, AbstractLink, AbstractZone,
        SimpleNetwork, SimpleLink, SimpleZone

export
        add_link!, rem_link!, add_zone!, rem_zone!,
        idx, numzones, numlinks, numsources, numsinks,
        sources, sinks, links, zones,
        outneighbors, inneighbors, outdegree, indegree, fstar, bstar,
        upn, dwn, props,
        id, issource, issink, throughflowallowed

export CostFunction, CostFunctionUE, CostFunctionSO, TimeFunctionContainer, BPR

export dijkstra, allornothing, msa, frankwolfe, conjugatefrankwolfe

include("utils.jl")

# i/o
include("data_parsers/utils.jl")
include("data_parsers/tntp_parser.jl")

# interface and simple types
include("interface.jl")

include("simplenetworks/simplelink.jl")
include("simplenetworks/simplezone.jl")
include("simplenetworks/simplenetwork.jl")

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

end # module StaticTrafficAssignment
