
function algorithmB(network::AbstractNetwork{T},
                    trips::Matrix{U},
                    costfn::CostFunction;
                    bushtype=SimpleBush{T},
                    λ=1e6,
                    maxiter=1000,
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
    nadded, nremoved = 1, 0 # number of links swithing in and out of bushes
    iterno = 0
    outererr = 1.
    while (outererr > errtol) && (iterno <= maxiter) #(nadded + nremoved > 0)
        # equilibrate bushes
        totalshift = zeros(Bool, nlinks, nzones)
        err = 1. # problem solved for the bushes completely
        while err > errtol
            # equilibrate core step
            for bush in bushes
                r = src(bush)
                scosts, sparentvec = acyclic(bush, linkcosts; kind=:short)

                for j in reverse(orderednodes(bush))
                    #lcosts, lparentvec = acyclic(bush, linkcosts - LARGE_NUM * totalshift[:,r]; kind=:long)
                    lcosts, lparentvec = acyclic(bush, linkcosts - LARGE_NUM * iszero.(flows[:,r]); kind=:long)
                    if (j == r) || (lcosts[j] ≈ scosts[j]) || (trips[r,j] == 0.)
                        continue
                    end

                    spath, lpath = try
                        pathto(sparentvec, j), pathto(lparentvec, j)
                    catch
                        println(r, "\t", j, "\t", trips[r,j])
                        error()
                    end

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
                    if iszero(lflow)
                        return (r, lsegids, bush, flows, totalshift)
                    end

                    flows[ssegids,r] .+= dx
                    flows[lsegids,r] .-= dx
                    if (dx < 0.)
                        println("negative dx: $dx")
                    end
                    #println(dx/lflow)

                    # check any zero flows on longpath
                    for lsi in lsegids
                        if iszero(flows[lsi,r])
                            totalshift[lsi,r] = true
                        elseif flows[lsi, r] ≈ 0.
                            println("nearly zero: $(flows[lsi,r])")
                        end
                    end
                end
            end
            totalshift .&= iszero.(flows)
            linkcosts, linkcostdrvs = costfn(flows; returnitems=[:costs, :derivs])
            numer = 0.
            denom = 0.
            for (i,bush) in enumerate(bushes)
                r = src(bush)
                sflows = allornothing(bush, r, trips[:,r], linkcosts)
                numer += sum(flows[:,i] .* linkcosts)
                denom += sum(sflows .* linkcosts)
            end
            err = numer/denom - 1.
            println(nadded + nremoved, "\t", outererr, "\t", err)
        end

        # update bushes
        nadded, nremoved = updatebushes!(bushes, flows, linkcosts, totalshift)

        outersflows = allornothing(network, trips, linkcosts; basedon=:link)
        outererr = sum(flows .* linkcosts)/sum(outersflows .* linkcosts) - 1.
        println(nadded, "\t", nremoved, "\t", outererr)
        iterno += 1
    end
    return flows
end

function updatebushes!(bushes::Vector{<:AbstractBush}, flows::Matrix, linkcosts::Vector, totalshift::Matrix{Bool})
    nadded, nremoved = 0, 0
    for (iteri,bush) in enumerate(bushes)
        r = src(bush)
        #scosts, sparentvec = acyclic(bush, linkcosts; kind=:short)
        lcosts, lparentvec = acyclic(bush, linkcosts; kind=:long)
        for link in links(net(bush))
            i,j,linkidx = upn(link),dwn(link),idx(net(bush), link)

            if has_link(bush, i, j)
                if iszero(flows[linkidx,iteri]) && !(indegree(bush, j) == 1)
                    rem_link!(bush, i, j)
                    nremoved += 1
                end
            else
                if (lcosts[j] > lcosts[i] + linkcosts[linkidx])
                    add_link!(bush, i, j)
                    nadded += 1
                end
            end
        end
    end
    return (nadded, nremoved)
end
