using StatsBase
using Distributions

export runga

# random initial population
# choose expression for reproduction, prob. proportional to fitness
# produce either copy, mutation, or crossover with other randomly chosen expression
# remove another randomly chosen expression

function runga(fitness::Function,
               create_entity::Function;
               population_size::Int = 10,
               crossover_rate::Float64 = 0.8,
               mutation_rate::Float64 = 0.1,
               crossover::Function = rand,
               mutate::Function = identity,
               generations::Int = 64,
               debug::Function = (;args...) -> return
               )
    
    population = map(create_entity, 1:population_size)
    fitnesses = map(fitness, population)

    for g = 1:generations
        survivors = sample(population, weights(1 ./ fitnesses), population_size)
        children = apply_crossover(survivors, crossover, crossover_rate)
        population = apply_mutations(children, mutate, mutation_rate)
        fitnesses .= fitness.(population)

        debug(generation = g,
              population = population,
              fitness = fitnesses)
    end

    population, fitnesses
end


function apply_mutations(population, mutate, mutation_rate)
    mutated = randsubseq(eachindex(population), mutation_rate)
    result = copy(population)
    result[mutated] .= mutate.(result[mutated])
    result
end

function apply_crossover(population, crossover, crossover_rate)
    result = similar(population)
    
    for i in eachindex(population)
        if rand() < crossover_rate
            result[i] = crossover(samplepair(population)...)
        else
            result[i] = sample(population)
        end
    end

    result
end
