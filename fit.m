function [ pcn_sensitivity, pcn_specificity, pcn_efficiency, q_t ] = fit( ndata, cat, cat_scelta, scala )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

rango = rank(ndata);
confusion_mat = zeros(length(unique(cat)));
pcn_sensitivity = zeros(length(unique(cat)), rango);
pcn_specificity = zeros(length(unique(cat)), rango);
pcn_efficiency = zeros(length(unique(cat)), rango);
q_t = [];


%per ogni numero di pc
for pc=1:rango
	indici = zeros(1,length(unique(cat)));
	modelli = [];
    
    %costruisco modello per ogni categoria
	u = unique(cat);
    for c=1:length(u)
		ndata_cat = ndata(cat == u(c),:);
		
		if c == 1
			indici(c) = length(ndata_cat);
		else
			indici(c) = indici(c-1)+length(ndata_cat);
		end

        [modello ndata_new] = pca_algo_mod(ndata_cat, scala, pc, false);
        modelli = [modelli modello];
    end
    [assegnati, mat_q_t, limiti] = classification(modelli, ndata, false);

    q = mat_q_t(:,cat_scelta).q;
    t = mat_q_t(:,cat_scelta).t;
    
    mean_t = mean(t);
    mean_q = mean(q);
    
    riga_q_t = [mean_q, mean_t];
    
    q_t = [q_t; riga_q_t];
    
    % riempio matrice di confusione
    camp = 1;
	for cg=1:length(unique(cat))			% per ogni categoria (riga)
		
        for ctg=1:length(unique(cat))		% campioni di quella categoria assegnati alle varie categorie (in modo corretto o errato)
			% riempio cella della matrice confusione con somma campioni assegnati
			confusion_mat(cg,ctg) = sum(assegnati(camp:indici(cg)) == ctg);
		end
					
		camp = indici(cg)+1;						
    end

    % per ogni categoria
    for j=1:length(unique(cat))
        % calcolo sensitivity
        sensitivity = 100*confusion_mat(j,j)/(sum(confusion_mat(j,:)));
        % calcolo sensibility
        specificity = 100*confusion_mat(j,j)/(sum(confusion_mat(:,j)));
        % calcolo efficiency
        efficiency = sqrt(sensitivity*specificity);

        pcn_efficiency(j,pc) = efficiency;		% per grafico (ogni riga è una categoria, colonne = pcs)
        pcn_sensitivity(j,pc) = sensitivity;
        pcn_specificity(j,pc) = specificity;
    end
end

end

