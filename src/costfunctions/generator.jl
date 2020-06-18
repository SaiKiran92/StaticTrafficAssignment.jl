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
    function fn(x::Array{<:Real,1}; returntsc::Bool=false, returnhessian::Bool=false, tolls=nothing)
        times = f.times(x)

        rv = Dict()
        rv[:costs] = times
        if tolls != nothing
            rv[:costs] += tolls
        end
        if returntsc
            rv[:tsc] = totalsystemcost(x, times)
        end
        if returnhessian
            rv[:hessian] = Diagonal(f.dtimes(x))
        end

        return NamedTuple(rv)
    end

    fn
end

function (f::CostFunctionGenerator)(::Type{SOProblem})
    function fn(x::Array{<:Real,1}; returntsc=true, returnhessian=false)
        times = f.times(x)
        dtimes = f.dtimes(x)

        rv = Dict()
        rv[:costs] = times .+ x .* dtimes
        if returntsc
            rv[:tsc] = totalsystemcost(x, times)
        end
        if returnhessian
            rv[:hessian] = Diagonal(2 * dtimes + x .* f.ddtimes(x))
        end

        return NamedTuple(rv)
    end

    fn
end

totalsystemcost(x::Array{<:Real,1}, timesfn::Function) = sum(x .* timesfn(x))
totalsystemcost(x::Array{<:Real,1}, times::Array{<:Real,1}) = sum(x .* times)
