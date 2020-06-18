struct CostFunctionGenerator <: Function
    times::Function
    dtimes::Function
    ddtimes::Function

    function CostFunctionGenerator(network, timefn)
        fns = []
        dfns = []
        ddfns = []
        for e in edges(network)
            edata = props(network, e)
            rv = timefn(edata)

            push!(fns, rv[1])

            try
                push!(dfns, rv[2])
            catch
                push!(dfns, nothing)
            end

            try
                push!(ddfns, rv[3])
            catch
                push!(ddfns, nothing)
            end
        end

        function times(x, ids=nothing)
            if ids != nothing
                tfns, tx = fns[ids], x[ids]
            else
                tfns, tx = fns, x
            end
            [fn(xi) for (fn,xi) in zip(tfns,tx)]
        end

        function dtimes(x, ids=nothing)
            if ids != nothing
                tdfns, tx = dfns[ids], x[ids]
            else
                tdfns, tx = dfns, x
            end
            [((dfn == nothing) ? nothing : dfn(xi)) for (dfn,xi) in zip(tdfns,tx)]
        end

        function ddtimes(x, ids=nothing)
            if ids != nothing
                tddfns, tx = ddfns[ids], x[ids]
            else
                tddfns, tx = ddfns, x
            end
            [((ddfn == nothing) ? nothing : ddfn(xi)) for (ddfn,xi) in zip(tddfns,tx)]
        end

        return new(times, dtimes, ddtimes)
    end
end

abstract type ProblemType end
abstract type UEProblem <: ProblemType end
abstract type SOProblem <: ProblemType end

function (f::CostFunctionGenerator)(::Type{UEProblem})
    function fn(x::Array{<:Real,1}, ids=nothing, returnitems=[:costs]; tolls=nothing)
        times = nothing
        dtimes = nothing

        if (:costs ∈ returnitems) | (:tsc ∈ returnitems)
            times = f.times(x, ids)
        end
        if (:derivs ∈ returnitems)
            dtimes = f.dtimes(x, ids)
        end
        tolls = (tolls == nothing) ? zero(x) : (ids == nothing) ? tolls : tolls[ids]

        rv = Dict()
        if :costs ∈ returnitems
            rv[:costs] = times + tolls
        end
        if :derivs ∈ returnitems
            rv[:derivs] = dtimes
        end
        if :tsc ∈ returnitems
            rv[:tsc] = sum(x .* times)
        end

        return NamedTuple(rv)
    end

    fn
end

function (f::CostFunctionGenerator)(::Type{SOProblem})
    function fn(x::Array{<:Real,1}, ids=nothing, returnitems=[:costs])
        times = nothing
        dtimes = nothing

        if (:costs ∈ returnitems) | (:tsc ∈ returnitems)
            times = f.times(x, ids)
            dtimes = f.dtimes(x, ids)
        end
        if (:derivs ∈ returnitems)
            ddtimes = f.ddtimes(x, ids)
        end

        rv = Dict()
        if :costs ∈ returnitems
            rv[:costs] = times + x .* dtimes
        end
        if :derivs ∈ returnitems
            rv[:derivs] = 2 * dtimes + x .* ddtimes
        end
        if :tsc ∈ returnitems
            rv[:tsc] = sum(x .* times)
        end

        return NamedTuple(rv)
    end

    fn
end
