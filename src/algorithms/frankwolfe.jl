function frankwolfe(network::MetaDiGraph, trips::AbstractMatrix{<:Real}, costfn::Function; reltol=1e-04)
    # initialize
    flows = allornothing(network, trips, costfn)

    relerr = 1
    while relerr > reltol
        # compute costs
        costs = costfn(flows)[:costs]

        # update flows
        ## calculate shortpathflows
        shortpathflows = allornothing(network, trips, costs)

        ## determining μ
        μ = bisection((μ) -> sum(costfn(μ * shortpathflows + (1 - μ) * flows).costs .* (shortpathflows - flows)))

        ## update
        flows += μ * (shortpathflows - flows)

        # relerr update
        relerr = sum(flows .* costs)/sum(shortpathflows .* costs) - 1
    end
    return flows
end
