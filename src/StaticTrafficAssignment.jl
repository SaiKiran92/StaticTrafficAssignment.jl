module StaticTrafficAssignment

using DataFrames: nrow
using LightGraphs: Edge, add_edge!
using MetaGraphs: MetaDiGraph, set_prop!, set_props!

export readtntpdata

include("data_loaders/TNTP_loader.jl")

end
