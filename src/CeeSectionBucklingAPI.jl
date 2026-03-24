module CeeSectionBucklingAPI

using JSON, CeeSectionBuckling

struct Inputs

    E
    ν

    t 

    L   #lip
    B   #flange
    H   #web
    r   #inside radius 

end


struct Outputs 

    Pcrℓ
    Pcrd 

end


function perform_calculation(inputs_path, serial_path)

    inputs = open(inputs_path) do f; JSON.parse(f); end

    E = inputs.E 
    ν = inputs.ν
    t = inputs.t 
    L = inputs.L 
    B = inputs.B 
    H = inputs.H 
    r = inputs.r 


    material = CeeSectionBuckling.Material(E, ν)
    dimensions = CeeSectionBuckling.Dimensions(t, L, B, H, r)

    all_results = []

    push!(all_results, CeeSectionBuckling.calculate_Pcrℓ(dimensions, material))
    push!(all_results, CeeSectionBuckling.calculate_Pcrd(dimensions, material))


    outputs = Outputs(all_results[1].results.Rcr, all_results[2].results.Rcr)

    open(serial_path, "w") do f
        JSON.json(f, outputs)
        println(f)
    end

end




end # module CeeSectionBucklingAPI
