
mutable struct SimpleNetwork{T<:Integer} <: AbstractNetwork{T}
    # structure
    ## forward star
    fadjlist::Vector{Vector{T}}
    fpoints::Vector{T}

    ## backward star
    badjlist::Vector{Vector{T}}
    bpoints::Vector{T}
    ## need to make sure both of the above representations are consistent

    # data
    ## zones
    zones::Vector{<:AbstractZone{T}}

    ## links
    links::Vector{<:AbstractLink{T}}
end

function SimpleNetwork(nnodes::T; zonetype=SimpleZone{T}, linktype=SimpleLink{T}) where T<:Integer
    fadjlist = [Vector{T}() for _ in one(T):nnodes]
    fpoints = ones(T, nnodes+1)

    badjlist = [Vector{T}() for _ in one(T):nnodes]
    bpoints = ones(T, nnodes+1)

    zones = Vector{zonetype}()

    links = Vector{linktype}()

    SimpleNetwork{T}(fadjlist, fpoints, badjlist, bpoints, zones, links)
end

function SimpleNetwork(nnodes::T, links::Vector{<:AbstractLink{T}}, zones::Vector{<:AbstractZone{T}}) where {T<:Integer}
    net = SimpleNetwork(nnodes)

    for link in links
        add_link!(net, link)
    end

    for zone in zones
        add_zone!(net, zone)
    end
    net
end

function SimpleNetwork(nnodes::T, linkdata, zonedata, args...; linktype::Type{<:AbstractLink{T}}=SimpleLink{T}, zonetype::Type{<:AbstractZone{T}}=SimpleZone{T}, kwargs...) where {T<:Integer}
    links = [linktype(row, args...; kwargs...) for row in eachrow(linkdata)]
    zones = [zonetype(row, args...; kwargs...) for row in eachrow(zonedata)]
    SimpleNetwork(nnodes, links, zones)
end

function add_zone!(net::SimpleNetwork{T}, z::AbstractZone{T}) where T<:Integer
    # check if z's index already taken
    (id(z) ∉ id.(net.zones)) || ((@warn "Zone ID $(id(z)) already taken! New zone not added."); return false)
    (id(z) <= numnodes(net)) || ((@warn "Zone ID $(id(z)) greater than the number of nodes! New zone not added."); return false)
    push!(net.zones, z)
    return true
end

function rem_zone!(net::SimpleNetwork{T}, i::T) where T<:Integer
    for (zi,z) in enumerate(net.zones)
        if i==id(z)
            deleteat!(net.zones, zi)
            return true
        end
    end
    return false
end

function add_link!(net::SimpleNetwork{T}, l::AbstractLink{T}) where T<:Integer
    # check if l's index already taken
    (idx(net, l) in idx.(Ref(net), net.links)) && return false
    # update star representations
    i, j = upn(l), dwn(l)

    @inbounds list = net.badjlist[j]
    index = searchsortedfirst(list, i)
    insert!(list, index, i)
    net.bpoints[(j+1):end] .+= 1

    @inbounds list = net.fadjlist[i]
    index = searchsortedfirst(list, j)
    insert!(list, index, j)
    net.fpoints[(i+1):end] .+= 1

    # add to list
    insert!(net.links, net.fpoints[i]-1+index, l)

    return true
end

function rem_link!(net::SimpleNetwork{T}, idx::U) where {T<:Integer, U<:Integer}
    try
        l = net.links[idx]
        i, j = upn(l), dwn(l)
        deleteat!(net, idx)
        deletesortedfirst!(net.fadjlist[i], j)
        net.fpoints[(i+1):end] .-= 1
        deletesortedfirst!(net.badjlist[j], i)
        net.bpoints[(j+1):end] .-= 1
        return true
    catch
        return false
    end
end

eltype(x::SimpleNetwork{T}) where T = T

has_link(net::SimpleNetwork{T}, i::U, j::U) where {T<:Integer, U<:Integer} = (j in net.fadjlist[i])

idx(net::SimpleNetwork{T}, i::U, j::U) where {T<:Integer, U<:Integer} = has_link(net, i, j) ? net.fpoints[i]-1+searchsortedfirst(net.fadjlist[i],j) : -1
idx(net::SimpleNetwork{T}, l::AbstractLink{U}) where {T<:Integer, U<:Integer} = idx(net, upn(l), dwn(l))
idx(net::SimpleNetwork{T}, t::Tuple{U,U}) where {T<:Integer, U<:Integer} = idx(net, t...)

numnodes(net::SimpleNetwork) = length(net.fpoints)-1
numzones(net::SimpleNetwork) = length(net.zones)
numlinks(net::SimpleNetwork) = length(net.links)
numsources(net::SimpleNetwork) = sum(issource.(net.zones))
numsinks(net::SimpleNetwork) = sum(issink.(net.zones))

sources(net::SimpleNetwork) = id.(filter(issource, net.zones))
sinks(net::SimpleNetwork) = id.(filter(issink, net.zones))
zones(net::SimpleNetwork) = net.zones
links(net::SimpleNetwork) = net.links

outneighbors(net::SimpleNetwork{T}, i::U) where {T<:Integer, U<:Integer} = net.fadjlist[i]
inneighbors(net::SimpleNetwork{T}, j::U) where {T<:Integer, U<:Integer} = net.badjlist[j]

outdegree(net::SimpleNetwork{T}, i::U) where {T<:Integer, U<:Integer} = length(net.fadjlist[i])
indegree(net::SimpleNetwork{T}, j::U) where {T<:Integer, U<:Integer} = length(net.badjlist[j])

fstar(net::SimpleNetwork{<:Integer}) = (adjlist = net.fadjlist, points = net.fpoints)
bstar(net::SimpleNetwork{<:Integer}) = (adjlist = net.badjlist, points = net.bpoints)

issource(net::SimpleNetwork{T}, i::U) where {T<:Integer, U<:Integer} = issource(net.zones[i])
issink(net::SimpleNetwork{T}, i::U) where {T<:Integer, U<:Integer} = issink(net.zones[i])
throughflowallowed(net::SimpleNetwork{T}, i::U) where {T<:Integer, U<:Integer} = throughflowallowed(net.zones[i])
props(net::SimpleNetwork{T}, i::U) where {T<:Integer, U<:Integer} = props(net.zones[i])
