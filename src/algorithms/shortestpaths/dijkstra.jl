function dijkstra(net::AbstractNetwork,
                  src::T,
                  linkcosts::AbstractVector{U}) where {T<:Integer, U<:Real}

    nnodes = numnodes(net)
    costs = fill(typemax(U), nnodes)
    parentmx = zeros(T, nnodes)

    P = PriorityQueue{T,U}()
    P[src] = costs[src] = 0
    parentmx[src] = 0

    while !isempty(P)
        u = dequeue!(P)
        for v in outneighbors(net, u)
            lidx = idx(net, u, v)
            alt = costs[u] + linkcosts[lidx]
            if (costs[v] > alt) && (throughflowallowed(net, u) || (u == src))
                P[v] = costs[v] = alt
                parentmx[v] = u
            end
        end
    end

    return (costs = costs, parentmx = parentmx)
end

function dijkstra(net::AbstractNetwork,
                  srcs::AbstractVector{T},
                  linkcosts::AbstractVector{U}) where {T<:Integer, U<:Real}

    nsrcs = length(srcs)
    nnodes = numnodes(net)
    costs, parentmx = zeros(U, nsrcs, nnodes), zeros(T, nsrcs, nnodes)
    @sync @distributed for i in 1:nsrcs
        res = dijkstra(net, srcs[i], linkcosts)
        costs[i,:] = res[1]
        parentmx[i,:] = res[2]
    end

    return (costs = costs, parentmx = parentmx)
end
