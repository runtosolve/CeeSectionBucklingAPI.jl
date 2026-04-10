

using JSON, CeeSectionBuckling, ShowCUFSM, ShowRackSections, CairoMakie


inputs_path = joinpath(@__DIR__, "inputs.json")


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




    model = all_results[1].results.model
    
    eig = 1

    t_elements = all_results[1].results.model.elem[:, 4]
    
    deformation_scale = [1.0, 1.0] .* 0.025

    element_discretization = 5

#     t = t_elements[1]

#         Δ = ShowRackSections.get_deformed_shape_extents(model, eig, deformation_scale) .+ t

#     api_figure_options = (max_pixel_size = 2048/4, cross_section_linecolor =:grey, signature_curve_linecolor=:blue)



#     drawing_size, thickness_scale = ShowRackSections.define_drawing_size(Δ, api_figure_options.max_pixel_size)

#     backgroundcolor = :transparent
#     linecolor = Symbol(api_figure_options.cross_section_linecolor)
#     linestyle = :solid 
#     joinstyle = :miter
    
#     options = ShowCUFSM.ModeShapeOptions(drawing_size, thickness_scale, backgroundcolor, linecolor, linestyle, joinstyle)






# ax, figure = ShowCUFSM.minimum_mode_shape(model, eig, t_elements, deformation_scale, options)
# figure 


X, Y = get_mode_shape_coordinates(model, eig, t_elements, element_discretization, deformation_scale)


scatterlines(X, Y)


function get_mode_shape_coordinates(model, eig, t_elements, element_discretization, deformation_scale)

    Pcr = ShowCUFSM.get_load_factor(model, eig)
    mode_index = argmin(Pcr)
    mode = model.shapes[mode_index][:, eig]

    n = fill(element_discretization, length(t_elements))

    cross_section_coords, Δ, figure_max_dims = ShowCUFSM.cross_section_mode_shape_info(model.elem, model.node, mode, n, deformation_scale)

    XY_discretized =Float64[]
    t_discretized = Float64[]
    Δ_discretized = Float64[]

    for i in eachindex(cross_section_coords)

        if i != size(cross_section_coords)[1]
            XY_segment = [cross_section_coords[i][j] for j in eachindex(cross_section_coords[i])][1:end-1]
        else
            XY_segment = [cross_section_coords[i][j] for j in eachindex(cross_section_coords[i])] #last segment, add end node 
        end

        XY_discretized = vcat(XY_discretized, XY_segment)

        t_discretized = vcat(t_discretized, fill(t_elements[i], n[i]-1))

        if i != size(cross_section_coords)[1]
            Δ_segment = [Δ[i][j] for j in eachindex(Δ[i])][1:end-1]
        else
            Δ_segment = [Δ[i][j] for j in eachindex(Δ[i])]  #last segment, add end node 
        end

        Δ_discretized = vcat(Δ_discretized, Δ_segment)

    end

    X_discretized = [XY_discretized[i][1] for i in eachindex(XY_discretized)]
    Y_discretized = [XY_discretized[i][2] for i in eachindex(XY_discretized)]

    ΔX_discretized = [Δ_discretized[i][1] for i in eachindex(Δ_discretized)]
    ΔY_discretized = [Δ_discretized[i][2] for i in eachindex(Δ_discretized)]


    X = (X_discretized .+ ΔX_discretized) .* deformation_scale[1]
    Y = (Y_discretized + ΔY_discretized) .* deformation_scale[2]

    return X, Y 

end

