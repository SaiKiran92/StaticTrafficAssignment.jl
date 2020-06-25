using StaticTrafficAssignment
using DataFrames

nnodes, ftnode, linkdf, trips, geometry, bestsolution = readtntpdata("examples/data/SiouxFalls/")

nzones = size(trips)[1]
zonedf = DataFrame(:id => 1:nzones, :issource => ones(Bool, nzones), :issink => ones(Bool, nzones), :thruallowed => (1:nzones) .>= ftnode)

network = SimpleNetwork(nnodes, linkdf, zonedf; idkey=:id, issrckey=:issource, issnkkey=:issink, thrukey=:thruallowed,  upnkey=:init_node, dwnkey=:term_node)

uecostfn = CostFunctionUE(network, BPR)
socostfn = CostFunctionSO(network, BPR)

@time aonsoln = allornothing(network, trips, uecostfn);

@time uesoln_msa = msa(network, trips, uecostfn);
@time sosoln_msa = msa(network, trips, socostfn);

@time uesoln_fw = frankwolfe(network, trips, uecostfn);
@time sosoln_fw = frankwolfe(network, trips, socostfn);

@time uesoln_cfw = conjugatefrankwolfe(network, trips, uecostfn);
@time sosoln_cfw = conjugatefrankwolfe(network, trips, socostfn);

@time uesoln_B = algorithmB(network, trips, uecostfn; λ=0.1);
@time sosoln_B = algorithmB(network, trips, socostfn; λ=0.05);
