
mutable struct SimpleZone{T<:Integer} <: AbstractZone{T}
    id::T
    issource::Bool
    issink::Bool
    thruallowed::Bool
    props::Union{Nothing, Dict}
end

function SimpleZone{T}(d::Dict; idkey, issrckey, issnkkey, thrukey) where T <: Integer
    (id = d[idkey]; delete!(d, idkey))
    (issource = d[issrckey]; delete!(d, issrckey))
    (issink = d[issnkkey]; delete!(d, issnkkey))
    (thruallowed = d[thrukey]; delete!(d, thrukey))
    SimpleZone{T}(id, issource, issink, thruallowed, d)
end

SimpleZone{T}(dfrow::DataFrameRow, args...; kwargs...) where T <: Integer = SimpleZone{T}(Dict(pairs(dfrow)); idkey=kwargs[:idkey], issrckey=kwargs[:issrckey], issnkkey=kwargs[:issnkkey], thrukey=kwargs[:thrukey])

id(z::SimpleZone{T}) where T = z.id
issource(z::SimpleZone{T}) where T = z.issource
issink(z::SimpleZone{T}) where T = z.issink
throughflowallowed(z::SimpleZone{T}) where T = z.thruallowed
props(z::SimpleZone{T}) where T = z.props

show(io::IOStream, z::AbstractZone) = print(io, "Zone $(z.id)")
