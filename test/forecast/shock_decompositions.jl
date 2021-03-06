path = dirname(@__FILE__)

# Set up arguments
m = AnSchorfheide(testing = true)
m <= Setting(:date_forecast_start, quartertodate("2015-Q4"))
m <= Setting(:forecast_horizons, 1)

system, histshocks = JLD2.jldopen("$path/../reference/forecast_args.jld2","r") do file
    read(file, "system"), read(file, "histshocks")
end

# Read expected output
exp_states, exp_obs, exp_pseudo =
    JLD2.jldopen("$path/../reference/shock_decompositions_out.jld2", "r") do file
        read(file, "exp_states"), read(file, "exp_obs"), read(file, "exp_pseudo")
    end

# With shockdec_startdate not null
states, obs, pseudo = shock_decompositions(m, system, histshocks)

@testset "Test shockdec with non-null startdate" begin
    @test @test_matrix_approx_eq exp_states[:startdate] states
    @test @test_matrix_approx_eq exp_obs[:startdate]    obs
    @test @test_matrix_approx_eq exp_pseudo[:startdate] pseudo
end

# With shockdec_startdate null
#m <= Setting(:shockdec_startdate, Nullable{Date}())
m <= Setting(:shockdec_startdate, nothing)
states, obs, pseudo = shock_decompositions(m, system, histshocks)

@testset "Test shockdec with null startdate" begin
    @test @test_matrix_approx_eq exp_states[:no_startdate] states
    @test @test_matrix_approx_eq exp_obs[:no_startdate]    obs
    @test @test_matrix_approx_eq exp_pseudo[:no_startdate] pseudo
end

nothing
