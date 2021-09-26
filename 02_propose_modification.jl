include("00_generate_landcover.jl")

landcover = cover()
pts = points(landcover) 
plotlandscape(landcover, pts)



abstract type ProposalGenerator end

struct ConnectNodes <: ProposalGenerator
    budget
end

function propose(gen::ConnectNodes, pts)

    # create a matrix of nodes that could be connected given the budget

    # there should be two layers here. 
    # 1) change the topolgoy of the graph probabilistically proportional to temp
    # 2) change the breakdown of the manhattan distance for a given topology 
end