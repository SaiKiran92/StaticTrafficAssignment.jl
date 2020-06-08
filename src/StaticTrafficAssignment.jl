module StaticTrafficAssignment

using DataFrames: nrow
using LightGraphs: Edge, add_edge!, edges, src, dst, nv, ne
using LightGraphs.Parallel: dijkstra_shortest_paths
using MetaGraphs: MetaDiGraph, set_prop!, set_props!, get_prop, props
using SparseArrays: sparse

export readtntpdata, CostFunctionGenerator, ProblemType, UEProblem, SOProblem, BPR, allornothing, frankwolfe

include("utils.jl")
include("data_loaders/TNTP_loader.jl")
include("costfunctions/generator.jl")
include("costfunctions/bprfn.jl")
include("algorithms/allornothing.jl")
include("algorithms/frankwolfe.jl")

end
