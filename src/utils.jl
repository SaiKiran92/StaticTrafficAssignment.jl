Base.convert(::Type{Tuple}, e::Edge) = (src(e), dst(e))

Base.:*(d::Dict, p::Real) = Dict(k => (v*p) for (k,v) in d)
Base.zero(d::Dict) = d * 0.

NamedTuple(d::Dict) = (; zip(keys(d), values(d))...)

function bisection(fn; a=0., b=1., ϵ=1e-05)
    μ = 0.
    #niter = 0
    while ((b - a) > ϵ)# & (niter < 5)
        μ = 0.5*(a + b)
        if fn(μ) > 0
            b = μ
        else
            a = μ
        end
        #niter += 1
        #println(niter, "\t", μ)
    end

    return 0.5*(a + b)
end

function findpath(parentmx::AbstractMatrix, orig::U, dest::U) where {U<:Integer}
    path = Vector{Tuple{U,U}}()
    currnode = dest
    while currnode != orig
        prevnode = parentmx[orig,currnode]
        push!(path, (prevnode, currnode))
        currnode = prevnode
    end
    reverse(path)
end

function findpathto(parents::AbstractVector, dest::U) where {U<:Integer}
    path = Vector{Tuple{U,U}}()
    currnode = dest
    while true #currnode != orig
        prevnode = parents[currnode]
        if currnode == prevnode
            break
        end
        push!(path, (prevnode, currnode))
        currnode = prevnode
    end
    reverse(path)
end
