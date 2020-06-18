using StaticTrafficAssignment
using LightGraphs, MetaGraphs

# reading data
folderpath = "/Users/mayakuntlasaikiran/.julia/dev/StaticTrafficAssignment/examples/data/SiouxFalls/"
network, trips, firstthroughnode, bestsolution = readtntpdata(folderpath);

# First run includes compilation time - So, no performance check here
nothroughnodes = collect(1:(firstthroughnode-1))
costgen = CostFunctionGenerator(network, BPR)
uecostfn = costgen(UEProblem)
socostfn = costgen(SOProblem)

aonsoln = allornothing(network, trips, uecostfn, nothroughnodes=nothroughnodes)

uesoln_mosa = frankwolfe(network, trips, uecostfn, nothroughnodes=nothroughnodes)
sosoln_mosa = frankwolfe(network, trips, socostfn, nothroughnodes=nothroughnodes);

uesoln_fw = frankwolfe(network, trips, uecostfn, nothroughnodes=nothroughnodes)
sosoln_fw = frankwolfe(network, trips, socostfn, nothroughnodes=nothroughnodes);

uesoln_cfw = conjugatefrankwolfe(network, trips, uecostfn, nothroughnodes=nothroughnodes)
sosoln_cfw = conjugatefrankwolfe(network, trips, socostfn, nothroughnodes=nothroughnodes);
