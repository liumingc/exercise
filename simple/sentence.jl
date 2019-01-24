
tbl = Dict(
    :sentence => (:seq, [:noun_phrase, :verb_phrase]),
    :noun_phrase => (:seq, [:article :noun]),
    :verb_phrase => (:seq, [:verb, :noun_phrase]),
    :article => (:one_of, [:the, :a]),
    :noun => (:one_of, [:man, :ball, :woman, :table, :tree]),
    :verb => (:one_of, [:hit, :took, :saw, :liked, :climbed])
)

function generate(word)
    if haskey(tbl, word)
        head, lst = tbl[word]
        if head == :seq
            map(generate, lst)
        elseif head == :one_of
            sz = length(lst)
            n = rand(1:sz)
            print(lst[n], " ")
        end
    end
end

for i=1:5
    generate(:sentence)
    println("\n=========")
end
