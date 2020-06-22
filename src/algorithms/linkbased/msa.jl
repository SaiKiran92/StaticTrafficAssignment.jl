function msa(network::AbstractNetwork,
              trips::AbstractMatrix{T},
              costfn::CostFunction;
              basedon=:link,
              errtol=1e-4) where {T<:Real, U<:Integer}
    # initialize
    flows = allornothing(network, trips, costfn; basedon=basedon)

    # start iteration
    err = 1.
    iterno = 2 # first iteration @ initialization
    while err > errtol
        ## find target solution
        linkcosts = costfn(flows).costs
        shortflows = allornothing(network, trips, linkcosts; basedon=basedon)

        ## find stepsize
        μ = 1/iterno

        ## calculate new link travel times
        flows += μ * (shortflows - flows)

        ## calculate error
        err = sum(flows .* linkcosts)/sum(shortflows .* linkcosts) - 1.
        iterno += 1
    end
    return (flows, err)
end
