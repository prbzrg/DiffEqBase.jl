using ModelingToolkit, OrdinaryDiffEq, SteadyStateDiffEq, Test

@variables t x(t) y(t)
eqs = [0 ~ x - y
       0 ~ y - x]

@named sys = ODESystem(eqs, t)
sys = structural_simplify(sys)

prob = ODEProblem(sys, Pair[], (0, 10.0))
sol = solve(prob, Tsit5())

@test sol[x] == [0.0, 0.0]
@test sol[y] == [0.0, 0.0]

for kwargs in [
    Dict(:saveat => 0:0.1:1),
    Dict(:save_start => false),
    Dict(:save_end => false),
]
    sol = solve(prob, kwargs...)
    init_sol = solve!(init(prob, kwargs...))
    step_sol = step!(init(prob, kwargs...), prob.tspan[end]-prob.tspan[begin])
    @test sol.u == init_sol.u
    @test sol.t == init_sol.t
    @test sol.u == step_sol.u
    @test sol.t == step_sol.t
end

@variables t x y
eqs = [0 ~ x - y
       0 ~ y - x]

@named sys = NonlinearSystem(eqs, [x, y], [])
sys = structural_simplify(sys)
prob = NonlinearProblem(sys, [])

sol = solve(prob, DynamicSS(Tsit5()))

@test sol[x] == 0.0
@test sol[y] == 0.0
