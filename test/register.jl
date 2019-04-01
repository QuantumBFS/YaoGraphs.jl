using Revise, YaoGraphRegister, LightGraphs, GraphPlot, Compose

using Colors

g = SimpleGraph(10, 10)

nodecolor = [colorant"lightseagreen", colorant"orange"]
membership = [i == 3 ? 2 : 1 for i in 1:10]
nodefillc = nodecolor[membership]

gplot(g; nodelabel=1:10, nodefillc=nodefillc, layout=circular_layout)
