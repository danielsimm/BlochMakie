using GLMakie
using LinearAlgebra
using ColorSchemes

include("utils/bloch_utils.jl")
include("utils/vis_utils.jl")

function bloch_preview(ϕ, θ, size=1000; cs=default_colorscheme, vec_color=default_vectorcolor)
    fig = Figure(resolution = (size, size))
    ax = Axis3(fig[1, 1], aspect=(1,1,1), azimuth=0.2, elevation=pi/8, perspectiveness=0.0)
    hidedecorations!(ax)
    hidespines!(ax)

    surface!(ax, sphere()..., transparency=true, shading=false, ssao=false, diffuse=Vec3f(1.0), specular=Vec3f(0.0), colormap=cs)
    lines!(ax, equator()..., color=:grey, linewidth=1)

    lw1 = Int(round(12*size/1000))
    lw2 = Int(round(8*size/1000))
    fs1 = Int(round(70*size/1000))
    fs2 = Int(round(40*size/1000))
    # define observables
    phi_proj_obs = Observable(Point3f.(phi_projection(ϕ, θ)...))
    theta_proj_obs = Observable(Point3f.(theta_projection(ϕ, θ)...))
    pos_obs = Observable([Point3f(angle_to_cartesian(ϕ, θ)...)])
    z_proj = Observable([Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)])
    phi_text_obs = Observable(Point3f(phi_text_pos(ϕ, θ)...))
    theta_text_obs = Observable(Point3f(angle_to_cartesian(ϕ, θ/2)))

    arrows!(ax, [Point3f(0)], pos_obs, color=vec_color, arrowhead=:Sphere, normalize=true, arrowsize=0.05, shading=false, specular=Vec3f(0.0))

    lines!(ax, phi_proj_obs, color=vec_color, linewidth=lw1)
    text!(ax, phi_text_obs; text=L"ϕ", color=vec_color, fontsize=fs1)
    lines!(ax, theta_proj_obs, color=vec_color, linewidth=lw1)
    text!(ax, theta_text_obs; text=L"θ", color=vec_color, fontsize=fs1)
    #limits!(ax, (-0.9, 0.9), (-0.9, 0.9), (-0.9, 0.9))
    lines!(ax, z_proj, color=vec_color, linewidth=lw2, linestyle=:dot)

    lines!(ax, [Point3f(0), Point3f(1.3, 0, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 1.3, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 0, 1.3)], color=:black)

    text!(ax, Point3f(0, 0, 1.35); text=L"Z", color=:black, fontsize=fs2)
    text!(ax, Point3f(1.35, 0, 0); text=L"X", color=:black, fontsize=fs2)
    text!(ax, Point3f(0, 1.35, 0); text=L"Y", color=:black, fontsize=fs2)
        
    display(fig)
end
    
function bloch_animation_png(ϕs, θs, name, size=1000; cs=default_colorscheme, vec_color=default_vectorcolor)
    if length(ϕs) != length(θs)
        error("ϕs and θs must have the same length")
    end
    ϕ = ϕs[1]
    θ = θs[1]

    mkdir(name)

    fig = Figure(resolution = (size, size))
    ax = Axis3(fig[1, 1], aspect=(1,1,1), azimuth=0.2, elevation=pi/8, perspectiveness=0.0)
    hidedecorations!(ax)
    hidespines!(ax)

    surface!(ax, sphere()..., transparency=true, shading=false, ssao=false, diffuse=Vec3f(1.0), specular=Vec3f(0.0), colormap=cs)
    lines!(ax, equator()..., color=:grey, linewidth=1)

    lw1 = Int(round(12*size/1000))
    lw2 = Int(round(8*size/1000))
    fs1 = Int(round(70*size/1000))
    fs2 = Int(round(40*size/1000))
    # define observables
    phi_proj_obs = Observable(Point3f.(phi_projection(ϕ, θ)...))
    theta_proj_obs = Observable(Point3f.(theta_projection(ϕ, θ)...))
    pos_obs = Observable([Point3f(angle_to_cartesian(ϕ, θ)...)])
    z_proj = Observable([Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)])
    phi_text_obs = Observable(Point3f(phi_text_pos(ϕ, θ)...))
    theta_text_obs = Observable(Point3f(angle_to_cartesian(ϕ, θ/2)))

    arrows!(ax, [Point3f(0)], pos_obs, color=vec_color, arrowhead=:Sphere, normalize=true, arrowsize=0.05, shading=false, specular=Vec3f(0.0))

    lines!(ax, phi_proj_obs, color=vec_color, linewidth=lw1)
    text!(ax, phi_text_obs; text=L"ϕ", color=vec_color, fontsize=fs1)
    lines!(ax, theta_proj_obs, color=vec_color, linewidth=lw1)
    text!(ax, theta_text_obs; text=L"θ", color=vec_color, fontsize=fs1)
    #limits!(ax, (-0.9, 0.9), (-0.9, 0.9), (-0.9, 0.9))
    lines!(ax, z_proj, color=vec_color, linewidth=lw2, linestyle=:dot)

    lines!(ax, [Point3f(0), Point3f(1.3, 0, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 1.3, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 0, 1.3)], color=:black)

    text!(ax, Point3f(0, 0, 1.35); text=L"Z", color=:black, fontsize=fs2)
    text!(ax, Point3f(1.35, 0, 0); text=L"X", color=:black, fontsize=fs2)
    text!(ax, Point3f(0, 1.35, 0); text=L"Y", color=:black, fontsize=fs2)

    
    # define observables
    phi_proj_obs = Observable(Point3f.(phi_projection(ϕ, θ)...))
    theta_proj_obs = Observable(Point3f.(theta_projection(ϕ, θ)...))
    pos_obs = Observable([Point3f(angle_to_cartesian(ϕ, θ)...)])
    z_proj = Observable([Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)])
    phi_text_obs = Observable(Point3f(phi_text_pos(ϕ, θ)...))
    theta_text_obs = Observable(Point3f(angle_to_cartesian(ϕ, θ/2)))

    for t in eachindex(ϕs)
        ϕ = ϕs[t]
        θ = θs[t]
        phi_proj_obs[] = Point3f.(phi_projection(ϕ, θ)...)
        theta_proj_obs[] = Point3f.(theta_projection(ϕ, θ)...)
        pos_obs[] = [Point3f(angle_to_cartesian(ϕ, θ)...)]
        z_proj[] = [Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)]
        phi_text_obs[] = Point3f(phi_text_pos(ϕ, θ)...)
        theta_text_obs[] = Point3f(angle_to_cartesian(ϕ, θ/2))
        save("$(name)/frame_$(t).png", alpha_colorbuffer(fig))
    end

