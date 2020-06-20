function conjugatefrankwolfe(network::RoadNetwork,
                             trips::AbstractMatrix{T},
                             costfn::Function;
                             basedon=:link,
                             firstthroughnode::U = 1,
                             errtol=1e-4,
                             δ=1e-3) where {T<:Real, U<:Integer}
    # initialize
    flows = allornothing(network, trips, costfn; basedon=basedon, firstthroughnode=firstthroughnode)

    # start iteration
    err = 1.
    oldflows = copy(flows)
    while err > errtol
        ## find target solution
        tmp = costfn(flows, nothing, [:costs, :derivs])
        linkcosts, H = tmp[:costs], Diagonal(tmp[:derivs])
        newflows = allornothing(network, trips, linkcosts; basedon=basedon, firstthroughnode=firstthroughnode)

        newdir = reduce(+, newflows - flows, dims=2:length(flows))
        olddir = reduce(+, oldflows - flows, dims=2:length(flows))
        α = (olddir' * H * newdir)/(olddir' * H * (newdir - olddir))
        α = isnan(α) ? 0. : (α < 0.) ? 0. : (α > (1. - δ)) ? (1. - δ) : α
        conjflows = α * oldflows + (1-α) * newflows

        ## find stepsize
        conjdirfull = conjflows - flows
        μ = bisection((μ) -> sum(costfn(flows + μ * conjdirfull).costs .* conjdirfull))

        ## calculate new link travel times
        flows += μ * conjdirfull

        ## calculate error
        err = sum(flows .* linkcosts)/sum(newflows .* linkcosts) - 1.
        oldflows = conjflows
    end
    return (flows, err)
end
