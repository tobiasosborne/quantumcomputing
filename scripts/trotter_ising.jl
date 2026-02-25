#!/usr/bin/env julia
#
# trotter_ising.jl — Trotter error analysis for the transverse-field Ising model
#
# Part of the "Introduction to Quantum Computing" exercise solutions.
# Computes the exact time evolution and first-order Trotter approximation
# for a 4-qubit transverse-field Ising chain, measuring the operator-norm
# error as a function of Trotter step count.

using LinearAlgebra

# ── Pauli matrices ────────────────────────────────────────────
const I2 = ComplexF64[1 0; 0 1]
const σx = ComplexF64[0 1; 1 0]
const σy = ComplexF64[0 -im; im 0]
const σz = ComplexF64[1 0; 0 -1]

# ── Utility: place an operator at a specific qubit site ───────
function kron_at(op::Matrix, site::Int, n::Int)
    # Build the n-qubit operator with `op` at position `site`
    # and identity everywhere else
    ops = [i == site ? op : I2 for i in 1:n]
    return foldl(kron, ops)
end

# ── Build the full Hamiltonian matrix ─────────────────────────
function ising_hamiltonian(n::Int, λ::Float64)
    d = 2^n
    H = zeros(ComplexF64, d, d)
    # XX nearest-neighbour coupling
    for j in 1:n-1
        H .+= kron_at(σx, j, n) * kron_at(σx, j+1, n)
    end
    # Transverse field
    for j in 1:n
        H .+= λ .* kron_at(σz, j, n)
    end
    return Hermitian(H)
end

# ── Extract individual local terms ────────────────────────────
function ising_local_terms(n::Int, λ::Float64)
    terms = Matrix{ComplexF64}[]
    # XX terms
    for j in 1:n-1
        push!(terms, kron_at(σx, j, n) * kron_at(σx, j+1, n))
    end
    # Z terms
    for j in 1:n
        push!(terms, λ .* kron_at(σz, j, n))
    end
    return terms
end

# ── First-order Trotter approximation ─────────────────────────
function trotter_step(terms::Vector{Matrix{ComplexF64}}, dt::Float64)
    d = size(terms[1], 1)
    U = Matrix{ComplexF64}(I, d, d)
    for h in terms
        U = exp(-im * h * dt) * U
    end
    return U
end

function trotter_approx(terms::Vector{Matrix{ComplexF64}}, t::Float64, nsteps::Int)
    dt = t / nsteps
    U_step = trotter_step(terms, dt)
    return U_step^nsteps
end

# ── Main computation ──────────────────────────────────────────
function main()
    n_qubits = 4
    λ = 0.5
    t = 1.0

    println("Transverse-field Ising model: n=$n_qubits qubits, λ=$λ, t=$t")
    println("=" ^ 60)

    # Exact evolution
    H = ising_hamiltonian(n_qubits, λ)
    U_exact = exp(-im * Matrix(H) * t)

    # Local terms for Trotterization
    terms = ising_local_terms(n_qubits, λ)
    println("Number of local terms: L=$(length(terms))")
    println()

    # Compute Trotter errors
    nsteps_list = [1, 2, 5, 10, 20, 50, 100, 200, 500]

    println("Trotter steps  |  Operator-norm error  |  Error × n")
    println("-" ^ 60)

    for ns in nsteps_list
        U_approx = trotter_approx(terms, t, ns)
        err = opnorm(U_exact - U_approx)
        # err × n should be roughly constant for O(1/n) scaling
        println("  $(lpad(ns, 5))       |  $(lpad(round(err, sigdigits=4), 12))      |  $(round(err * ns, sigdigits=4))")
    end

    # Save data for pgfplots
    open(joinpath(@__DIR__, "..", "latex", "data", "trotter_error.dat"), "w") do f
        println(f, "nsteps\terror")
        for ns in nsteps_list
            U_approx = trotter_approx(terms, t, ns)
            err = opnorm(U_exact - U_approx)
            println(f, "$ns\t$err")
        end
    end
    println("\nData saved to latex/data/trotter_error.dat")
end

main()
