"""
    get_timestep(setup)

Estimate time step based on eigenvalues of operators, using Gershgorin.
"""
function get_timestep(setup, time_stepper)
    @unpack Nu, Nv = setup.grid
    @unpack Iu_ux, Iu_vx, Iv_uy, Iv_vy = setup.discretization
    @unpack yIu_ux, yIu_vx, yIv_uy, yIv_vy = setup.discretization
    @unpack Au_ux, Au_uy, Av_vx, Av_vy = setup.discretization
    @unpack CFL = setup.time

    # For explicit methods only
    if isexplicit(time_stepper)
        ## Convective part
        Cu =
            Cux * spdiagm(Iu_ux * uₕ + yIu_ux) * Au_ux +
            Cuy * spdiagm(Iv_uy * vₕ + yIv_uy) * Au_uy
        Cv =
            Cvx * spdiagm(Iu_vx * uₕ + yIu_vx) * Av_vx +
            Cvy * spdiagm(Iv_vy * vₕ + yIv_vy) * Av_vy

        test = spdiagm(Ωu⁻¹) * Cu
        sum_conv_u = abs.(test) * ones(Nu) - Diagonal(abs.(test)) - Diagonal(test)
        test = spdiagm(Ωv⁻¹) * Cv
        sum_conv_v = abs.(test) * ones(Nv) - Diagonal(abs.(test)) - Diagonal(test)
        λ_conv = max(maximum(sum_conv_u), maximum(sum_conv_v))

        ## Diffusive part
        test = spdiagm(Ωu⁻¹) * Diffu
        sum_diff_u = abs.(test) * ones(Nu) - Diagonal(abs.(test)) - Diagonal(test)
        test = spdiagm(Ωv⁻¹) * Diffv
        sum_diff_v = abs.(test) * ones(Nv) - Diagonal(abs.(test)) - Diagonal(test)
        λ_diff = max(maximum(sum_diff_u), maximum(sum_diff_v))

        # Based on max. value of stability region
        Δt_diff = λ_diff_max(time_stepper, setup) / λ_diff

        # Based on max. value of stability region (not a very good indication
        # For the methods that do not include the imaginary axis)

        Δt_conv = λ_conv_max / λ_conv
        Δt = CFL * min(Δt_conv, Δt_diff)
    end

    Δt
end
