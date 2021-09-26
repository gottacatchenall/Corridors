include("00_generate_landcover.jl")

using Colors
using Omniscape

frac = discretize(rand(DiamondSquare(0.9999999), 1000, 1000), 6)
heatmap(frac, c=cmap)



"""
hvals = vcat(0.001, collect(0.01:0.01:0.99))

cmap = [colorant"#2e3440", colorant"#4c566a", colorant"#5e81ac",  colorant"#81a1c1", colorant"#8fbcbb",  colorant"#d08770"]

maps = []

for h in hvals
    push!(maps, heatmap(discretize(rand(DiamondSquare(h), 1000,1000), 6), xticks=:none, yticks=:none, colorbar=:none,c=cmap, size=(100,100)))
end

plot(maps..., layout=grid(10,10), size=(1500,1500))


savefig("ok2.png")
"""