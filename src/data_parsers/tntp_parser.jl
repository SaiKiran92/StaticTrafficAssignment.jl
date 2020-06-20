using CSV: read

struct InputError <: Exception
    s::String
end
Base.showerror(io::IO, ex::InputError) = print(io, ex.s)

# helper function
function readvalue(io, s::String, dtype=Int)
    l = strip(readline(io))
    occursin(s, l) || throw(InputError(filepath))
    parse(dtype, split(l)[end])
end

function readnettntp(filepath::String;
                     _dtypes = Dict(:init_node => Int, :term_node => Int, :capacity => Float64,
                                    :length => Float64, :free_flow_time => Float64, :power => Float64,
                                    :b => Float64, :speed => Float64, :toll => Float64, :link_type => Int))
    # reading metadata
    nzones, nnodes, ftnode, nlinks, headerrow = open(filepath) do io
        nzones = readvalue(io, "<NUMBER OF ZONES>")
        nnodes = readvalue(io, "<NUMBER OF NODES>")
        ftnode = readvalue(io, "<FIRST THRU NODE>")
        nlinks = readvalue(io, "<NUMBER OF LINKS>")

        headerrow = 4
        while(headerrow += 1; ((line = strip(readline(io))) == "") || !startswith(line, "~"))
            if eof(io)
                throw(InputError("network data"))
            end
        end

        return (nzones, nnodes, ftnode, nlinks, headerrow)
    end

    # reading network-link data
    linkdf = read(filepath, skipto=headerrow+1, header=headerrow, types=_dtypes)
    linkdf = linkdf[:,2:(end-1)]

    return (nzones, nnodes, ftnode, nlinks, linkdf)
end

function readtriptntp(filepath::String)
    nzones, totalflow, trips = open(filepath) do io
        # reading metadata
        nzones = readvalue(io, "<NUMBER OF ZONES>")
        totalflow = readvalue(io, "<TOTAL OD FLOW>", Float64)

        # reading trip data
        while (line = strip(readline(io)); ~occursin("Origin", line)) end

        trips = zeros(nzones, nzones)
        i = parse(Int, split(line)[end])
        while !eof(io)
            line = strip(readline(io))
            if occursin("Origin", line)
                i = parse(Int, split(line)[end])
            elseif (line == "")

            else
                line = line[1:(end - (line[end] == ';'))]
                for traw in split(line, ";")
                    ttmp = split(traw)
                    trips[i, parse(Int, ttmp[1])] = parse(Float64, ttmp[end])
                end
            end
        end

        return (nzones, totalflow, trips)
    end

    return (nzones, totalflow, trips)
end

function readnodetntp(filepath::String)
    data = read(filepath)
    data = data[:, 1:(end-1)]
    return data
end

readflowtntp(filepath::String) = read(filepath)

function readtntpdata(folderpath::String)
    contents = filter((f) -> endswith(f, ".tntp"), readdir(folderpath))
    filetypes = [:net, :trips, :flow, :node]

    filepaths = Dict()
    for ft in filetypes
        files = filter(x -> endswith(x, "_$ft.tntp"), contents)
        if length(files) > 1
            throw("More than one $ft files found in the folder!")
        elseif length(files) == 0
            throw("No $ft files found in the folder!")
        else
            f = files[1]
        end
        filepaths[ft] = folderpath*f
    end

    nzones, nnodes, ftnode, nlinks, linkdf = readnettntp(filepaths[:net])
    nzones2, totalflow, trips = readtriptntp(filepaths[:trips])

    @assert nzones == nzones2 "Number of zones inconsistent"
    @assert totalflow ≈ sum(trips) "Number of trips inconsistent"
    @assert nlinks == nrow(linkdf) "Number of links inconsistent"
    @assert all((1 .<= linkdf.init_node .<= nnodes) .& (1 .<= linkdf.term_node .<= nnodes)) "Number of nodes inconsistent"
    @assert ftnode <= nnodes "First through node inconsistent"

    # building the network
    network = RoadNetwork(nnodes)
    set_prop!(network, :nzones, nzones)

    for row in eachrow(linkdf)
        e = Edge(row[:init_node], row[:term_node])
        add_edge!(network, e)
        set_props!(network, e, Dict(Symbol(n) => row[n] for n in names(row) if ~(n in (row[:init_node], row[:term_node]))))
    end
    for (i,e) in enumerate(edges(network))
        set_prop!(network, e, :idx, i)
    end

    if :node in keys(filepaths)
        geometry = readnodetntp(filepaths[:node])
        set_prop!(network, :geometry, geometry)
    end

    bestsolution = nothing
    if :flow in keys(filepaths)
        bestsolution = readflowtntp(filepaths[:flow])
        @assert nlinks == nrow(bestsolution) "Number of links inconsistent with flow file"
    end

    return (network = network, trips = trips, firstthroughnode = ftnode, bestsolution = bestsolution)
end

edgeidx(network::RoadNetwork, e::Edge) = get_prop(network, e, :idx)
edgeidx(network::RoadNetwork, i, j) = get_prop(network, i, j, :idx)
