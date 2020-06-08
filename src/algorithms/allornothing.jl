function allornothing(network::MetaDiGraph, trips::Array{<:Real,2}, costs::Array)
    # Initialization
    nnodes = nv(network)
    nzones = get_prop(network, :nzones)
    flows = zeros(ne(network))

    # Making cost matrix
    costmx = sparse([], [], Float64[], nnodes, nnodes)
    #costmx = zeros(nnodes, nnodes)
    for (c,e) in zip(costs,edges(network))
        costmx[src(e),dst(e)] = c
    end
    flowmx = zero(costmx) # for computational purposes

    # Computing shortest paths
    shortpaths = dijkstra_shortest_paths(network, 1:nzones, costmx)
    parentmx = shortpaths.parents

    # Determining flows
    tripswaiting = copy(trips)
    for orig in 1:nzones
        for dest in 1:nzones
            t = tripswaiting[orig,dest]
            if isapprox(t, 0.)
                continue
            end
            tripswaiting[orig,dest] = 0.

            # Finding the shortest path
            path = [dest]
            currnode = dest
            while currnode != orig
                prevnode = parentmx[orig,currnode]
                currnode = prevnode
                push!(path, currnode)
            end

            # Assigning flows
            currnode = orig
            for nextnode in path[(end-1):-1:1]
                flowmx[currnode, nextnode] += t
                t += tripswaiting[nextnode,dest]
                tripswaiting[nextnode,dest] = 0.
                currnode = nextnode
            end
        end
    end

    for (i,e) in enumerate(edges(network))
        flows[i] = flowmx[src(e),dst(e)]
    end

    return flows
end

allornothing(network::MetaDiGraph, trips::Array{<:Real,2}, costfn::Function) = allornothing(network, trips, costfn(zeros(ne(network))).costs)
