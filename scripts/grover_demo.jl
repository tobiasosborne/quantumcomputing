#!/usr/bin/env julia
#
# grover_demo.jl — Step-by-step Grover's algorithm demonstration
#
# Part of the "Introduction to Quantum Computing" exercise solutions.
# Demonstrates Grover's algorithm for n=2 qubits with x=0001.

using LinearAlgebra

# ── Pauli matrices and Hadamard ───────────────────────────────
const I2 = ComplexF64[1 0; 0 1]
const H_gate = (1/√2) * ComplexF64[1 1; 1 -1]

# ── Build n-qubit Hadamard ────────────────────────────────────
function hadamard_n(n::Int)
    H_n = H_gate
    for _ in 2:n
        H_n = kron(H_n, H_gate)
    end
    return H_n
end

# ── Build phase oracle for bit string x ───────────────────────
function phase_oracle(x::Vector{Int})
    N = length(x)
    return Diagonal(ComplexF64[(-1)^x[j] for j in 1:N])
end

# ── Build diffusion operator 2|U><U| - I ──────────────────────
function diffusion_operator(n::Int)
    N = 2^n
    U = ones(ComplexF64, N) / √N  # uniform superposition
    return 2 * U * U' - I(N)
end

# ── Grover iterate ────────────────────────────────────────────
function grover_iterate(oracle, diffusion)
    return diffusion * oracle
end

# ── Main demonstration ────────────────────────────────────────
function main()
    n = 2
    N = 2^n
    x = [0, 0, 0, 1]  # x_00=0, x_01=0, x_10=0, x_11=1

    println("Grover's Algorithm Demo")
    println("n = $n qubits, N = $N")
    println("x = $x (solution at index 4, i.e., |11⟩)")
    println("=" ^ 50)

    # Build operators
    H_n = hadamard_n(n)
    O_x = phase_oracle(x)
    D = diffusion_operator(n)
    G = grover_iterate(O_x, D)

    # Initial state
    ψ = zeros(ComplexF64, N)
    ψ[1] = 1.0  # |00⟩

    println("\nInitial state: |00⟩")
    display_state(ψ, n)

    # Apply Hadamard
    ψ = H_n * ψ
    println("\nAfter H⊗H (uniform superposition):")
    display_state(ψ, n)

    # Grover iterations
    for k in 1:4
        ψ = G * ψ
        prob_solution = abs2(ψ[4])
        println("\nAfter k=$k Grover iteration(s):")
        display_state(ψ, n)
        println("  Success probability: $(round(prob_solution, digits=6))")
        println("  Theory: sin²($(2k+1)π/6) = $(round(sin((2k+1)*π/6)^2, digits=6))")
    end

    # Analytic check
    println("\n" * "=" ^ 50)
    println("Angle θ = sin⁻¹(√(t/N)) = sin⁻¹(1/2) = π/6")
    println("Optimal k̃ = π/(4θ) - 1/2 = π/(2π/3) - 1/2 = 1.0")
end

function display_state(ψ, n)
    N = 2^n
    for j in 1:N
        bits = string(j-1, base=2, pad=n)
        amp = ψ[j]
        if abs(amp) > 1e-10
            println("  |$bits⟩: $(round(amp, digits=6))  (prob=$(round(abs2(amp), digits=6)))")
        end
    end
end

main()
