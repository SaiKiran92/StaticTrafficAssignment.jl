function allornothing(network::RoadNetwork,
                      trips::AbstractMatrix{V},
                      costs::AbstractVector{T};
                      basedon::Symbol = :link,
                      nothroughnodes = []) where {T<:Real, U<:Integer, V<:Real}
    # Initialization
    nnodes, nlinks = nv(network), ne(network)
    nzones = get_prop(network, :nzones)

    flows, addflows! = begin
        if basedon == :link
            zeros(nlinks), ((orig, dest, lidx, v) -> (flows[lidx] += v;))
        elseif basedon == :origin
            zeros(nlinks, nzones), ((orig, dest, lidx, v) -> (flows[lidx,orig] += v;))
        end
    end

    # Computing shortest paths
    _, parentmx = dijkstra(network, 1:nzones, costs; nothroughnodes=nothroughnodes)

    # Determining flows
    tripswaiting = copy(trips)
    for orig in 1:nzones
        for dest in 1:nzones
            t = tripswaiting[orig,dest]
            if isapprox(t, 0.) | (orig == dest)
                continue
            end
            tripswaiting[orig,dest] = 0.

            # Finding the shortest path
            path = findpath(parentmx, orig, dest)

            # Assigning flows
            for l in path
                addflows!(orig, dest, edgeidx(network, l...), t)
                try
                    t += tripswaiting[l[2],dest]
                    tripswaiting[l[2],dest] = 0.
                catch BoundsError
                end
            end
        end
    end
    return flows
end

allornothing(network::RoadNetwork,
             trips::AbstractMatrix{T},
             costfn::Function;
             basedon::Symbol = :link,
             nothroughnodes = []) where {T<:Real, U<:Integer} = allornothing(network, trips, costfn(zeros(ne(network))).costs; basedon=basedon, nothroughnodes=nothroughnodes)