end

function bloch_animation_preview(ϕs, θs, size=1000; cs=default_colorscheme, vec_color=default_vectorcolor)
    if length(ϕs) != length(θs)
        error("ϕs and θs must have the same length")
    end
    ϕ = ϕs[1]
    θ = θs[1]

    fig = Figure(resolution = (size, size))
    ax = Axis3(fig[1, 1], aspect=(1,1,1), azimuth=0.2, elevation=pi/8, perspectiveness=0.0)
    hidedecorations!(ax)
    hidespines!(ax)

    surface!(ax, sphere()..., transparency=true, shading=false, ssao=false, diffuse=Vec3f(1.0), specular=Vec3f(0.0), colormap=cs)
    lines!(ax, equator()..., color=:grey, linewidth=1)

    lw1 = Int(round(12*size/1000))
    lw2 = Int(round(8*size/1000))
    fs1 = Int(round(70*size/1000))
    fs2 = Int(round(40*size/1000))
    # define observables
    phi_proj_obs = Observable(Point3f.(phi_projection(ϕ, θ)...))
    theta_proj_obs = Observable(Point3f.(theta_projection(ϕ, θ)...))
    pos_obs = Observable([Point3f(angle_to_cartesian(ϕ, θ)...)])
    z_proj = Observable([Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)])
    phi_text_obs = Observable(Point3f(phi_text_pos(ϕ, θ)...))
    theta_text_obs = Observable(Point3f(angle_to_cartesian(ϕ, θ/2)))

    arrows!(ax, [Point3f(0)], pos_obs, color=vec_color, arrowhead=:Sphere, normalize=true, arrowsize=0.05, shading=false, specular=Vec3f(0.0))

    lines!(ax, phi_proj_obs, color=vec_color, linewidth=lw1)
    text!(ax, phi_text_obs; text=L"ϕ", color=vec_color, fontsize=fs1)
    lines!(ax, theta_proj_obs, color=vec_color, linewidth=lw1)
    text!(ax, theta_text_obs; text=L"θ", color=vec_color, fontsize=fs1)
    #limits!(ax, (-0.9, 0.9), (-0.9, 0.9), (-0.9, 0.9))
    lines!(ax, z_proj, color=vec_color, linewidth=lw2, linestyle=:dot)

    lines!(ax, [Point3f(0), Point3f(1.3, 0, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 1.3, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 0, 1.3)], color=:black)

    text!(ax, Point3f(0, 0, 1.35); text=L"Z", color=:black, fontsize=fs2)
    text!(ax, Point3f(1.35, 0, 0); text=L"X", color=:black, fontsize=fs2)
    text!(ax, Point3f(0, 1.35, 0); text=L"Y", color=:black, fontsize=fs2)

    
    # define observables
    phi_proj_obs = Observable(Point3f.(phi_projection(ϕ, θ)...))
    theta_proj_obs = Observable(Point3f.(theta_projection(ϕ, θ)...))
    pos_obs = Observable([Point3f(angle_to_cartesian(ϕ, θ)...)])
    z_proj = Observable([Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)])
    phi_text_obs = Observable(Point3f(phi_text_pos(ϕ, θ)...))
    theta_text_obs = Observable(Point3f(angle_to_cartesian(ϕ, θ/2)))

    display(fig)
    sleep(1)

    for t in eachindex(ϕs)
        ϕ = ϕs[t]
        θ = θs[t]
        phi_proj_obs[] = Point3f.(phi_projection(ϕ, θ)...)
        theta_proj_obs[] = Point3f.(theta_projection(ϕ, θ)...)
        pos_obs[] = [Point3f(angle_to_cartesian(ϕ, θ)...)]
        z_proj[] = [Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)]
        phi_text_obs[] = Point3f(phi_text_pos(ϕ, θ)...)
        theta_text_obs[] = Point3f(angle_to_cartesian(ϕ, θ/2))
        sleep(1/60)
    end

end

bloch_animation_preview(collect(0:0.1:2pi), collect(0:0.1:2pi), 1000)