
struct CostFunctionUE <: CostFunction
    tfc::TimeFunctionContainer

    function CostFunctionUE(network::AbstractNetwork, fn::Function)
        new(TimeFunctionContainer(network, fn))
    end
end

function (f::CostFunctionUE)(x::Array{<:Real,1}, ids=nothing; returnitems=[:costs], tolls=nothing)
    t, dt = nothing, nothing

    if (:costs ∈ returnitems) || (:tsc ∈ returnitems)
        t = times(f.tfc, x, ids)
    end
    if (:derivs ∈ returnitems)
        dt = dtimes(f.tfc, x, ids)
    end
    tolls = (tolls == nothing) ? zero(x) : (ids == nothing) ? tolls : tolls[ids]

    rv = Dict()
    if :costs ∈ returnitems
        rv[:costs] = t + tolls
    end
    if :derivs ∈ returnitems
        rv[:derivs] = dt
    end
    if :tsc ∈ returnitems
        rv[:tsc] = sum(x .* t)
    end
    
    return NamedTuple(rv)
end

struct CostFunctionSO <: CostFunction
    tfc::TimeFunctionContainer

    function CostFunctionSO(network::AbstractNetwork, fn::Function)
        new(TimeFunctionContainer(network, fn))
    end
end

function (f::CostFunctionSO)(x::Array{<:Real,1}, ids=nothing; returnitems=[:costs], tolls=nothing)
    t, dt, ddt = nothing, nothing, nothing

    if (:costs ∈ returnitems) || (:tsc ∈ returnitems)
        t = times(f.tfc, x, ids)
    end
    if (:costs ∈ returnitems) || (:derivs ∈ returnitems)
        dt = dtimes(f.tfc, x, ids)
    end
    if (:derivs ∈ returnitems)
        ddt = ddtimes(f.tfc, x, ids)
    end
    tolls = (tolls == nothing) ? zero(x) : (ids == nothing) ? tolls : tolls[ids]

    rv = Dict()
    if :costs ∈ returnitems
        rv[:costs] = t + x .* dt
    end
    if :derivs ∈ returnitems
        rv[:derivs] = 2 * dt + x .* ddt
    end
    if :tsc ∈ returnitems
        rv[:tsc] = sum(x .* t)
    end
    return NamedTuple(rv)
end

(f::CostFunction)(x::AbstractMatrix, args...; kwargs...) = f(sum(x, dims=2)[:,1], args...; kwargs...)
