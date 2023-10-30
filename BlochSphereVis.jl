using GLMakie
using LinearAlgebra
using ColorSchemes

const default_colorscheme = ColorScheme([RGBAf(139/255, 219/255, 225/255, 255/255), RGBAf(1.0, 1.0, 1.0, 0.0), RGBAf(254/255, 216/255, 219/255, 1.0)])
const default_vectorcolor = RGBAf(227/255, 159/255, 27/255, 1)

function angle_to_cartesian(ϕ, θ)
    x = cos(ϕ) * sin(θ)
    y = sin(ϕ) * sin(θ)
    z = cos(θ)
    return x, y, z
end

function sphere()
    r = 1.0
    theta = LinRange(0, pi, 100)
    phi = LinRange(0, 2pi, 100)
    
    x = [r * cos(φv) * sin(θv) for θv in theta, φv in phi]
    y = [r * sin(φv) * sin(θv) for θv in theta, φv in phi]
    z = [r * cos(θv) for θv in theta, φv in 2phi]

    return x, y, z
end

function equator()
    θ = LinRange(0, 2π, 100)
    return cos.(θ), sin.(θ), zeros(100)
end

function phi_projection(ϕ, θ)
    dots = round(Int, ϕ*20)
    if dots ≤ 1
        dots = 2
    end
    dotsx = [angle_to_cartesian.(LinRange(0.0, ϕ, dots), θ)[i][1] for i in 1:dots]
    dotsy = [angle_to_cartesian.(LinRange(0.0, ϕ, dots), θ)[i][2] for i in 1:dots]
    return dotsx, dotsy, zeros(length(dots))
end

function phi_text_pos(ϕ, θ)
    x, y, z = angle_to_cartesian(ϕ/2, θ)
    z = 0
    x *= 1.2
    y *= 1.2
    return x,y,z
end


function theta_projection(ϕ, θ)
    dots = round(Int, θ*20)
    if dots ≤ 1
        dots = 2
    end
    
    # dotted curved line to axis
    dotsx = [angle_to_cartesian.(ϕ, LinRange(0.0, θ, dots))[i][1] for i in 1:dots] 
    dotsy = [angle_to_cartesian.(ϕ, LinRange(0.0, θ, dots))[i][2] for i in 1:dots]
    dotsz = [angle_to_cartesian.(ϕ, LinRange(0.0, θ, dots))[i][3] for i in 1:dots]
    
    return dotsx, dotsy, dotsz
end

function calculate_rgba(rgb1, rgb2, rgba_bg)::RGBAf
    rgb1 == rgb2 && return RGBAf(rgb1.r, rgb1.g, rgb1.b, 1)
    c1 = Float64.((rgb1.r, rgb1.g, rgb1.b))
    c2 = Float64.((rgb2.r, rgb2.g, rgb2.b))
    alphas_fg = 1 .+ c1 .- c2
    alpha_fg = clamp(sum(alphas_fg) / 3, 0, 1)
    alpha_fg == 0 && return rgba_bg
    rgb_fg = clamp.((c1 ./ alpha_fg), 0, 1)
    rgb_bg = Float64.((rgba_bg.r, rgba_bg.g, rgba_bg.b))
    alpha_final = alpha_fg + (1 - alpha_fg) * rgba_bg.alpha
    rgb_final = @. 1 / alpha_final * (alpha_fg * rgb_fg + (1 - alpha_fg) * rgba_bg.alpha * rgb_bg)
    return RGBAf(rgb_final..., alpha_final)
end

function alpha_colorbuffer(figure)
    scene = figure.scene
    bg = scene.backgroundcolor[]
    scene.backgroundcolor[] = RGBAf(0, 0, 0, 1)
    b1 = copy(colorbuffer(scene))
    scene.backgroundcolor[] = RGBAf(1, 1, 1, 1)
    b2 = colorbuffer(scene)
    scene.backgroundcolor[] = bg
    return map(b1, b2) do b1, b2
        calculate_rgba(b1, b2, bg)
    end
end

function smooth_transition(x1, x2, frames)
    factors = 0.5 .* (tanh.(LinRange(-pi, pi, frames)) .+1)
    return x2 .* factors .+ x1 .* (1 .- factors)
end

