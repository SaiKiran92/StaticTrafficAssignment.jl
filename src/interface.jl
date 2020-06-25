
# Similar to the interface of LightGraphs
_NI(m) = error("Not implemented: $m")

"""
    AbstractNetwork

An abstract type for road networks with integer type node indexing.
"""
abstract type AbstractNetwork{T<:Integer} <: AbstractGraph{T} end

"""
    AbstractLink

An abstract type for road links connecting two nodes.
"""
abstract type AbstractLink{T<:Integer} <: AbstractEdge{T} end

"""
    AbstractZone

An abstract type for zones/centroids, which are nodes with some additional information.
"""
abstract type AbstractZone{T<:Integer} end

"""
    AbstractBush

An abstract type for bushes used in bush/origin-based assignment algorithms.
"""
abstract type AbstractBush{T<:Integer} <: AbstractNetwork{T} end

abstract type CostFunction <: Function end

#
# Interface for AbstractZones
#

id(z::AbstractZone) = _NI("id")
issource(z::AbstractZone) = _NI("issource")
issink(z::AbstractZone) = _NI("issink")
throughflowallowed(z::AbstractZone) = _NI("throughflowallowed")
props(z::AbstractZone) = _NI("props")

#
# Interface for AbstractLink
#

upn(l::AbstractLink) = _NI("upn") # upnode
dwn(l::AbstractLink) = _NI("dwn") # downnode
props(l::AbstractLink) = _NI("props")

#
# Interface for AbstractNetwork
#

has_link(n::AbstractNetwork, i, j) = _NI("has_link")

idx(n::AbstractNetwork, args...; kwargs...) = _NI("idx")

numnodes(n::AbstractNetwork) = _NI("numnodes")
numzones(n::AbstractNetwork) = _NI("numzones")
numlinks(n::AbstractNetwork) = _NI("numlinks")
numsources(n::AbstractNetwork) = _NI("numsources")
numsinks(n::AbstractNetwork) = _NI("numsinks")

sources(n::AbstractNetwork) = _NI("sources")
sinks(n::AbstractNetwork) = _NI("sinks")
zones(n::AbstractNetwork) = _NI("zones")
links(n::AbstractNetwork) = _NI("links")

outneighbors(net::AbstractNetwork{T}, i::U) where {T<:Integer, U<:Integer} = _NI("outneighbors")
inneighbors(net::AbstractNetwork{T}, j::U) where {T<:Integer, U<:Integer} = _NI("inneighbors")

outdegree(n::AbstractNetwork) = _NI("outdegree")
indegree(n::AbstractNetwork) = _NI("indegree")

fstar(n::AbstractNetwork) = _NI("fstar")
bstar(n::AbstractNetwork) = _NI("bstar")

issource(net::AbstractNetwork{T}, i::U) where {T<:Integer, U<:Integer} = _NI("issource")
issink(net::AbstractNetwork{T}, i::U) where {T<:Integer, U<:Integer} = _NI("issink")
throughflowallowed(net::AbstractNetwork{T}, i::U) where {T<:Integer, U<:Integer} = _NI("throughflowallowed")
props(net::AbstractNetwork{T}, i::U) where {T<:Integer, U<:Integer} = _NI("props")

add_zone!(net, z) = _NI("add_zone!")
add_zone!(net::AbstractNetwork{T}, zonetype::Type{<:AbstractZone{T}}, args...; kwargs...) where T<:Integer = add_zone!(net, zonetype(args...; kwargs...))

rem_zone!(net, i) = _NI("rem_zone!")
rem_zone!(net::AbstractNetwork{T}, z::AbstractZone{T}) where T<:Integer = rem_zone!(net, id(z))

add_link!(net, l) = _NI("add_link!")
add_link!(net::AbstractNetwork{T}, linktype::Type{<:AbstractLink{T}}, args...; kwargs...) where T<:Integer = add_link!(net, linktype(args...; kwargs...))

rem_link!(net, i) = _NI("rem_link!")
rem_link!(net::AbstractNetwork{T}, l::AbstractLink{T}) where T<:Integer = rem_link!(net, idx(net, l))

#
# Interface for AbstractBush
#

src(b::AbstractBush) = _NI("src")
net(b::AbstractBush) = _NI("net")

show(io::IO, net::AbstractNetwork) = print(io, "Network $(numnodes(net)) $(numlinks(net)) $(numzones(net))")
show(io::IO, l::AbstractLink) = print(io, "Link $(upn(l)) => $(dwn(l))")
show(io::IO, z::AbstractZone) = print(io, "Zone $(id(z)) $(issource(z)) $(issink(z)) $(throughflowallowed(z))")
show(io::IO, b::AbstractBush) = print(io, "Bush $(src(b)) $(numnodes(b)) $(numlinks(b)) $(numzones(b))")
