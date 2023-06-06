using BenchmarkTools
using Qanuk
using JSON
using Plots

include("QanukBenchmarking.jl")

@task "Z" nqubits=nqubits begin
    map(nqubits) do k
        t = @benchmark apply_gate!(ψ, sigma_z(target_qubit_1)) setup=(ψ=rand_state($k))
        minimum(t).time
    end
end

outputpath=joinpath(commonpath,datapath,"Z")

if !ispath(outputpath)
    mkpath(outputpath)
end

write(joinpath(outputpath,"Z_$(time_stamp).json"), JSON.json(benchmarks))

plot(nqubits,
    benchmarks["Z"]["times"],
    label="Z",
    yaxis=:log, 
    color="blue",
    dpi=dpi
)

scatter!(
    nqubits,
    benchmarks["Z"]["times"],
    label=nothing, 
    color="blue",
    dpi=dpi
)

savefig(joinpath(outputpath,"plot_Z_$(time_stamp).png"))