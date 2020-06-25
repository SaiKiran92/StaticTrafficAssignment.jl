
function acyclic(network::AbstractNetwork, linkcosts::Vector{<:Real}, order=orderednodes(network); kind=:short)
    nnodes = length(order)
    r = order[1]

    nodecosts = fill((kind == :short) ? Inf : (kind == :long) ? -Inf : error("Only short and long kinds allowed!"), nnodes)
    parentvec = fill(-1, nnodes)
    nodecosts[r] = 0; parentvec[r] = r

    condn = ((kind == :short) ? (i,j) -> (nodecosts[j] > nodecosts[i] + linkcosts[idx(network, i, j)])
                              : (i,j) -> (nodecosts[j] < nodecosts[i] + linkcosts[idx(network, i, j)]))

    for j in order[2:end]
        for i in inneighbors(network, j)
            if condn(i,j)
                nodecosts[j] = nodecosts[i] + linkcosts[idx(network, i, j)]
                parentvec[j] = i
            end
        end
    end

    return nodecosts, parentvec
end
