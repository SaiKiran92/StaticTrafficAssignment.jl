function frankwolfe(network::RoadNetwork,
              trips::AbstractMatrix{T},
              costfn::Function;
              basedon=:link,
              nothroughnodes = [],
              errtol=1e-4) where {T<:Real, U<:Integer}
    # initialize
    flows = allornothing(network, trips, costfn; basedon=basedon, nothroughnodes=nothroughnodes)

    # start iteration
    err = 1.
    while err > errtol
        ## find target solution
        linkcosts = costfn(flows).costs
        newflows = allornothing(network, trips, linkcosts; basedon=basedon, nothroughnodes=nothroughnodes)

        ## find stepsize
        μ = bisection((μ) -> sum(costfn(μ * newflows + (1-μ) * flows).costs .* (newflows - flows)))

        ## calculate new link travel times
        flows += μ * (newflows - flows)

        ## calculate error
        err = sum(flows .* linkcosts)/sum(newflows .* linkcosts) - 1.
    end
    return (flows, err)
end
