using JSON
using HTTP

Base.@kwdef struct Status
    type::String
    message::String=""
end

get_status_type(s::Status)=s.type
get_status_message(s::Status)=s.message

function Base.show(io::IO, status::Status)
    if status.message ==""
        println(io, "Status: $(status.type)")
    else
        println(io, "Status: $(status.type)")
        println(io, "Message: $(status.message)")
    end
end

abstract type Requestor end

get_request(requestor::Requestor,::String,::String,::String) = 
    throw(NotImplementedError(:get_request,requestor))
post_request(requestor::Requestor,::String,::String,::String) = 
    throw(NotImplementedError(:post_request,requestor))

struct HTTPRequestor<:Requestor end
struct MockRequestor<:Requestor 
    request_checker::Function
    post_checker::Function
end

const path_circuits ="circuits"
const path_results  ="result"

const queued_status     ="queued"
const running_status    ="running"
const succeeded_status  ="succeeded"
const failed_status     ="failed"
const cancelled_status  ="cancelled"

const possible_status_list=[
    failed_status,
    succeeded_status,
    running_status,
    queued_status,
    cancelled_status,
]

function post_request(
    ::HTTPRequestor,
    url::String,
    access_token::String,
    body::String
    )::HTTP.Response

    return HTTP.post(
        url, 
        headers=Dict(
            "Authorization"=>"Bearer $access_token",
            "Content-Type"=>"application/json"
            ),
        body=body,
    )
end

function post_request(
    mock_requester::MockRequestor,
    url::String,
    access_token::String,
    body::String
    )::HTTP.Response

    return mock_requester.post_checker(url,access_token,body)

end


function get_request(
    ::HTTPRequestor,
    url::String,
    access_token::String,
    )::HTTP.Response

    return HTTP.get(
        url, 
        headers=Dict(
            "Authorization"=>"Bearer $access_token",
            "Content-Type"=>"application/json"
            ),
    )
end

function get_request(
    mock_requester::MockRequestor,
    url::String,
    access_token::String
    )::HTTP.Response

    return mock_requester.request_checker(url,access_token)
end


"""
    serialize_job(circuit::QuantumCircuit,repetitions::Integer)

Creates a JSON-formatted String containing the circuit configuration to be sent 
to a `QPU` service, along with the number of repetitions requested.

# Examples
```jldoctest
julia> c = QuantumCircuit(qubit_count = 2,gates=[sigma_x(1)])
Quantum Circuit Object:
   qubit_count: 2 
q[1]:──X──
          
q[2]:─────
          



julia> serialize_job(c,10)
"{\\\"num_repetitions\\\":10,\\\"circuit\\\":{\\\"operations\\\":[{\\\"parameters\\\":{},\\\"type\\\":\\\"x\\\",\\\"qubits\\\":[0]}]}}"

```
"""
function serialize_job(circuit::QuantumCircuit,repetitions::Integer)::String
  
    circuit_description=Dict(
        "circuit"=>Dict{String,Any}(
                "operations"=>Vector{Dict{String,Any}}()
            ),
        "num_repetitions"=>repetitions
    )

    for gate in get_circuit_gates(circuit)
        push!(
            circuit_description["circuit"]["operations"],
            Dict{String,Any}(
                "type"=> get_instruction_symbol(gate),
                #server-side qubit numbering starts at 0
                "qubits"=> [n-1 for n in get_connected_qubits(gate)],
                "parameters"=> get_gate_parameters(gate)  
            )
        )
    end

    circuit_json=JSON.json(circuit_description)

    return circuit_json
end

"""
    Client

A data structure to represent a *Client* to a QPU service.  
# Fields
- `host::String` -- URL of the QPU server.
- `user::String` -- Username.
- `access_token::String` -- User access token.

# Example
```jldoctest
julia> c = Client(host="http://example.anyonsys.com",user="test_user",access_token="not_a_real_access_token")
Client for QPU service:
   host:         http://example.anyonsys.com
   user:         test_user 
 
  
```
"""
Base.@kwdef struct Client 
    host::String
    user::String
    access_token::String
    requestor::Requestor=HTTPRequestor()
end

function Base.show(io::IO, client::Client)
    println(io, "Client for QPU service:")
    println(io, "   host:         $(client.host)")
    println(io, "   user:         $(client.user) ")
