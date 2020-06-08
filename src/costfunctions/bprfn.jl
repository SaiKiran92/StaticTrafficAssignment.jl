function BPR(data)
    b, C, F, p = data[:b], data[:capacity], data[:free_flow_time], data[:power]

    fn(x) = F*(1 + b*(x/C)^p)
    dfn(x) = F*b*(p/C)*(x/C)^(p-1)
    ddfn(x) = F*b*(p*(p-1)/(C^2))*(x/C)^(p-2)

    return (fn, dfn, ddfn)
end
