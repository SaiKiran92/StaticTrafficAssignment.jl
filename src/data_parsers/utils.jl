struct InputError <: Exception
    s::String
end
Base.showerror(io::IO, ex::InputError) = print(io, ex.s)
