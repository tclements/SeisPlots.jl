@userplot Spectrogram

@recipe function f(h::Spectrogram;
    yscale=:identity, 
    n=nothing, 
    noverlap=0.9,
    seriescolor=:inferno,
    dbscale=false
)
    if  (typeof(h.args[1]) <: SeisData)
        @warn("Only plotting spectrogram of first SeisChannel in SeisData")
        C = h.args[1][1]
    elseif (typeof(h.args[1]) <: SeisChannel)
        C = h.args[1]
    else
        error("First argument must be SeisChannel or SeisData.")
    end

    if size(C.t,2) != 2 
        error("Cannot plot SeisChannel with gaps. Please use ungap! first.")
    end

    # set up the subplots
    
    # framestyle := [:none :axes]
    grid := false
    layout := (2,1)

    # get spectrogram 
    if isnothing(n)
        n = nextpow(2,C.fs ^ 2 / 50)
    else
        n = nextpow(2,n)
    end
    newoverlap = floor(Int, n * noverlap)
    spec = DSP.spectrogram(C.x,n,newoverlap,fs=C.fs)
    t = u2d.(SeisIO.t_expand(C.t,C.fs) * SeisIO.μs)

    if dbscale 
        power = 10 .* log10.(spec.power)
    else
        power = sqrt.(spec.power)
    end

    # top plot time series 
    @series begin
        subplot := 1
        label --> C.id
        legendfontsize --> 8 
        ytickfontsize --> 10 
        xtickfontsize --> 8
        seriescolor --> :black
        yscale := :identity 
        t,C.x
    end

    # main heatmap
    @series begin
        legend := false
        seriestype := :heatmap
        yscale --> yscale
        ytickfontsize --> 10 
        xtickfontsize --> 8
        subplot := 2
        xguide --> "Time [s]"
        yguide --> "Frequency [Hz]"
        xlims --> (t[1],t[end])
        seriescolor --> cmap
        t[1] .+ Millisecond.(spec.time .* 1000), spec.freq[2:end], power[2:end,:]
    end
end