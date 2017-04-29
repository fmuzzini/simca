function [ model, ndata ] = pca_algo_mod( ndata, scala, pcn, flag )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[rig col] = size(ndata);

% faccio preprocessing solo se sto facendo per la prima volta pca
% se l'ho richiamata dopo aver rimosso gli outliers, non lo faccio
if flag
	%% preprocessing

	% calcolo valore medio per ogni colonna della matrice
	mean_cols = mean(ndata);

	% caso mean centring o autoscaling (mean + scaling)
	if (strcmp(scala, 'mean') || strcmp(scala, 'auto'))
		
		% sottraggo i valori medi di ogni colonna
		ndata = ndata - (ones(rig, 1) * mean_cols);
	end

	% caso solo scaling o autoscaling
	if (strcmp(scala, 'scaling') || strcmp(scala, 'auto'))
		
		% divido per i valori della deviazione standard di ogni colonna
		ndata = ndata ./ (ones(rig, 1) * std(ndata));    
	end
end


%% algoritmo pca SVD
[U,S, loadings] = svds(ndata, pcn); 
    
% autovalori
autovalori = (diag(S).^2)./(rig-1);
    
% calcolo la varianza spiegata
varianza_tot = sum(autovalori);
var_spieg = [];
for i=1:length(autovalori)
    var_spieg = [var_spieg autovalori(i)/varianza_tot];     %e' un vettore
end
var_spieg = 100*var_spieg;
    
% calcolo gli scores
scores = U * S;

% calcolo matrice residui
mat_res = ndata - scores*loadings';


model.scores = scores;
model.loadings = loadings;
model.varsp = var_spieg;
model.autovalori = autovalori;
model.residui = mat_res;
model.scala = scala;

end

