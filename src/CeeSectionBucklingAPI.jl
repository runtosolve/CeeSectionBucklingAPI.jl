module CeeSectionBucklingAPI

using JSON, CeeSectionBuckling, CUFSMModalGeometry

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
    local_buckling_mode_shape 
    distortional_buckling_mode_shape

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

    #get mode shapes 

    model = all_results[1].results.model
    eig = 1
    element_discretization = 5
    deformation_scale = [0.5, 0.5]
    t_elements = model.elem[:, 4]
    X, Y = CUFSMModalGeometry.get_mode_shape_coordinates(model, eig, t_elements, element_discretization, deformation_scale)
    local_buckling_mode_shape = (X=X, Y=Y)

     model = all_results[2].results.model
    eig = 1
    element_discretization = 5
    deformation_scale = [0.5, 0.5]
    t_elements = model.elem[:, 4]
    X, Y = CUFSMModalGeometry.get_mode_shape_coordinates(model, eig, t_elements, element_discretization, deformation_scale)
    distortional_buckling_mode_shape = (X=X, Y=Y)


    outputs = Outputs(all_results[1].results.Rcr, all_results[2].results.Rcr, local_buckling_mode_shape, distortional_buckling_mode_shape)

    open(serial_path, "w") do f
        JSON.json(f, outputs)
        println(f)
    end

end




end # module CeeSectionBucklingAPI
