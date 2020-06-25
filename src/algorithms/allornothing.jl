function allornothing(network::AbstractNetwork,r,trips::Vector,costs::Vector)
    #nlinks = numlinks(network)
    zoneids = id.(zones(network))
    flows = zero(costs)

    _, parentvec = dijkstra(network, r, costs)
    for j in zoneids
        t = trips[j]
        if isapprox(t, 0.) | (r == j)
            continue
        end

        # Finding the shortest path
        p = pathto(parentvec, j)

        # Assigning flows
        for l in p
            flows[idx(network, l)] += t
        end

    end
    return flows
end

function allornothing(network::AbstractNetwork,
                      trips::Matrix{U},
                      costs::Vector{T};
                      basedon::Symbol = :link) where {T<:Real, U<:Real}
    # Initialization
    nnodes, nzones = numnodes(network), numzones(network)
    nlinks = length(costs)
    zonelist = zones(network)
    zoneids = id.(zonelist)

    flows = (basedon == :link) ? zeros(nlinks) : (basedon == :origin) ? zeros(nlinks, nzones) : error("Invalid input!")

    for (i,z) in enumerate(zoneids)
        if basedon == :link
            flows += allornothing(network, z, trips[z,:], costs)
        else
            flows[:,i] += allornothing(network, z, trips[z,:], costs)
        end
    end

    return flows
end

allornothing(network::AbstractNetwork, trips::AbstractMatrix{T}, costfn::CostFunction; basedon::Symbol = :link) where {T<:Real} = allornothing(network, trips, costfn(zeros(numlinks(network))).costs; basedon=basedon)
