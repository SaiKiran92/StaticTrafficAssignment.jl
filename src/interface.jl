
abstract type AbstractNetwork{T<:Integer} <: AbstractGraph{T} end
abstract type AbstractLink{T<:Integer} <: AbstractEdge{T} end
abstract type AbstractZone{T} end

add_zone!(net::AbstractNetwork{T}, zonetype::Type{<:AbstractZone{T}}, args...; kwargs...) where T<:Integer = add_zone!(net, zonetype(args...; kwargs...))
rem_zone!(net::AbstractNetwork{T}, z::AbstractZone{T}) where T<:Integer = rem_zone!(net, id(z))

add_link!(net::AbstractNetwork{T}, linktype::Type{<:AbstractLink{T}}, args...; kwargs...) where T<:Integer = add_link!(net, linktype(args...; kwargs...))
rem_link!(net::AbstractNetwork{T}, l::AbstractLink{T}) where T<:Integer = rem_link!(net, idx(net, l))

show(io::IO, net::AbstractNetwork{T}) where T = print(io, "Network $(numnodes(net)) $(numlinks(net)) $(numzones(net))")
show(io::IO, l::AbstractLink) = print(io, "Link $(upn(l)) => $(dwn(l))")
show(io::IO, z::AbstractZone) = print(io, "Zone $(id(z)) $(issource(z)) $(issink(z)) $(throughflowallowed(z))")
