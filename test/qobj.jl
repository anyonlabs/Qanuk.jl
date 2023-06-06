using Qanuk
using Test

@testset "ket2dm" begin
    @testset "ensure type consistency" begin
        function test_consistent_type(dtype)
            ψ = Ket{dtype}([dtype(1.0), dtype(2.0)])

            ρ = ket2dm(ψ)

            @test typeof(ρ) == DenseOperator{2, dtype}
        end

        test_consistent_type(ComplexF32)
        test_consistent_type(ComplexF64)
    end
end

@testset "anticommute" begin
    @testset "ensure type consistency" begin
        function test_consistent_type(a, b, expectedType)
            value = anticommute(a, b)
            @test typeof(value) == expectedType
        end

        for dtype in (ComplexF64, ComplexF32)
            test_consistent_type(sigma_x(dtype), sigma_x(dtype), DiagonalOperator{2, dtype})
        end
    end
end

@testset "simple_bra_ket" begin
    Ψ_0 = spin_up()
    Ψ_1 = spin_down()
    print(Ψ_0)

    @test normalize!(2*Ψ_0)≈ Ψ_0

    Ψ_p = (1.0 / sqrt(2.0)) * (Ψ_0 + Ψ_1)
    Ψ_m = (1.0 / sqrt(2.0)) * (Ψ_0 - Ψ_1)
    _Ψ = Bra(Ψ_p)
    print(_Ψ)

    # scalar multiplication
    Ψ_0 = Ket([1.,2.])
    a=10.0
    Ψ_scaled = a*Ψ_0 
    Ψ_scaled2= Ψ_0*a 

    @test typeof(Ψ_scaled )==Ket{ComplexF64}
    @test typeof(Ψ_scaled2)==Ket{ComplexF64}

    @test Ψ_scaled ≈Ket([10.,20.])
    @test Ψ_scaled2≈Ket([10.,20.])

    a=ComplexF64(10.0)
    Ψ_scaled = a*Ψ_0 
    Ψ_scaled2= Ψ_0*a 

    @test typeof(Ψ_scaled )==Ket{ComplexF64}
    @test typeof(Ψ_scaled2)==Ket{ComplexF64}

    @test Ψ_scaled ≈Ket([10.,20.])
    @test Ψ_scaled2≈Ket([10.,20.])

    Ψ_0 = spin_up()
    Ψ_1 = spin_down()

    # test if adjoin operations work properly
    @test adjoint(Ψ_p) ≈ Bra(Ψ_p)
    @test adjoint(_Ψ) ≈ Ψ_p
    # Test amplitude is unity
    @test (_Ψ * Ψ_p) ≈ Complex(1.0)

    @test get_num_qubits(_Ψ) == 1
    @test get_num_bodies(Ket([1.0, 0.0, 0.0]), 3) == 1

    M_0 = Ψ_0 * Bra(Ψ_0)
    @test size(M_0) == (2, 2)

    H = hadamard(1)
    X = sigma_x(1)
    Y = sigma_y(1)
    Z = sigma_z(1)

    vals, vecs = eigen(hadamard())
    @test vals[1] ≈ -1.0
    @test vals[2] ≈ 1.0 

    # Hadamard gate on a single qubit
    @test H * Ψ_0 ≈ Ψ_p
    @test H * Ψ_1 ≈ Ψ_m

    # Base.:*(::Bra,::Operator)
    @test _Ψ*hadamard() ≈ Bra(spin_up())

    # Ctor from adjoint
    @test adjoint(hadamard()) ≈ hadamard()

    # Bit flip gate (sigma_x)
    @test X * Ψ_0 ≈ Ψ_1
    @test X * Ψ_1 ≈ Ψ_0
    @test (Bra(Ψ_1) * get_operator(X)) * Ψ_0 ≈ Complex(1.0)

    # Z gate
    @test Z * Ψ_0 ≈ Ψ_0
    @test Z * Ψ_1 ≈ -Ψ_1

    # Swap gate
    ψ_input=Ket([1.,2.,3.,4.,5.,6.,7.,8.])
    ψ_input_32=Ket(ComplexF32[1.,2.,3.,4.])

    ψ_1_2  =Ket([1.,2.,5.,6.,3.,4.,7.,8.])
    ψ_1_3  =Ket([1.,5.,3.,7.,2.,6.,4.,8.])

    @test ψ_1_2≈swap(1,2)*ψ_input
    @test ψ_1_2≈swap(2,1)*ψ_input
    @test ψ_1_3≈swap(1,3)*ψ_input
    @test ψ_1_3≈swap(3,1)*ψ_input

    @test typeof(swap(1,2)*ψ_input_32)==Ket{ComplexF32}

    @test_throws DomainError swap(1,10)*ψ_input

    # ISwap gate
    ψ_1_2  =Ket([1.,2.,5.0*im,6.0*im,3.0*im,4.0*im,7.,8.])
    ψ_1_3  =Ket([1.,5.0*im,3.,7.0*im,2.0*im,6.,4.0*im,8.])

    @test ψ_1_2≈iswap(1,2)*ψ_input
    @test ψ_1_2≈iswap(2,1)*ψ_input
    @test ψ_1_3≈iswap(1,3)*ψ_input
    @test ψ_1_3≈iswap(3,1)*ψ_input

    @test typeof(iswap(1,2)*ψ_input_32)==Ket{ComplexF32}

    @test_throws DomainError iswap(1,10)*ψ_input

    # ISwapDagger gate
    ψ_1_2  =Ket([1.,2.,5.0*-im,6.0*-im,3.0*-im,4.0*-im,7.,8.])
    ψ_1_3  =Ket([1.,5.0*-im,3.,7.0*-im,2.0*-im,6.,4.0*-im,8.])

    @test ψ_1_2≈iswap_dagger(1,2)*ψ_input
    @test ψ_1_2≈iswap_dagger(2,1)*ψ_input
    @test ψ_1_3≈iswap_dagger(1,3)*ψ_input
    @test ψ_1_3≈iswap_dagger(3,1)*ψ_input

    @test typeof(iswap_dagger(1,2)*ψ_input_32)==Ket{ComplexF32}

    @test_throws DomainError iswap_dagger(1,10)*ψ_input

