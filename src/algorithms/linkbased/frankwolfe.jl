function frankwolfe(network::AbstractNetwork,
              trips::AbstractMatrix{T},
              costfn::Function;
              basedon=:link,
              errtol=1e-4) where {T<:Real}
    # initialize
    flows = allornothing(network, trips, costfn; basedon=basedon)

    # start iteration
    err = 1.
    while err > errtol
        ## find target solution
        linkcosts, = costfn(flows)
        shortflows = allornothing(network, trips, linkcosts; basedon=basedon)

        ## find stepsize
        Δflows = shortflows - flows
        μ = bisection((μ) -> sum(costfn(flows + μ * Δflows).costs .* Δflows))

        ## calculate new link travel times
        flows += μ * Δflows

        ## calculate error
        err = sum(flows .* linkcosts)/sum(shortflows .* linkcosts) - 1.
    end
    return (flows, err)
end
