function [ assegnati, mat_q_t, limiti ] = classification( model_single_class, data_ts, flag )
% funzione che effettua la classificazione dei campioni da stimare

% parametri input:
%             - modelli pca su cui proiettare i campioni da stimare (un modello per categoria)
%             - matrice dei campioni da stimare
% parametri output:
%             - vettore di categorie assegnate per campione
%			  - matrice di struct contenenti q e t2 per ogni modello (colonne) e campione (righe)
%			  - vettore di struct contenenti residui, qlim e t2lim per ogni modello
    
    [rig_data_ts col_data_ts] = size(data_ts);
	mat_q_t = [];
	assegnati = [];
	limiti = [];
	
	for r=1:length(model_single_class)
        
		new_scores = data_ts*model_single_class(r).loadings;            % calcolo i nuovi scores del nuovo campione nello spazio pca della m-esima classe
		new_data_ts = new_scores*model_single_class(r).loadings';            % ricalcolo i nuovi dati in fit nel modello pca
		new_residui = data_ts - new_data_ts;
				
		% qui i residui sono calcolati sul modello corrente (non sul nuovo modello appena calcolato)
		qlim = residuallimit(model_single_class(r).residui);                                       % calcolo linea confidenza (95%) per i residui q
		[rig_score col_score] = size(model_single_class(r).scores);
		t2lim = tsqlim(rig_score, col_score, 0.95);                                 % calcolo linea confidenza (95%) per i residui t2
			
		tmp.residui = new_residui;
		tmp.qlim = qlim;
		tmp.t2lim = t2lim;
			
		limiti = [limiti tmp];						% memorizzo limiti corrispondenti + new_residui
	end

    for i=1:rig_data_ts								% per ogni campione (precedentemente rimosso)

		mat_temp = [];								% sarà vettore di struct con q e t2 per ogni modello (campione corrente)
        best_class_distance = intmax;
		
		best_cat = -1;                               % NEL CASO NON VENGA ASSEGNATO A NESSUNA CLASSE (HO MESSO -1 E NON 0 PERCHE' DOPO NON E' RICONOSCIBILE NELLA MANIPOLAZIONE DEGLI ASSEGNATI)
		
		for m=1:length(model_single_class)			% per ogni modello di categoria, classifico il campione e vedo a quale categoria viene assegnato
            
            % faccio preprocessing ai campioni nuovi solo se tale funzione e'
            % chiamata dal file simca (e non per la crossvalidation)
            if (flag)

                % calcolo valore medio per ogni colonna della matrice
                mean_cols = mean(data_ts);

                [rig col] = size(data_ts);
                % caso mean centring o autoscaling (mean + scaling)
                if (strcmp(model_single_class(m).scala, 'mean') || strcmp(model_single_class(m).scala, 'auto'))
                    
                    % sottraggo i valori medi di ogni colonna
                    data_ts = data_ts - (ones(rig, 1) * mean_cols);
                end

                % caso solo scaling o autoscaling
                if (strcmp(model_single_class(m).scala, 'scaling') || strcmp(model_single_class(m).scala, 'auto'))

                    % divido per i valori della deviazione standard di ogni colonna
                    data_ts = data_ts ./ (ones(rig, 1) * std(data_ts));    
                end
            end

			new_scores = data_ts*model_single_class(m).loadings;
            new_residui = limiti(m).residui;
			% calcolo q e t2
			new_q = diag(new_residui*new_residui');
			new_q = new_q(i);								% prendo solo valore corrispondente al campione
			new_t2 = diag(new_scores*inv(diag(model_single_class(m).autovalori))*new_scores');
			new_t2 = new_t2(i);
			
			tmp.q = new_q;
			tmp.t = new_t2;
			mat_temp = [mat_temp tmp];
			
			% calcolo distanza
			class_distance = sqrt((new_q/limiti(m).qlim)^2+(new_t2/limiti(m).t2lim)^2);
			   
			% regola di classificazione
			if (class_distance < sqrt(2))                              % il campione appartiene alla classe
				if class_distance < best_class_distance
					% se due classi sono <sqrt(2), si sceglie quella più vicina (distanza minore)
					best_class_distance = class_distance;
					best_cat = m;								% assegno indice di categoria
				end
			end
        end

		mat_q_t = [mat_q_t ; mat_temp];				% matrice con righe = campioni e colonne = modelli, le celle hanno struct di q e t2
		assegnati = [assegnati best_cat];			% vettore di indici (delle categorie)
           
    end    

end



