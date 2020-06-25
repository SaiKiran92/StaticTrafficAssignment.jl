function topologicalorder(network::AbstractNetwork{T}) where T<:Integer
    nnodes = numnodes(network)
    nodeorder = zeros(T, nnodes)
    deg = indegree.(Ref(network), 1:nnodes)

    S = filter((i) -> deg[i] == 0, 1:nnodes)
    if length(S) == 0
        @warn "No nodes with no incoming links. Cannot define a topological order!"
    elseif length(S) > 1
        @warn "More than one nodes with zero indegree. Topological order not unique!"
    end
    o = 0
    while length(S) > 0
        i = pop!(S)
        o += 1
        nodeorder[i] = o
        for j in outneighbors(network, i)
            deg[j] -= 1
            if deg[j] == 0
                push!(S, j)
            end
        end
    end
    if (o != nnodes)
        @warn "Network is not acyclic. Incomplete topological order!"
    end

    nodeorder
end

orderednodes(network::AbstractNetwork) = invperm(topologicalorder(network))
