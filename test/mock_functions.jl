using Qanuk
using HTTP

host="http://example.anyonsys.com"
user="test_user"
access_token="not_a_real_access_token"

function post_checker(url::String,access_token::String,body::String)

    expected_url=host*"/"*Qanuk.path_circuits
    expected_access_token=access_token
    expected_json="{\"num_repetitions\":100,\"circuit\":{\"operations\":[{\"parameters\":{},\"type\":\"x\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,0]}]}}"

    @assert url==expected_url ("received: \n$url, \nexpected: \n$expected_url")
    @assert access_token==expected_access_token  ("received: \n$access_token, expected: \n$expected_access_token")
    @assert body==expected_json  ("received: \n$body, expected: \n$expected_json")

    return HTTP.Response(200, [], 
        body="{\"circuitID\":\"8050e1ed-5e4c-4089-ab53-cccda1658cd0\"}";
    )
end

function post_checker_transpiled(url::String,access_token::String,body::String)

    expected_url=host*"/"*Qanuk.path_circuits
    expected_access_token=access_token
    expected_json="{\"num_repetitions\":100,\"circuit\":{\"operations\":[{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,0]}]}}"

    @assert url==expected_url ("received: \n$url, \nexpected: \n$expected_url")
    @assert access_token==expected_access_token  ("received: \n$access_token, expected: \n$expected_access_token")
    @assert body==expected_json  ("received: \n$body, expected: \n$expected_json")

    return HTTP.Response(200, [], 
        body="{\"circuitID\":\"8050e1ed-5e4c-4089-ab53-cccda1658cd0\"}";
    )
end

function post_checker_toffoli(url::String,access_token::String,body::String)

    expected_url=host*"/"*Qanuk.path_circuits
    expected_access_token=access_token
    expected_json="{\"num_repetitions\":100,\"circuit\":{\"operations\":[{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{\"phi\":3.9269908169872414},\"type\":\"p\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[0,1]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"t_dag\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{\"phi\":3.9269908169872414},\"type\":\"p\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[0,1]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[1,2]},{\"parameters\":{\"phi\":-3.9269908169872414},\"type\":\"p\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"t_dag\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[2]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[0,1]},{\"parameters\":{},\"type\":\"t\",\"qubits\":[0]},{\"parameters\":{},\"type\":\"z_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"t\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_minus_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"cz\",\"qubits\":[0,1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"x_90\",\"qubits\":[1]},{\"parameters\":{},\"type\":\"z_90\",\"qubits\":[1]}]}}"

    @assert url==expected_url ("received: \n$url, \nexpected: \n$expected_url")
    @assert access_token==expected_access_token  ("received: \n$access_token, expected: \n$expected_access_token")
    @assert body==expected_json  ("received: \n$body, expected: \n$expected_json")

    return HTTP.Response(200, [], 
        body="{\"circuitID\":\"8050e1ed-5e4c-4089-ab53-cccda1658cd0\"}";
    )
end

function request_checker(url::String,access_token::String)
    myregex=Regex("(.*)(/$(Qanuk.path_circuits)/)(.*)")
    match_obj=match(myregex,url)

    if !isnothing(match_obj)

        myregex=Regex("(.*)(/$(Qanuk.path_circuits)/)(.*)(/$(Qanuk.path_results))\$")   
        match_obj=match(myregex,url)
                
        if !isnothing(match_obj)
            # caller is :get_result
            return HTTP.Response(200, [], 
                body="{\"histogram\":{\"001\":\"100\"}}"
            ) 
        else
            myregex=Regex("(.*)(/$(Qanuk.path_circuits)/)([^/]*)\$")
            match_obj=match(myregex,url)

            if !isnothing(match_obj)
                # caller is :get_status
                return HTTP.Response(200, [], 
                    body="{\"status\":{\"type\":\"succeeded\"}}"
                )
            end
        end
    end

    throw(NotImplementedError(:get_request,url))
end

stubStatusResponse(status::String) = HTTP.Response(200, [], body="{\"status\":{\"type\":\"$status\"}}")
stubFailedStatusResponse() = HTTP.Response(200, [], body="{\"status\":{\"type\":\"failed\"},\"message\":\"mocked\"}")
stubResult() = HTTP.Response(200, [], body="{\"histogram\":{\"001\":\"100\"}}")
stubFailureResult() = HTTP.Response(200, [], body="{\"status\":{\"type\":\"failed\"}}")
stubCancelledResultResponse() = HTTP.Response(200, [], body="{\"status\":{\"type\":\"cancelled\"}}")

# Returns a function that will yield the given responses in order as it's
# repeatedly called.
function stub_response_sequence(response_sequence::Vector{HTTP.Response})
  idx = 0

  return function(url::String, access_token::String)
    if idx >= length(response_sequence)
      throw(ErrorException("too many requests; response sequence exhausted"))
    end
    idx += 1
    return response_sequence[idx]
  end
end