end

"""
    get_host(Client)

Returns host URL of a `Client` to a `QPU` service.  

# Example
```jldoctest
julia> c = Client(host="http://example.anyonsys.com",user="test_user",access_token="not_a_real_access_token");

julia> get_host(c)
"http://example.anyonsys.com"

```
"""
get_host(client::Client)        =client.host
get_requestor(client::Client)   =client.requestor


"""
    submit_circuit(client::Client,circuit::QuantumCircuit,num_repetitions::Integer)

Submit a circuit to a `Client` of `QPU` service, requesting a number of 
repetitions (num_repetitions). Returns circuitID.  

# Example

```jldoctest mylabel
julia> submit_circuit(client,QuantumCircuit(qubit_count=3,gates=[sigma_x(3),control_z(2,1)]),100)
"8050e1ed-5e4c-4089-ab53-cccda1658cd0"

```
"""
function submit_circuit(client::Client,circuit::QuantumCircuit,num_repetitions::Integer)::String

    circuit_json=serialize_job(circuit,num_repetitions)
  
    path_url=get_host(client)*"/"*path_circuits
    
    response=post_request(
        get_requestor(client),
        path_url,
        client.access_token,
        circuit_json)

    body=JSON.parse(read_response_body(response.body))

    @assert haskey(body,"circuitID") ("Server returned an invalid response, without a circuitID field.")

    return body["circuitID"]
end

"""
    get_status(client::Client,circuitID::String)::Dict{String, String}

Obtain the status of a circuit computation through a `Client` of a `QPU` service.
Returns status::Dict containing status["type"]: 
    -"queued"   : Computation in queue.
    -"running"  : Computation being processed.
    -"failed"   : QPU service has returned an error message.
    -"succeeded": Computation is completed, result is available.

In the case of status["type"]=="failed", the server error is contained in status["message"].

# Example


```jldoctest
julia> circuitID=submit_circuit(client,QuantumCircuit(qubit_count=3,gates=[sigma_x(3),control_z(2,1)]),100)
"8050e1ed-5e4c-4089-ab53-cccda1658cd0"

julia> get_status(client,circuitID)
Status: succeeded

```
"""
function get_status(client::Client,circuitID::String)::Status

    path_url=get_host(client)*"/"*path_circuits*"/"*"$circuitID"
    
    response=get_request(
        get_requestor(client),
        path_url,
        client.access_token
        )

    body=JSON.parse(read_response_body(response.body))

    @assert haskey(body,"status")
    @assert haskey(body["status"],"type")

    if !(body["status"]["type"] in possible_status_list)
        throw(ArgumentError("Server returned unrecognized status type: $(body["status"]["type"])"))
    end

    if body["status"]["type"]==failed_status
        return Status(type=body["status"]["type"],message=body["message"])
    else
        return Status(type=body["status"]["type"])
    end
end

"""
    get_result(client::Client,circuit::String)::Dict{String, Int}

Get the histogram of a completed circuit calculation, through a `Client` of a `QPU` service, 
by circuit identifier circuitID.

# Example


```jldoctest 
julia> circuitID=submit_circuit(client,QuantumCircuit(qubit_count=3,gates=[sigma_x(3),control_z(2,1)]),100)
"8050e1ed-5e4c-4089-ab53-cccda1658cd0"

julia> get_status(client,circuitID);

julia> get_result(client,circuitID)
Dict{String, Int64} with 1 entry:
  "001" => 100

```
"""
function get_result(client::Client,circuitID::String)::Dict{String, Int}

    path_url=get_host(client)*"/"*path_circuits*"/"*"$circuitID"*"/"*path_results
    
    response=get_request(
        get_requestor(client),
        path_url,
        client.access_token
        )

    body=JSON.parse(read_response_body(response.body))

    histogram=Dict{String,Int}()
    
    @assert haskey(body,"histogram")

    # convert from Dict{String,String} to Dict{String,Int}
    for (key,val) in body["histogram"]
        histogram[key]=parse(Int, val)
    end

    return histogram
end


abstract type AbstractQPU end

get_metadata(qpu::AbstractQPU) =
    throw(NotImplementedError(:get_metadata,qpu))

