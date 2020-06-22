
struct SimpleLink{T<:Integer} <: AbstractLink{T}
    upn::T # upnode
    dwn::T # downnode
    props::Union{Nothing,Dict}
end

function SimpleLink{T}(data::Dict; upnkey, dwnkey) where T <: Integer
    (upn = data[upnkey]; delete!(data, upnkey))
    (dwn = data[dwnkey]; delete!(data, dwnkey))
    SimpleLink{T}(upn, dwn, data)
end

SimpleLink{T}(dfrow::DataFrameRow, args...; kwargs...) where T <: Integer = SimpleLink{T}(Dict(pairs(dfrow)); upnkey=kwargs[:upnkey], dwnkey=kwargs[:dwnkey])

# Accessors
upn(e::SimpleLink) = e.upn
dwn(e::SimpleLink) = e.dwn
props(e::SimpleLink) = e.props
