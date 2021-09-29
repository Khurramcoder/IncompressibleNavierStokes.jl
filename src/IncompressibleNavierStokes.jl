"Incompressible Navier-Stokes solvers"
module IncompressibleNavierStokes

using LinearAlgebra: Factorization, I, cholesky, factorize, ldiv!
using SparseArrays: SparseMatrixCSC, sparse, spdiagm, spzeros
using UnPack: @unpack
# using Plots: contour, contourf, title!
using Makie: Figure, Node, contourf

# Setup
include("solvers/time/runge_kutta_methods.jl")
include("parameters.jl")

# Preprocess
include("preprocess/check_input.jl")
include("preprocess/create_mesh.jl")

# Spatial
include("spatial/check_conservation.jl")
include("spatial/check_symmetry.jl")
include("spatial/convection.jl")
include("spatial/create_initial_conditions.jl")
include("spatial/diffusion.jl")
include("spatial/momentum.jl")
include("spatial/strain_tensor.jl")
include("spatial/turbulent_viscosity.jl")

include("spatial/boundary_conditions/bc_diff_stag.jl")
include("spatial/boundary_conditions/bc_diff_stag3.jl")
include("spatial/boundary_conditions/bc_general.jl")
include("spatial/boundary_conditions/bc_general_stag.jl")
include("spatial/boundary_conditions/create_boundary_conditions.jl")
include("spatial/boundary_conditions/set_bc_vectors.jl")

include("spatial/grid/nonuniform_grid.jl")

include("spatial/operators/build_operators.jl")
include("spatial/operators/interpolate_nu.jl")
include("spatial/operators/operator_averaging.jl")
include("spatial/operators/operator_convection_diffusion.jl")
include("spatial/operators/operator_divergence.jl")
include("spatial/operators/operator_interpolation.jl")
include("spatial/operators/operator_mesh.jl")
include("spatial/operators/operator_postprocessing.jl")
include("spatial/operators/operator_regularization.jl")
include("spatial/operators/operator_turbulent_diffusion.jl")

# Bodyforce
include("bodyforce/force.jl")

# Solvers
include("solvers/get_timestep.jl")
include("solvers/solve_steady.jl")
include("solvers/solve_steady_ke.jl")
include("solvers/solve_steady_ibm.jl")
include("solvers/solve_unsteady.jl")
include("solvers/solve_unsteady_ke.jl")
include("solvers/solve_unsteady_rom.jl")

include("solvers/pressure/pressure_poisson.jl")
include("solvers/pressure/pressure_additional_solve.jl")

include("solvers/time/step_AB_CN.jl")
include("solvers/time/step_ERK.jl")
include("solvers/time/step_ERK_ROM.jl")
include("solvers/time/step_IRK.jl")
include("solvers/time/step_IRK_ROM.jl")

# Utils
include("utils/filter_convection.jl")

# Postprocess
include("postprocess/postprocess.jl")
include("postprocess/get_vorticity.jl")
include("postprocess/get_streamfunction.jl")

# Main driver
include("main.jl")

# Reexport
export @unpack

# Setup
export Case,
    Fluid,
    Visc,
    Grid,
    Discretization,
    Force,
    ROM,
    IBM,
    Time,
    SolverSettings,
    Visualization,
    BC,
    Setup

# Spatial
export nonuniform_grid

# Main driver
export main
export create_mesh!,
    create_boundary_conditions!,
    build_operators!,
    create_initial_conditions,
    set_bc_vectors!,
    force,
    check_input!,
    solve_steady_ke!,
    solve_steady!,
    solve_steady_ibm!,
    solve_unsteady_ke!,
    solve_unsteady_rom!,
    solve_unsteady!,
    postprocess

# Runge Kutta methods

# Explicit Methods
export FE11, SSP22, SSP42, SSP33, SSP43, SSP104, rSSPs2, rSSPs3, Wray3, RK56, DOPRI6

# Implicit Methods
export BE11, SDIRK34, ISSPm2, ISSPs3

# Half explicit methods
export HEM3, HEM3BS, HEM5

# Classical Methods
export GL1, GL2, GL3, RIA1, RIA2, RIA3, RIIA1, RIIA2, RIIA3, LIIIA2, LIIIA3

# Chebyshev methods
export CHDIRK3, CHCONS3, CHC3, CHC5

# Miscellaneous Methods
export Mid22, MTE22, CN22, Heun33, RK33C2, RK33P2, RK44, RK44C2, RK44C23, RK44P2

# DSRK Methods
export DSso2, DSRK2, DSRK3

# "Non-SSP" Methods of Wong & Spiteri
export NSSP21, NSSP32, NSSP33, NSSP53

end
