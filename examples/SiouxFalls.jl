using StaticTrafficAssignment
using LightGraphs

network, trips, firstthroughnode, bestsolution = readtntpdata("/Users/mayakuntlasaikiran/.julia/dev/StaticTrafficAssignment/examples/data/SiouxFalls/")

costgen = CostFunctionGenerator(network, BPR)
uecostfn = costgen(UEProblem)
socostfn = costgen(SOProblem)

@time aonsoln = allornothing(network, trips, uecostfn)
@time uesoln = frankwolfe(network, trips, uecostfn)
@time sosoln = frankwolfe(network, trips, socostfn)
