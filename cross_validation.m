function [ pcn_sensitivity pcn_specificity pcn_efficiency avg_q_t2 ] = cross_validation( ndata, alg, splits, cat, cat_scelta, scala )
% CROSS_VALIDATION fa cv con diversi schemi di cancellazione e classifica i campioni rimossi, tiene il risultato ottenuto in maggioranza

	pcn_efficiency = zeros(length(unique(cat)),rank(ndata));
	pcn_sensitivity = zeros(length(unique(cat)),rank(ndata));
	pcn_specificity = zeros(length(unique(cat)),rank(ndata));
			
	confusion_mat = zeros(length(unique(cat)), length(unique(cat))+1);
	confusion_mat(:,1) = unique(cat);             % prima colonna matrice confusione (nomi categorie)
	
	% VETTORI CHE CONTERRANO LA MEDIA DI Q E T2 DEI CAMPIONI TOLTI PER OGNI MODELLO CON UN DETERMINATO NUMERO DI PC PER UNA CATEGORIA
	avg_q_all_pc = [];
	avg_t2_all_pc = [];	

	mat_q_t	= [];
	
	
	for i=1:rank(ndata)								% per tutte le possibili pcn fino al rango	
		non_assegnati = 0;
	
		cat_per_campione = [];						% sarà matrice con assegnamento campione-classe per ogni tipo di cancellazione (sulle righe)
		campioni = [];								% conterrà per ogni campione la categoria assegnata
		indici_finali = zeros(1,length(unique(cat)));
		
		[rig_ndata col_ndata] = size(ndata);
		if alg == 2
			blind = splits;
		else
			blind = rig_ndata / splits;                    % calcolo quanti campioni tolgo dalla matrice completa
		end
		
		for b=1:blind								% un modello (per ogni categoria) per ogni diversa cancellazione (verrà tenuto il ris più frequente dalla classificazione)
		
			cat_per_campione_modello_sing = zeros(1,rig_ndata);				% sarà vettore con assegnamento campione-categoria
			assegnati_aggiunto = zeros(1,rig_ndata);						% serve se faccio una assegnazione in più per un campione già assegnato (con altra cancellazione)
		
			indici = [];													% per tenere in memoria dove finiscono i campioni di una categoria e iniziano gli altri			
			modelli = [];													% sarà vettore con un modello per ogni categoria, con questo schema di cancellazione
			dati_test = [];													% matrice con i campioni tolti da testare
					
			% PRIMO LOOP SULLE CATEGORIE > costruisco un modello per ogni categoria, con lo stesso schema di cancellazione
			for c=1:length(unique(cat))
						
				u = unique(cat);
				ndata_cat = ndata(cat == u(c),:);			% matrice con solo la categoria presa in considerazione
				
				if c == 1
					indici_finali(c) = length(ndata_cat);
				else
					indici_finali(c) = indici_finali(c-1)+length(ndata_cat);
				end
						
				[rg cl] = size(ndata_cat);
				% la cancellazione è bilanciata perchè alg e splits si riferiscono alla matrice dei campioni della SINGOLA categoria
				[vect_ind ndata_solo_i] = schema_cancellazione(ndata_cat, alg, splits, b);
				dati_test = [dati_test ; ndata_solo_i];			% ho matrice con campioni da tutte le categorie (da testare)
				[l cl] = size(dati_test);
				indici = [indici l];			% ultimi indici di categoria
					
				% calcolo modello pca con tutti gli altri campioni tranne quelli da cancellare
				ndata_meno_i = ndata_cat(not(vect_ind), :);      % creo una matrice con la/e riga/he i-esime estratte
	 							
				% un modello per ogni categoria, con i campioni tenuti
				[modello_pca ndata_meno_i_pre] = pca_algo_mod(ndata_meno_i, scala, i, false);
				modelli = [modelli modello_pca];		% modelli per ogni categoria, per questo tipo di cancellazione	
			end
						
			inizio = 1;			
			% SECONDO LOOP sulle categorie > classifico i campioni (rimossi) di ogni categoria secondo i modelli costruiti prima
			for ct=1:length(unique(cat))			% per ogni categoria
				test = dati_test(inizio:indici(ct),:);
				% faccio classificazione dei campioni di questa categoria, assegnati è vettore con classe (indice) assegnata per ciascun campione
				[assegnati mat_q_t limiti] = classification(modelli, test, false);
						
				md = mod(b,length(test));
				if md == 0
					md = length(test);				% altrimenti se arriva all'ultima riga, il modulo è 0 (indice 0 non valido per accedere)
				end
				if ct > 1
					md = md+indici_finali(ct-1);
				end

				for a=1:length(assegnati)
					if cat_per_campione_modello_sing(md) == 0					% se nel vettore la posizione è ancora non assegnata
						cat_per_campione_modello_sing(md) = assegnati(a);
					else
						assegnati_aggiunto(md) = assegnati(a);					% se la posizione è già stata assegnata, metto l'assegnamento in un vettore sotto
						cat_per_campione = [cat_per_campione ; assegnati_aggiunto];
					end
					
					md = md+splits;
				end
						
				inizio = indici(ct)+1;
			end
			
			cat_per_campione = [cat_per_campione ; cat_per_campione_modello_sing];			% una riga per ogni assegnamento fatto (se = 0, cella vuota)		
			
		end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% ottengo i valori medi di t2 e q per poter farne i grafici in funzione delle pc
	
		[rig_mat_q_t col_mat_q_t] = size(mat_q_t);
		sum_q = 0;
		sum_t2 = 0;

		for num_c=1:length(rig_mat_q_t)
			sum_q = sum_q + mat_q_t(num_c, cat_scelta).q;
			sum_t2 = sum_t2 + mat_q_t(num_c, cat_scelta).t;
		end
		avg_q_samples_per_cat = sum_q / rig_mat_q_t;						% valore medio di q dei campioni per quella categoria
		avg_t2_samples_per_cat = sum_t2 / rig_mat_q_t;						% valore medio di t2 dei campioni per quella categoria
		
		avg_q_all_pc = [avg_q_all_pc avg_q_samples_per_cat];
		avg_t2_all_pc = [avg_t2_all_pc avg_t2_samples_per_cat];
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					
		[ris_per_blind num_campioni] = size(cat_per_campione);
		for cm=1:num_campioni			
			majority = mode(cat_per_campione(find(cat_per_campione(:,cm) ~= 0)', cm));			% con mode trovo la categoria presente in maggioranza negli assegnamenti fatti (elem ~= 0)
			if majority == -1
				non_assegnati = non_assegnati+1;
			end
			campioni = [campioni majority];												% vettore con una categoria per campione
		end
		
		% riempio matrice di confusione
		camp = 1;
		for cg=1:length(unique(cat))			% per ogni categoria (riga)
			for ctg=1:length(unique(cat))		% campioni di quella categoria assegnati alle varie categorie (in modo corretto o errato)
				% riempio cella della matrice confusione con somma campioni assegnati
				confusion_mat(cg,ctg+1) = sum(campioni(camp:indici_finali(cg)) == ctg);
			end
						
			camp = indici_finali(cg)+1;						
		end					

		%disp(confusion_mat);
		%disp(non_assegnati);
		% per ogni categoria
		for j=1:length(unique(cat))
			% calcolo sensitivity
			sensitivity = 100*confusion_mat(j,j+1)/(sum(confusion_mat(j,2:end)));
			if isnan(sensitivity)
				sensitivity = 0;
			end
			% calcolo sensibility
			specificity = 100*confusion_mat(j,j+1)/(sum(confusion_mat(1:end,j+1)));
			if isnan(specificity)
				specificity = 0;
			end
			% calcolo efficiency
			efficiency = 100*sqrt((sensitivity/100)*(specificity/100));
						
			pcn_efficiency(j,i) = efficiency;		% per grafico (ogni riga è una categoria, colonne = pcs)
			pcn_sensitivity(j,i) = sensitivity;
			pcn_specificity(j,i) = specificity;
		end

	end

	% creo un'unica matrice per le medie di q e t2
	avg_q_t2 = [avg_q_all_pc' avg_t2_all_pc'];
					
end