end

@testset "operator_exp" begin
    theta = pi/8
    exponential = exp(-im*theta/2*sigma_x())
    @test exponential ≈ rotation_x(theta)
end

@testset "pauli_operators" begin
    x = sigma_x()
    z = sigma_z()
    y = sigma_y()
    @test x[1,1] ≈ 0.0
    @test x[1,2] ≈ 1.0
    @test y ≈ 1.0im*x*z
    #commutation relations
    @test commute(x,y) ≈ 2.0im*z
    @test commute(y,z) ≈ 2.0im*x
    @test commute(z,x) ≈ 2.0im*y
    @test anticommute(x,x) ≈ 2.0*eye()

    vals, vecs = eigen(z)
    @test vals[1] ≈ -1.0
    @test vals[2] ≈ 1.0 
    
    xy = kron(x, y)
    @test get_num_qubits(xy) == 2
end

@testset "get_embed_operator" begin
    X = sigma_x()
    system = MultiBodySystem(2, 2)
    target = 1
    embed_operator = get_embed_operator(X, target, system)
    @test embed_operator ≈ kron(sigma_x(), eye())

    target = 2
    embed_operator = get_embed_operator(X, target, system)
    @test embed_operator ≈ kron(eye(), sigma_x())
end

@testset "operator_exceptions" begin
    non_integer_qubits = DenseOperator(zeros(3, 3))
    @test_throws DomainError get_num_qubits(non_integer_qubits)

    non_integer_qutrit = DenseOperator(zeros(2, 2))
    @test_throws DomainError get_num_bodies(non_integer_qutrit, 3)
end

@testset "ket_exceptions" begin
    non_integer_qubits = Ket(zeros(3))
    @test_throws DomainError get_num_qubits(non_integer_qubits)

    non_integer_qutrit = Bra(Ket(zeros(2)))
    @test_throws DomainError get_num_bodies(non_integer_qutrit, 3)
end


