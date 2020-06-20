function mosa(network::RoadNetwork,
              trips::AbstractMatrix{T},
              costfn::Function;
              basedon=:link,
              firstthroughnode::U = 1,
              errtol=1e-4) where {T<:Real, U<:Integer}
    # initialize
    flows = allornothing(network, trips, costfn; basedon=basedon, firstthroughnode=firstthroughnode)

    # start iteration
    err = 1.
    iterno = 2 # first iteration @ initialization
    while err > errtol
        ## find target solution
        linkcosts = costfn(flows).costs
        newflows = allornothing(network, trips, linkcosts; basedon=basedon, firstthroughnode=firstthroughnode)

        ## find stepsize
        μ = 1/iterno

        ## calculate new link travel times
        flows += μ * (newflows - flows)

        ## calculate error
        err = sum(flows .* linkcosts)/sum(newflows .* linkcosts) - 1.
        iterno += 1
    end
    return (flows, err)
end