function bloch_plot(ϕ, θ, size=1000; cs=default_colorscheme, vec_color=default_vectorcolor)
    fig = Figure(resolution = (size, size), backgroundcolor=(:white, 0.0))
    ax = Axis3(fig[1, 1], aspect=(1,1,1), azimuth=0.2, elevation=pi/8, perspectiveness=0.0)
    hidedecorations!(ax)
    hidespines!(ax)

    surface!(ax, sphere()..., transparency=true, shading=false, ssao=false, diffuse=Vec3f(1.0), specular=Vec3f(0.0), colormap=cs)
    lines!(ax, equator()..., color=:grey, linewidth=1)

    # define observables
    phi_proj_obs = Observable(Point3f.(phi_projection(ϕ, θ)...))
    theta_proj_obs = Observable(Point3f.(theta_projection(ϕ, θ)...))
    pos_obs = Observable([Point3f(angle_to_cartesian(ϕ, θ)...)])
    z_proj = Observable([Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)])
    phi_text_obs = Observable(Point3f(phi_text_pos(ϕ, θ)...))
    theta_text_obs = Observable(Point3f(angle_to_cartesian(ϕ, θ/2)))

    arrows!(ax, [Point3f(0)], pos_obs, color=vec_color, arrowhead=:Sphere, normalize=true, arrowsize=0.05, shading=false, specular=Vec3f(0.0))

    lines!(ax, phi_proj_obs, color=vec_color, linewidth=12)
    text!(ax, phi_text_obs; text=L"ϕ", color=vec_color, fontsize=100)
    lines!(ax, theta_proj_obs, color=vec_color, linewidth=12)
    text!(ax, theta_text_obs; text=L"θ", color=vec_color, fontsize=100)
    limits!(ax, (-0.9, 0.9), (-0.9, 0.9), (-0.9, 0.9))
    lines!(ax, z_proj, color=vec_color, linewidth=8, linestyle=:dot)

    lines!(ax, [Point3f(0), Point3f(1.6, 0, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 1.6, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 0, 1.6)], color=:black)
    
    #display(fig)
    phis = Float32.(smooth_transition(0.0, 2*pi, 500))
    thetas = Float32.(smooth_transition(pi/2 ,-pi/2, 500))
    for t in 1:500
        ϕ = phis[t]
        θ = thetas[t]
        phi_proj_obs[] = Point3f.(phi_projection(ϕ, θ)...)
        theta_proj_obs[] = Point3f.(theta_projection(ϕ, θ)...)
        pos_obs[] = [Point3f(angle_to_cartesian(ϕ, θ)...)]
        z_proj[] = [Point3f.(angle_to_cartesian(ϕ, θ)...), Point3f.(angle_to_cartesian(ϕ, θ)[1], angle_to_cartesian(ϕ, θ)[2], 0.0)]
        phi_text_obs[] = Point3f(phi_text_pos(ϕ, θ)...)
        theta_text_obs[] = Point3f(angle_to_cartesian(ϕ, θ/2))
        sleep(0.01)
        save("frame_$(t).png", alpha_colorbuffer(fig))
    end

end

phis = smooth_transition(0.0f0, 0.5f0, 200)
# function bloch_plot_transparent(ϕ, θ, size=1000; cs=default_colorscheme, vec_color=default_vectorcolor)
#     fig = Figure(resolution = (size, size), backgroundcolor = (:white, 0.0))
#     ax = Axis3(fig[1, 1], aspect=(1,1,1), azimuth=0.2, elevation=pi/8, perspectiveness=1.0)
#     hidedecorations!(ax)
#     hidespines!(ax)

#     surface!(ax, sphere()..., transparency=true, shading=false, ssao=false, diffuse=Vec3f(1.0), specular=Vec3f(0.0), colormap=cs)
#     lines!(ax, equator()..., color=:grey, linewidth=1)

#     x, y, z = angle_to_cartesian(ϕ, θ)
#     arrows!(ax, [0], [0], [0], [x], [y], [z], color=vec_color, arrowhead=:Sphere, normalize=true, arrowsize=0.05, shading=false, specular=Vec3f(0.0))

#     lines!(ax, phi_projection(ϕ, θ)..., color=vec_color, linewidth=12)
#     text!(ax, Point3f(angle_to_cartesian(ϕ/2, π/2)); text=L"ϕ", color=vec_color, fontsize=100)
#     lines!(ax, theta_projection(ϕ, θ)..., color=vec_color, linewidth=12)
#     text!(ax, Point3f(angle_to_cartesian(ϕ, θ/2)); text=L"θ", color=vec_color, fontsize=100)
#     limits!(ax, (-0.9, 0.9), (-0.9, 0.9), (-0.9, 0.9))
#     lines!(ax, [x, x], [y, y], [0, z], color=vec_color, linewidth=8, linestyle=:dot)

#     lines!(ax, [Point3f(0), Point3f(1.6, 0, 0)], color=:black)
#     lines!(ax, [Point3f(0), Point3f(0, 1.6, 0)], color=:black)
#     lines!(ax, [Point3f(0), Point3f(0, 0, 1.6)], color=:black)
    
#     return alpha_colorbuffer(fig)
# end


bloch_plot(0.0, 0.0)