@testset "fock_space" begin
    hspace_size = 8
    a_dag = create(hspace_size)
    a = destroy(hspace_size)
    n = number_op(hspace_size)
    #adding a photon to a photon number base vector
    @test a_dag*fock(3,hspace_size) ≈ sqrt(4.0)*fock(4,hspace_size)
    #subtracting a photon
    @test a*fock(3,hspace_size) ≈ sqrt(3.0)*fock(2,hspace_size)
    @test expected_value(n,fock(3,hspace_size))==3
end

@testset "density_matrix" begin
    Ψ_0 = fock(1, 2)
    @test ket2dm(Ψ_0) ≈ (Ψ_0*Bra(Ψ_0))
    @test fock_dm(1,2) ≈ (Ψ_0*Bra(Ψ_0))
end

@testset "coherent state" begin
    ψ = coherent(2.0,20)
    @test expected_value(number_op(20),ψ) ≈ 4.0 atol=1.0e-4
end

@testset "cat states" begin
    alpha = 0.25
    hspace_size=8
    ψ_0 = normalize!(coherent(alpha, hspace_size)+coherent(-alpha,hspace_size))
    ψ_1 = normalize!(coherent(alpha, hspace_size)-coherent(-alpha,hspace_size))

    @test Bra(ψ_0)*ψ_1 ≈ 0.0
    @test wigner(ket2dm(ψ_0),0.0,0.0) ≈ -0.636619772367581382432888403855 atol=1.0e-4
end

@testset "genlaguerre" begin
    @test genlaguerre(0, 0, 0) == 1
end

@testset "qutrit_operators" begin
    hilbert_space_size_per_qutrit = 3
    qutrit_operator = DenseOperator([1 0 0;
                                0 1 0
                                0 0 1])
    @test get_num_bodies(kron(qutrit_operator, qutrit_operator),
        hilbert_space_size_per_qutrit) == 2
end

@testset "is_hermitian" begin
    @test is_hermitian(sigma_y())
    @test !is_hermitian(sigma_p())
end

@testset "get_measurement_probabilities" begin
    ket = 1/sqrt(5)*Ket([1, 0, -im, 0, 0, im, -1, 1, 0])
    probabilities = get_measurement_probabilities(ket)
    @test probabilities ≈ [0.2, 0, 0.2, 0, 0, 0.2, 0.2, 0.2, 0]

    target_bodies = [2]
    hspace_size_per_body = 3
    probabilities = get_measurement_probabilities(ket, target_bodies, hspace_size_per_body)
    @test probabilities ≈ 1/5*[2, 1, 2]

    target_bodies = [1,2]
    probabilities = get_measurement_probabilities(ket, target_bodies, hspace_size_per_body)
    @test probabilities ≈ [0.2, 0, 0.2, 0, 0, 0.2, 0.2, 0.2, 0]

    ket = 1/sqrt(3)*Ket([1, 0, -im, 1])
    target_bodies = [1]
    probabilities = get_measurement_probabilities(ket, target_bodies)
    @test probabilities ≈ [1/3, 2/3]

    ket = 1/sqrt(7)*Ket([1, 0, -im, 0, 0, im, -1, 1, 0, 1, 1, 0])
    target_bodies = [1, 2]
    hspace_size_per_body = [2, 3, 2]
    probabilities = get_measurement_probabilities(ket, target_bodies, hspace_size_per_body)
    @test probabilities ≈ 1/7*[1, 1, 1, 2, 1, 1]

    wrong_hspace_size_per_body = Int[]
    @test_throws ErrorException get_measurement_probabilities(ket, target_bodies,
        wrong_hspace_size_per_body)

    not_unique_targets = [1, 1]
    @test_throws ErrorException get_measurement_probabilities(ket, not_unique_targets,
        hspace_size_per_body)

    unsorted_targets = [2, 1]
    @test_throws ErrorException get_measurement_probabilities(ket, unsorted_targets,
        hspace_size_per_body)

    large_targets = [1, 4]
    @test_throws ErrorException get_measurement_probabilities(ket, large_targets,
        hspace_size_per_body)

    empty_target_bodies = Int[]
    @test_throws ErrorException get_measurement_probabilities(ket, empty_target_bodies,
        hspace_size_per_body)
end
