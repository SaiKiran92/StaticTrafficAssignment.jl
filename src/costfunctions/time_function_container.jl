
struct TimeFunctionContainer
    times::Vector{Function}
    dtimes::Vector{Function}
    ddtimes::Vector{Function}

    function TimeFunctionContainer(network, f)
        times = Vector{Function}()
        dtimes = Vector{Function}()
        ddtimes = Vector{Function}()
        for l in links(network)
            a, b, c = f(props(l))
            push!(times, a)
            push!(dtimes, b)
            push!(ddtimes, c)
        end

        new(times, dtimes, ddtimes)
    end
end

function times(tfc::TimeFunctionContainer, x::Array{<:Real,1}, ids::Union{Nothing,Array{<:Integer,1}}=nothing)
    t = try
        funcmap(tfc.times[ids], x)
    catch
        funcmap(tfc.times[ids], x[ids])
    end
    t
end

function dtimes(tfc::TimeFunctionContainer, x::Array{<:Real,1}, ids::Union{Nothing,Array{<:Integer,1}}=nothing)
    dt = try
        funcmap(tfc.dtimes[ids], x)
    catch
        funcmap(tfc.dtimes[ids], x[ids])
    end
    dt
end

function ddtimes(tfc::TimeFunctionContainer, x::Array{<:Real,1}, ids::Union{Nothing,Array{<:Integer,1}}=nothing)
    ddt = try
        funcmap(tfc.ddtimes[ids], x)
    catch DimensionMismatch
        funcmap(tfc.ddtimes[ids], x[ids])
    end
    ddt
end
