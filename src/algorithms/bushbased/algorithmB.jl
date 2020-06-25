
function algorithmB(network::AbstractNetwork{T},
                    trips::Matrix{U},
                    costfn::CostFunction;
                    bushtype=SimpleBush{T},
                    λ=1e4,
                    errtol=1e-4) where {T<:Integer, U<:Real}

    # unable to state the type for bushtype as `::Type{<:AbstractBush{T}}`

    zoneids = id.(zones(network))
    nzones = length(zoneids)
    nlinks = numlinks(network)

    # initialize
    bushes = [bushtype(network, r, costfn) for r in zoneids]
    flows = allornothing(network, trips, costfn; basedon=:origin)

    # iteration
    linkcosts, linkcostdrvs = costfn(flows; returnitems=[:costs, :derivs]) # updated as and when flows change
    LARGE_NUM = typemax(eltype(linkcosts))/2 # large constant used below
    # equilibrate bushes
    nlinkswitches = 1
    err = 1. # problem solved for the bushes completely
    while err > errtol
        # equilibrate core step
        totalshift = zeros(Bool, nlinks, nzones)
        for bush in bushes
            r = src(bush)
            scosts, sparentvec = acyclic(bush, linkcosts; kind=:short)
            lcosts, lparentvec = acyclic(bush, linkcosts + LARGE_NUM * totalshift[:,r]; kind=:long)

            for j in reverse(orderednodes(bush))
                if (j == r) || (lcosts[j] ≈ scosts[j]) || (trips[r,j] == 0.)
                    continue
                end

                spath = pathto(sparentvec, j)
                lpath = pathto(lparentvec, j)
                max_i = min(length(spath), length(lpath))

                # find path segments
                i = 1
                while (i <= max_i) && (spath[i] == lpath[i])
                    i += 1
                end
                sa = la = i

                i = 0
                while (i < max_i) && (spath[end-i] == lpath[end-i])
                    i += 1
                end
                sb = length(spath)-i
                lb = length(lpath)-i

                # link indices
                ssegids = idx.(Ref(bush), spath[sa:sb])
                lsegids = idx.(Ref(bush), lpath[la:lb])

                scost, sdcost = sum(linkcosts[ssegids]), sum(linkcostdrvs[ssegids])
                lcost, ldcost = sum(linkcosts[lsegids]), sum(linkcostdrvs[lsegids])

                lflow = minimum(flows[lsegids,r])
                dx = min(lflow, λ * (lcost - scost)/(ldcost + sdcost))

                flows[ssegids,r] .+= dx
                flows[lsegids,r] .-= dx

                # check any zero flows on longpath
                for lsi in lsegids
                    if flows[lsi,r] == 0.
                        totalshift[lsi,r] = true
                    end
                end
            end
        end

        linkcosts, linkcostdrvs = costfn(flows; returnitems=[:costs, :derivs])
        sflows = allornothing(network, trips, linkcosts; basedon=:link)
        err = sum(flows .* linkcosts)/sum(sflows .* linkcosts) - 1.
        println(nlinkswitches, "\t", err)

        # update bushes
        nlinkswitches = updatebushes!(bushes, flows, linkcosts)
    end
    flows
end

function updatebushes!(bushes::Vector{<:AbstractBush}, flows::Matrix, linkcosts::Vector)
    nlinkswitches = 0
    for bush in bushes
        r = src(bush)
        scosts, sparentvec = acyclic(bush, linkcosts; kind=:short)
        lcosts, lparentvec = acyclic(bush, linkcosts; kind=:long)
        for link in links(net(bush))
            i,j,linkidx = upn(link),dwn(link),idx(net(bush), link)
            if (lcosts[j] > lcosts[i] + linkcosts[linkidx]) && !has_link(bush, i, j)
                add_link!(bush, link)
                nlinkswitches += 1
            elseif has_link(bush, i, j) && iszero(flows[linkidx,r]) && (sparentvec[j] != i)
                rem_link!(bush, i, j)
                nlinkswitches += 1
            end
        end
    end
    return nlinkswitches
end
