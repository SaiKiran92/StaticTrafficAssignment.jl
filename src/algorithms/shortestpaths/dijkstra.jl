function dijkstra(network::MetaDiGraph,
                  origin::U,
                  linkcosts::AbstractVector{T};
                  nothroughnodes = []) where {T<:Real, U<:Integer}

    nnodes = nv(network)
    costlabels = fill(typemax(T), nnodes)
    parents = zeros(U, nnodes)

    P = PriorityQueue{U,T}()
    P[origin] = costlabels[origin] = 0
    parents[origin] = 0

    while !isempty(P)
        u = dequeue!(P)
        for v in outneighbors(network, u)
            lidx = edgeidx(network, u, v)
            alt = costlabels[u] + linkcosts[lidx]
            if (costlabels[v] > alt) & ((u ∉ nothroughnodes) | (u == origin))
                P[v] = costlabels[v] = alt #costlabels[u] + linkcosts[lidx]
                parents[v] = u
            end
        end
    end

    return (costs = costlabels, parents = parents)
end

function dijkstra(network::MetaDiGraph,
                  origins::AbstractVector{U},
                  linkcosts::AbstractVector{T};
                  nothroughnodes = []) where {T<:Real, U<:Integer}

    norigins = length(origins)
    costlabels, parents = zeros(T, norigins, nv(network)), zeros(U, norigins, nv(network))
    @sync @distributed for i in 1:norigins
        res = dijkstra(network, origins[i], linkcosts)
        costlabels[i,:] = res[1]
        parents[i,:] = res[2]
    end

    return (costs = costlabels, parents = parents)
end
