Base.convert(::Type{Tuple}, e::Edge) = (src(e), dst(e))
Base.:*(d::Dict, p::Real) = Dict(k => (v*p) for (k,v) in d)
Base.zero(d::Dict) = d * 0.

NamedTuple(d::Dict) = (; zip(keys(d), values(d))...)

function bisection(fn; a=0., b=1., ϵ=1e-05)
    μ = 0.
    while (b - a) > ϵ
        μ = 0.5*(a + b)
        if fn(μ) > 0
            b = μ
        else
            a = μ
        end
    end

    return μ
end

function matrixify(network::MetaDiGraph, vec::AbstractVector)
    mx = sparse([], [], Float64[], nnodes, nnodes)
    #costmx = zeros(nnodes, nnodes)
    for (v,e) in zip(vec,edges(network))
        mx[src(e),dst(e)] = v
    end
    mx
end
