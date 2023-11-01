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
    z = 0.1
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
