@testset "Solvers" begin
    T = Float64
    Re = 500.0
    viscosity_model = LaminarModel(; Re)

    n = 50
    x = LinRange(0, 2π, n + 1)
    y = LinRange(0, 2π, n + 1)
    setup = Setup(x, y; viscosity_model)

    pressure_solver = FourierPressureSolver(setup)

    t_start, t_end = tlims = (0.0, 5.0)

    initial_velocity_u(x, y) = cos(x)sin(y)
    initial_velocity_v(x, y) = -sin(x)cos(y)
    initial_pressure(x, y) = -1 / 4 * (cos(2x) + cos(2y))
    V₀, p₀ = create_initial_conditions(
        setup,
        t_start;
        initial_velocity_u,
        initial_velocity_v,
        initial_pressure,
        pressure_solver,
    )

    @testset "Steady state" begin
        problem = SteadyStateProblem(setup, V₀, p₀)
        V, p = solve(problem)
        uₕ = V[setup.grid.indu]
        vₕ = V[setup.grid.indv]
        @test norm(uₕ .- mean(uₕ)) / mean(uₕ) < 1e-8
        @test norm(vₕ .- mean(vₕ)) / mean(vₕ) < 1e-8
    end

    # Exact solutions
    F(t) = exp(-2t / Re)
    u(x, y, t) = initial_velocity_u(x, y) * F(t)
    v(x, y, t) = initial_velocity_v(x, y) * F(t)
    (; xu, yu, xv, yv) = setup.grid
    uₕ = u.(xu, yu, t_end)
    vₕ = v.(xv, yv, t_end)
    V_exact = [uₕ[:]; vₕ[:]]

    @testset "Unsteady solvers" begin
        problem = UnsteadyProblem(setup, V₀, p₀, tlims)

        @testset "Explicit Runge Kutta" begin
            V, p = solve(problem, RK44(); Δt = 0.01, pressure_solver, inplace = false)
            @test norm(V - V_exact) / norm(V_exact) < 1e-4
            Vip, pip = solve(problem, RK44(); Δt = 0.01, pressure_solver, inplace = true)
            @test Vip ≈ V
            @test pip ≈ p
        end

        @testset "Implicit Runge Kutta" begin
            V, p = solve(problem, RIA2(); Δt = 0.01, pressure_solver, inplace = true)
            @test_broken norm(V - V_exact) / norm(V_exact) < 1e-3
            @test_broken solve(
                problem,
                RIA2();
                Δt = 0.01,
                pressure_solver,
                inplace = false,
            ) isa Tuple
        end

        @testset "One-leg beta method" begin
            V, p = solve(
                problem,
                OneLegMethod{T}();
                method_startup = RK44(),
                Δt = 0.01,
                pressure_solver,
                inplace = false,
            )
            @test norm(V - V_exact) / norm(V_exact) < 1e-4
            Vip, pip = solve(
                problem,
                OneLegMethod{T}();
                method_startup = RK44(),
                Δt = 0.01,
                pressure_solver,
                inplace = true,
            )
            @test Vip ≈ V
            @test pip ≈ p
        end

        @testset "Adams-Bashforth Crank-Nicolson" begin
            @test_broken solve(
                problem,
                AdamsBashforthCrankNicolsonMethod{T}();
                method_startup = RK44(),
                Δt = 0.01,
                pressure_solver,
                inplace = false,
            ) isa NamedTuple
            V, p = solve(
                problem,
                AdamsBashforthCrankNicolsonMethod{T}();
                method_startup = RK44(),
                Δt = 0.01,
                pressure_solver,
                inplace = true,
            )
            @test norm(V - V_exact) / norm(V_exact) < 1e-4
        end
    end
end
