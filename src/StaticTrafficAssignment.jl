module StaticTrafficAssignment

using DataFrames: nrow
using LinearAlgebra: Diagonal
using LightGraphs: Edge, add_edge!, edges, src, dst, nv, ne, inneighbors, outneighbors, indegree, outdegree
using MetaGraphs: MetaDiGraph, set_prop!, set_props!, get_prop, props
using DataStructures: PriorityQueue, dequeue!
using Distributed: @distributed

# input and costs
export
        RoadNetwork,
        readtntpdata,
        CostFunctionGenerator,
        ProblemType,
        UEProblem,
        SOProblem,
        BPR

# algorithms
export
        dijkstra,
        allornothing,
        mosa,
        frankwolfe,
        conjugatefrankwolfe

RoadNetwork = MetaDiGraph

include("utils.jl")
include("data_parsers/tntp_parser.jl")

include("costfunctions/generator.jl")
include("costfunctions/bprfn.jl")

include("algorithms/shortestpaths/dijkstra.jl")
include("algorithms/allornothing.jl")
include("algorithms/linkbased/mosa.jl")
include("algorithms/linkbased/frankwolfe.jl")
include("algorithms/linkbased/conjugatefrankwolfe.jl")
include("algorithms/bushbased/utils.jl")
#include("algorithms/bushbased/algorithmB.jl")

end
