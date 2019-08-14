# 1D Burgers Equation
# u_t+(0.5*u²)_{x}=0

using ConservationLawsDiffEq
using OrdinaryDiffEq
using LinearAlgebra

const CFL = 0.5
const Tend = 1.0

Jf(u) = u
f(u) = u^2/2
f0(x) = sin(2*π*x)

function get_problem(N)
  mesh = line_mesh(N, 0.0, 1.0)
  ConservationLawsProblem(f,f0,mesh,[Periodic()]; tspan = (0.0,Tend), Df = Jf)
end
#Run
@time prob = get_problem(200)
@time sol = solve(prob, FVSKTAlgorithm();TimeIntegrator = SSPRK22(), CFL = CFL,progress=false, use_threads = false, save_everystep = false)
@time sol1 = fast_solve(prob, FVSKTAlgorithm();TimeIntegrator = SSPRK22(), CFL = CFL,progress=true)
@time sol2 = solve(prob, LaxFriedrichsAlgorithm();TimeIntegrator = SSPRK22(), CFL = CFL, progress=true, save_everystep = false)
@time sol3 = solve(prob, LocalLaxFriedrichsAlgorithm();TimeIntegrator = SSPRK22(), CFL = CFL,progress=true, save_everystep = false)
@time sol4 = solve(prob, GlobalLaxFriedrichsAlgorithm();TimeIntegrator = SSPRK22(), CFL = CFL,progress=true, save_everystep = false)
#@time sol5 = solve(prob, LaxWendroff2sAlgorithm();progress=true, save_everystep = false)
@time sol5 = solve(prob, FVCompWENOAlgorithm();CFL = CFL,progress=true, TimeAlgorithm = SSPRK33())
@time sol6 = solve(prob, FVCompMWENOAlgorithm();progress=true, TimeAlgorithm = SSPRK33(),CFL = CFL)
@time sol7 = solve(prob, FVSpecMWENOAlgorithm();TimeIntegrator = SSPRK22(), CFL = CFL,progress=true, save_everystep = false)

basis=legendre_basis(3)
limiter! = DGLimiter(prob, basis, Linear_MUSCL_Limiter())
@time sol8 = solve(prob, DiscontinuousGalerkinScheme(basis, glf_num_flux); TimeIntegrator = SSPRK22(limiter!))

#Plot
using Plots
plot(sol,tidx = 1,lab="uo",line=(:dot,2))
plot!(sol,lab="KT u")
plot!(sol2,lab="L-F h")
plot!(sol3,lab="LLF h")
plot!(sol4,lab="GLF h")
plot!(sol5,lab="Comp WENO5 h")
plot!(sol6,lab="Comp MWENO5 h")
plot!(sol7,lab="Spec MWENO5 h")
plot!(sol8, label="DG k=3")
