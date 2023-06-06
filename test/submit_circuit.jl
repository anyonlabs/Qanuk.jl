using Qanuk
using Test

@testset "submit_job_iswap" begin
    c = QuantumCircuit(qubit_count = 2)
    push!(c, sigma_x(1))
    push!(c, iswap(1, 2))

    try
        owner = ENV["Qanuk_ID"]
        token = ENV["Qanuk_TOKEN"]
        host = ENV["Qanuk_HOST"]
        job_uuid, status =
            submit_circuit(c, owner = owner, token = token, shots = 101, host = host)
        id, st, msg =
            get_circuit_status(job_uuid, owner = owner, token = token, host = host)
        println("id:" * job_uuid * "  status code:" * string(st) * " message:" * msg)
    catch e
        println(e)

    end
end
