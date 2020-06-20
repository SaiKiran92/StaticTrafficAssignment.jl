function topologicalorder(bush)
    nnodes = nv(bush)
    nodeorder = zeros(Int, nnodes)
    deg = indegree.(Ref(bush), 1:nnodes)

    SEL = [i for (i,d) in enumerate(deg) if d == 0]
    @assert (length(SEL) == 0) "Not a bush! Check connectivity."

    o = 0
    while length(SEL) > 0
        i = pop!(SEL)
        o += 1
        nodeorder[i] = o
        for j in outneighbors(bush, i)
            deg[j] -= 1
            if deg[j] == 0
                push!(SEL, j)
            end
        end
    end
    @assert (o == nnodes) "Not a bush! Check cyclicity."

    nodeorder
end

function bushlabels(bush, linkcosts, nodeorder=nothing; kind=:short)
    if nodeorder == nothing
        nodeorder = topologicalorder(bush)
    end

    nodecosts = fill((kind == :short) ? Inf : -Inf, nnodes)
    parentvec = fill(-1, nnodes)

    orderednodes = invperm(nodeorder)
    r = orderednodes[1]
    nodecosts[r] = 0.
    parentvec = r

    condn = ((kind == :short) ? (i,j) -> (nodecosts[j] > (nodecosts[i] + linkcosts[edgeidx(bush,i,j)]))
            : (kind == :long) ? (i,j) -> (nodecosts[j] < (nodecosts[i] + linkcosts[edgeidx(bush,i,j)]))
            : error("Invalid path kind!"))

    for j in orderednodes[2:end]
        for i in inneighbors(bush, j)
            if condn(i,j)
                nodecosts[j] = nodecosts[i] + linkcosts[edgeidx(bush,i,j)]
                parentvec[j] = i
            end
        end
    end

    return nodecosts, parentvec
end

function initbushes(network, trips, costfn)
    nnodes, nlinks = nv(network), ne(network)
    nzones = get_prop(network, :nzones)
    _, parentmx = dijkstra(network, 1:nzones, costfn(zeros(nlinks)).costs)
    flows = zeros(nlinks, nzones)

    bushes = [MetaDiGraph(nnodes) for r in 1:nzones]
    for (r,bush) in enumerate(bushes)
        set_prop!(bush, :nzones, get_prop(network, :nzones))
        for s in 1:nzones
            path = findpath(parentmx, r, s)
            for l in path
                flows[edgeidx(network, l...), r] += trips[r,s]
                add_edge!(bush, l)
            end
        end
        set_prop!(bush, :edgeidx, get_prop(network, :edgeidx))
    end

    return bushes
end

function updatebush!(network, bush, linkcosts, linksmodified)
    longnodecosts, _ = bushlabels(bush, linkcosts; kind=:long)
    for (i,e) in enumerate(edges(network))
        if (longnodecosts[dst(e)] < longnodecosts[src(e)] + linkcosts[i]) & linksmodified[i]
            add_edge!(bush, e)
        else
            try
                rem_edge!(bush, e)
            catch
            end
        end
    end
end

function algorithmB(network, trips, costfn; λ=0.01, reltol=1e-4)
    bushes = initbushes(network, costfn)
    # flow initialization

    while ϵ > reltol
        for bush in bushes
            nodeorder = topologicalorder(bush)
            
        end

        ## update bushes
        linkcosts = cosftn(flows).costs
        for bush in bushes
            updatebush!(network, bush, linkcosts, linksmodified)
        end
    end
end
