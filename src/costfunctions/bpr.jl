function BPR(b, C, F, p)
    f(x) = F*(1 + b*(x/C)^p)
    df(x) = F*b*(p/C)*(x/C)^(p-1)
    ddf(x) = F*b*(p*(p-1)/(C^2))*(x/C)^(p-2)

    (f, df, ddf)
end
BPR(data::Dict) = BPR(data[:b], data[:capacity], data[:free_flow_time], data[:power])
