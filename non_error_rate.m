function [ vet_ner ] = non_error_rate( res, val, cat )
%NON_ERROR_RATE Calcola il non error rate per ogni classe
%   res = risultati del metodo di classificazione
%   val = indice delle classi di appartenenza dei campioni

vet_ner = [];

%per ogni categoria
for c = cat
    index = find(val == c);                 %trova i campioni della categoria
    giusti = sum(res(index) == val(index)); %conta quanti sono stati predetti giusti
    ner_cat = giusti / length(index) * 100; %calcola ner% giusti/totali * 100
    vet_ner = [vet_ner ner_cat];
end

end

