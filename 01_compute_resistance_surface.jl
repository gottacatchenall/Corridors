include("00_generate_landcover.jl")

using Circuitscape
using Distributions 

function makeresistance(landcover, dist=Exponential(100))
    # assume some distribution
    minresistcover = max(landcover...)

    minresistval = 1

    resistvals = [i == minresistcover ? minresistval : rand(dist) for i in 1:length(unique(landcover))]
    resistsurf = map(i->resistvals[i], landcover)

    resistsurf
end

function modifyresistance(resistsurf, modification)

end


cov = makecover()
pts = makepoints(cov)
re = makeresistance(cov)
heatmap(re, colorscale=:log10)
                

spy(re .== 1)




function init_curcuitscape_problem(surf::Matrix{T}, pts) where {T <: Float64}

    cfg = Circuitscape.init_config()
    flags = Circuitscape.get_raster_flags(cfg)
    

    polymap = Matrix{T}(0,0,0)
    points_rc = convert.(Vector{T}, (pts[:,1], pts[:,2], 1:size(pts)[1]))
    source_map, ground_map = Matrix{T}(0,0,0), Matrix{T}(0,0,0)
    strengths = Matrix{T}(0, 0,0)
    included_pairs = Circuitscape.IncludeExcludePairs(T)

    rastermeta = Circuitscape.RasterMeta(size(surf)..., 0,0,0,-9999, [0.0],"")

    rd = Circuitscape.RasterData(surf, polymap, source_map, ground_map, points_rc, strengths,
                    included_pairs, rastermeta)

    Circuitscape.compute_graph_data_no_polygons(rd, flags, cfg)
end


init_curcuitscape_problem(re, pts)

