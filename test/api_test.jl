using CeeSectionBucklingAPI 

# struct Inputs


#     E
#     ν

#     t 

#     L   #lip
#     B   #flange
#     H   #web
#     r   #inside radius 

# end


# struct Outputs 

#     Pcrℓ
#     Pcrd 

# end

# E = 29500.0
# ν = 0.30 

# t = 0.060
# L = 3/8
# B = 1.0
# H = 2.0
# r = 2 * t

# inputs = Inputs(E, ν, t, L, B, H, r)


# JSON.json(joinpath(@__DIR__, "inputs.json"), inputs)



inputs_path = joinpath(@__DIR__, "inputs.json")

serial_path = joinpath(@__DIR__, "outputs.json")


CeeSectionBucklingAPI.perform_calculation(inputs_path, serial_path)


# inputs = open(inputs_path) do f; JSON.parse(f); end

# E = inputs.E 
# ν = inputs.ν
# t = inputs.t 
# L = inputs.L 
# B = inputs.B 
# H = inputs.H 
# r = inputs.r 


# material = CeeSectionBuckling.Material(E, ν)
# dimensions = CeeSectionBuckling.Dimensions(t, L, B, H, r)

# all_results = []



# push!(all_results, CeeSectionBuckling.calculate_Pcrℓ(dimensions, material))
# push!(all_results, CeeSectionBuckling.calculate_Pcrd(dimensions, material))


# outputs = Outputs(all_results[1].results.Rcr, all_results[2].results.Rcr)

# open(serial_path, "w") do f
#     JSON.json(f, outputs)
#     println(f)
# end




