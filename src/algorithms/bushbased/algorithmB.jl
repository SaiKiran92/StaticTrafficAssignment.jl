function algorithmB(net::AbstractNetwork{T}, trips::AbstractMatrix, costfn::CostFunction; bushtype::AbstractBush{T}=SimpleBush{T},  errtol=1e-4) where {T<:Integer}
    nzones = numzones(net)

    # initialize bushes
    bushes = [bushtype(net, r, costfn) for r in 1:nzones]

    # iterate
    nchange = 1
    while nchange != 0
        ## equilibrate bushes
        err = 1.
        while err > errtol
            for r in zones(net)

            end

            # calculate new error
        end

        ## update bushes
        nchange = 0
        for bush in bushes

        end
    end
end

function updatebush!(bush)

end

function topologicalorder(bush::AbstractNetwork{T}) where T<:Integer
    nnodes = numnodes(bush)
    nodeorder = zeros(T, nnodes)
    deg = indegree.(Ref(bush), 1:nnodes)

    S = filter((i) -> deg[i] == 0, 1:nnodes)
    if length(S) == 0
        @warn "Not a bush input! No nodes with zero indegree."
    elseif length(S) > 1
        @warn "Not a bush input! More than one nodes with zero indegree."
    end
    o = 0
    while length(S) > 0
        i = pop!(S)
        o += 1
        nodeorder[i] = o
        for j in outneighbors(bush, i)
            deg[j] -= 1
            if deg[j] == 0
                push!(S, j)
            end
        end
    end
    if (o != nnodes)
        @warn "Not a bush input! Has cycles."
    end

    nodeorder
end

function bushpath(bush::AbstractNetwork, linkcosts::Vector{<:Real}, nodeorder=nothing; kind=:short)
    nnodes = numnodes(bush)
    if nodeorder == nothing
        nodeorder = topologicalorder(bush)
    end

    nodecosts = fill((kind == :short) ? Inf : (kind == :long) ? -Inf : error("Invalid path kind!"), nnodes)
    parentvec = fill(-1, nnodes)
    nodecosts[r] = 0; parents[r] = r

    condn = ((kind == :short) ? (i,j) -> (nodecosts[j] > nodecosts[i] + linkcosts[idx(bush, i, j)])
                              : (i,j) -> (nodecosts[j] < nodecosts[i] + linkcosts[idx(bush, i, j)]))

    orderednodes = invperm(nodeorder)
    for j in orderednodes[2:end]
        for i in inneighbors(bush, j)
            if condn(i,j)
                nodecosts[j] = nodecosts[i] + linkcosts[idx(bush, i, j)]
                parentvec[j] = i
            end
        end
    end

    return nodecosts, parentvec
end
