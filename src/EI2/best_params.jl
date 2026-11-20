using Statistics

# bestParams(studyfile) : reads the parameter study (res/alpha_study.csv) and returns (best alpha, best pool size)

function bestParams(studyfile)
    alpha = 0.5            #back up only if studyAlpha is empty or none existing 
    poolSize = 10
    if !isfile(studyfile)
        println("no parameter study file, default alpha = ", alpha, " and pool size = ", poolSize)
        return alpha, poolSize
    end

    study = [split(l, ",") for l in readlines(studyfile)[2:end] if !isempty(strip(l))]
    names = unique([d[1] for d in study])
    pools = sort(unique([parse(Int, d[2]) for d in study]))
    alphas = sort(unique([parse(Float64, d[3]) for d in study]))
    # keep only the instances where every (pool size, alpha) was run (the study may still be running)
    done = [nm for nm in names if length(unique([(d[2], d[3]) for d in study if d[1] == nm])) == length(pools) * length(alphas)]

    # best alpha : mean z of each alpha (over pool sizes and runs) / best mean of the instance, averaged over the instances
    alphaScore = Dict(a => 0.0 for a in alphas)
    for nm in done
        m = Dict(a => mean([parse(Int, d[5]) for d in study if d[1] == nm && parse(Float64, d[3]) == a]) for a in alphas)
        top = maximum(values(m))
        for a in alphas
            alphaScore[a] += m[a] / top / length(done)
        end
    end
    alpha = argmax(alphaScore)

    # best pool size : same with alpha fixed to the best alpha
    poolScore = Dict(p => 0.0 for p in pools)
    for nm in done
        m = Dict(p => mean([parse(Int, d[5]) for d in study if d[1] == nm && parse(Float64, d[3]) == alpha && parse(Int, d[2]) == p]) for p in pools)
        top = maximum(values(m))
        for p in pools
            poolScore[p] += m[p] / top / length(done)
        end
    end
    poolSize = argmax(poolScore)

    println("parameter study : ", length(done), " instance(s) complete : ", done)
    println("  score by alpha     : ", sort(collect(alphaScore)))
    println("  score by pool size : ", sort(collect(poolScore)))
    println("  best alpha = ", alpha, "   best pool size = ", poolSize)
    return alpha, poolSize
end
