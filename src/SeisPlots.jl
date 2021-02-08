module SeisPlots

using SeisIO, RecipesBase, Dates
import DSP

include("spectrogram.jl")

@recipe function f(C::SeisChannel; max_npts=400000)
    label --> C.id
    seriescolor --> :black
    legendfontsize --> 8 
    ytickfontsize --> 8 
    xtickfontsize --> 6
    t = u2d.(SeisIO.t_expand(C.t,C.fs) * SeisIO.μs)
    t, C.x
end

@recipe function f(S::SeisData; max_npts=400000, max_traces=10)
    layout := (min(S.n,max_traces),1)
    seriescolor --> :black

    # get minumum and maximum times 
    starttimes = u2d.(SeisIO.μs .* [SeisIO.starttime(S[i].t,S[i].fs) for i = 1:S.n])
    endtimes = u2d.(SeisIO.μs .* [SeisIO.endtime(S[i].t,S[i].fs) for i = 1:S.n])
    xlims --> (minimum(starttimes),maximum(endtimes))
    legendfontsize --> max(3,8-S.n)
    ytickfontsize --> max(3,8-S.n)
    xtickfontsize --> 6

    # plot each series 
    for i in 1:min(S.n,max_traces)
        @series begin
            subplot := i 
            label --> S[i].id
            t = u2d.(SeisIO.t_expand(S[i].t,S[i].fs) * SeisIO.μs)
            if i != min(S.n,max_traces) 
                xticks --> Int[]
            end
            t,S[i].x
        end
    end
end

end
