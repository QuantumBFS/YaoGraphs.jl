using YaoGraphRegister
using Test

@testset "YaoGraphRegister.jl" begin
    # Write your own tests here.
end

using LightGraphs, GraphPlot, Compose

g = SimpleGraph(10, 10)
gplot(g)
