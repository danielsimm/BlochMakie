using GLMakie
using LinearAlgebra
using ColorSchemes

function angle_to_cartesian(ϕ, θ)
    x = cos(ϕ) * sin(θ)
    y = sin(ϕ) * sin(θ)
    z = cos(θ)
    return x, y, z
end
function equator!(ax::Axis3; color=:grey, linewidth=1)
    θ = LinRange(0, 2π, 100)
    lines!(ax, cos.(θ), sin.(θ), zeros(100), color=color, linewidth=linewidth)
    return ax
end

function smooth_transition(x1, x2, frames)
    factors = 0.5 .* (tanh.(LinRange(-pi, pi, frames)) .+1)
    return x2 .* factors .+ x1 .* (1 .- factors)
end

function geodetic!(ax::Axis3; color=:grey, linewidth=1)
    θ = LinRange(0, 2π, 100)
    lines!(ax, cos.(θ), sin.(θ), zeros(100), color=color, linewidth=linewidth)
    lines!(ax, zeros(100), cos.(θ), sin.(θ), color=color, linewidth=linewidth)
    lines!(ax, sin.(θ), zeros(100), cos.(θ), color=color, linewidth=linewidth)
    return ax
end

function phi_projection!(ax::Axis3, ϕ, θ)
    dots = round(Int, ϕ*20)
    dotsx = [angle_to_cartesian.(LinRange(0.0, ϕ, dots), θ)[i][1] for i in 1:dots]
    dotsy = [angle_to_cartesian.(LinRange(0.0, ϕ, dots), θ)[i][2] for i in 1:dots]
    lines!(ax, dotsx, dotsy, zeros(length(dots)), color=orange, linewidth=12)
    text!(ax, Point3f(angle_to_cartesian(ϕ/2, π/2)); text=L"ϕ", color=orange, fontsize=100)
    return ax
end

function theta_projection!(ax, ϕ, θ)
    dots = round(Int, θ*20)
    x, y, z = angle_to_cartesian(ϕ, θ)
    lines!(ax, [x, x], [y, y], [0, z], color=orange, linewidth=8, linestyle=:dot)
    # dotted curved line to axis
    dotsx = [angle_to_cartesian.(ϕ, LinRange(0.0, θ, dots))[i][1] for i in 1:dots] 
    dotsy = [angle_to_cartesian.(ϕ, LinRange(0.0, θ, dots))[i][2] for i in 1:dots]
    dotsz = [angle_to_cartesian.(ϕ, LinRange(0.0, θ, dots))[i][3] for i in 1:dots]
    lines!(ax, dotsx, dotsy, dotsz, color=orange, linewidth=12)
    text!(ax, Point3f(angle_to_cartesian(ϕ, θ/2)); text=L"θ", color=orange, fontsize=100)
    return ax
end

function sphere!(ax::Axis3)
    r = 1.0
    theta = LinRange(0, pi, 100)
    phi = LinRange(0, 2pi, 100)
    
    x = [r * cos(φv) * sin(θv) for θv in theta, φv in phi]
    y = [r * sin(φv) * sin(θv) for θv in theta, φv in phi]
    z = [r * cos(θv) for θv in theta, φv in 2phi]
    
    surface!(ax, x, y, z, transparency=true, shading=false, ssao=false, diffuse=Vec3f(1.0), specular=Vec3f(0.0), colormap=cs)
end

const cs = ColorScheme([RGBAf(139/255, 219/255, 225/255, 255/255), RGBAf(1.0, 1.0, 1.0, 0.0), RGBAf(254/255, 216/255, 219/255, 1.0)])
const orange = RGBAf(227/255, 159/255, 27/255, 1)

function bloch_plot(ϕ, θ)
    fig = Figure(resolution = (2000, 2000), backgroundcolor = (:white, 0.0))
    ax = Axis3(fig[1, 1], aspect=(1,1,1), azimuth=0.2, elevation=pi/8, perspectiveness=1.0)
    hidedecorations!(ax)
    hidespines!(ax)
    equator!(ax)
    geodetic!(ax)
    sphere!(ax)
    phi_projection!(ax, ϕ, θ)
    theta_projection!(ax, ϕ, θ)
    limits!(ax, (-0.9, 0.9), (-0.9, 0.9), (-0.9, 0.9))

    #mesh!(ax, Sphere(Point3f(0), 1.0f0), transparency=true, alpha=0.05, colormap=:viridis)
    lines!(ax, [Point3f(0), Point3f(1.6, 0, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 1.6, 0)], color=:black)
    lines!(ax, [Point3f(0), Point3f(0, 0, 1.6)], color=:black)
    x, y, z = angle_to_cartesian(ϕ, θ)
    arrows!(ax, [0], [0], [0], [x], [y], [z], color=orange, arrowhead=:Sphere, normalize=true, arrowsize=0.05, shading=false, specular=Vec3f(0.0))
    return fig
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

save("test.png", alpha_colorbuffer(bloch_plot(0.5, 0.8)))