is_native_gate(qpu::AbstractQPU,::AbstractGate) =
    throw(NotImplementedError(:is_native_gate,qpu))

is_native_circuit(qpu::AbstractQPU,::QuantumCircuit) =
    throw(NotImplementedError(:is_native_circuit,qpu))

get_transpiler(qpu::AbstractQPU) =
    throw(NotImplementedError(:get_transpiler,qpu))

run_job(qpu::AbstractQPU, circuit::QuantumCircuit, num_repetitions::Integer) =
    throw(NotImplementedError(:run_job,qpu))

"""
    VirtualQPU

A data structure to represent a Quantum Simulator.  

# Example
```jldoctest
julia> qpu=VirtualQPU()
Quantum Simulator:
   developers:  Anyon Systems Inc.
   package:     Qanuk.jl


```
"""
struct VirtualQPU <: AbstractQPU end

get_metadata(qpu::VirtualQPU) = Dict{String,String}(
    "developers"  =>"Anyon Systems Inc.",
    "package"     =>"Qanuk.jl",
)

is_native_gate(::VirtualQPU,::AbstractGate)::Bool = true

is_native_circuit(::VirtualQPU,::QuantumCircuit)::Tuple{Bool,String} = (true,"")

get_transpiler(::VirtualQPU)=TrivialTranspiler()

function Base.show(io::IO, qpu::VirtualQPU)
    metadata=get_metadata(qpu)

    println(io, "Quantum Simulator:")
    println(io, "   developers:  $(metadata["developers"])")
    println(io, "   package:     $(metadata["package"])")
end

read_response_body(body::Base.CodeUnits{UInt8, String})=
    read_response_body(convert(Vector{UInt8},body))

function read_response_body(body::Vector{UInt8})::String
    # convert response body from binary to ASCII
    read_buffer=IOBuffer(reinterpret(UInt8, body))
    body_string=String(readuntil(read_buffer, 0x00))

    if length(body_string)!=length(body)
        throw(ArgumentError("Server returned an erroneous message, with nul terminator before end of string."))
    end

    return body_string
end

"""
    transpile_and_run_job(qpu::VirtualQPU, circuit::QuantumCircuit,num_repetitions::Integer;transpiler::Transpiler=get_transpiler(qpu))

This method first transpiles the input circuit using either the default transpiler, 
or any other transpiler passed as a key-word argument.  
The transpiled circuit is then run on a `QPU` simulator, repeatedly for the specified 
number of repetitions (num_repetitions). Returns the histogram of the 
completed circuit calculations, or an error message.

# Example
```jldoctest 
julia> qpu=VirtualQPU();

julia> transpile_and_run_job(qpu,QuantumCircuit(qubit_count=3,gates=[sigma_x(3),control_z(2,1)]) ,100)
Dict{String, Int64} with 1 entry:
  "001" => 100

```
"""
function transpile_and_run_job(
    qpu::VirtualQPU, 
    circuit::QuantumCircuit,
    num_repetitions::Integer;
    transpiler::Transpiler=get_transpiler(qpu)
    )::Dict{String,Int}

    transpiled_circuit=transpile(transpiler,circuit)

    is_native_circuit(qpu,transpiled_circuit)

    return run_job(qpu,transpiled_circuit,num_repetitions)
end

"""
    run_job(qpu::VirtualQPU, circuit::QuantumCircuit,num_repetitions::Integer)

Run a circuit computation on a `QPU` simulator, repeatedly for the specified 
number of repetitions (num_repetitions). Returns the histogram of the 
completed circuit calculations.

# Example
```jldoctest 
julia> qpu=VirtualQPU();

julia> run_job(qpu,QuantumCircuit(qubit_count=3,gates=[sigma_x(3),control_z(2,1)]) ,100)
Dict{String, Int64} with 1 entry:
  "001" => 100

```
"""
function run_job(qpu::VirtualQPU, circuit::QuantumCircuit,num_repetitions::Integer)::Dict{String,Int}
    
    data=simulate_shots(circuit, num_repetitions)
    
    histogram=Dict{String,Int}()

    for label in data
        if haskey(histogram,label)
            histogram[label]+=1
        else
            histogram[label]=1
        end
    end

    return histogram
end

