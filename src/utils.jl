
deletesortedfirst!(a::Vector{T}, i::T) where T = deleteat!(a, searchsortedfirst(a, i))
funcmap(funcs::Vector{Function}, x::Vector) = map((f,xi) -> f(xi), funcs, x)
NamedTuple(d::Dict) = (;zip(keys(d), values(d))...)


function bisection(fn; a=0., b=1., ϵ=1e-05)
    μ = 0.
    while ((b - a) > ϵ)
        μ = 0.5*(a + b)
        if fn(μ) > 0
            b = μ
        else
            a = μ
        end
    end
    return 0.5*(a + b)
end
