using StaticTrafficAssignment
using Documenter

makedocs(;
    modules=[StaticTrafficAssignment],
    authors="Sai Kiran Mayakuntla",
    repo="https://github.com/SaiKiran92/StaticTrafficAssignment.jl/blob/{commit}{path}#L{line}",
    sitename="StaticTrafficAssignment.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SaiKiran92.github.io/StaticTrafficAssignment.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SaiKiran92/StaticTrafficAssignment.jl",
)
