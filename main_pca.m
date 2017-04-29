function [ model ] = main_pca( ndata_all, ndata, cat_all, cat, var )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
	
	fprintf('\n');

    ndata_orig = ndata;   
        
    % tipo di pca
	fprintf('Tipo di algoritmo pca disponibile: svd\n\n');

    % chiedo all'utente il tipo di scalatura
    scala = [];
    while (isempty(scala) || ~any([strcmp(scala,'mean') strcmp(scala,'scaling') strcmp(scala,'auto')]))
        scala = input('Scegli il tipo di scalatura (mean o scaling o auto): ', 's');
    end

        
    % mostro scree plot
    [model, ndata] = pca_algo_mod(ndata, scala, rank(ndata), true);
    scree_plot(rank(ndata), model.autovalori);
	title('Scree plot');
	
	% mostro grafici cv
	cv = [];
	while (isempty(cv) || ~any(ismember(cv,['y', 'n'])))
		cv = input('\nVedere anche grafici cv per scegliere numero pc? "y" o "n": ','s');
	end
	
	if strcmp(cv,'y')
		%% cross validation
			
        % chiedo all'utente lo schema di cancellazione che vuole usare
		alg = [];
		while(isempty(alg) || ~any(ismember(alg,[1,2])))
			alg = input('Scegli lo schema di cancellazione per la cv: 1: leave one out, 2: venetian blinds: ');
		end
				
		if (alg == 2)
		   splits = [];
		   [r c] = size(ndata_all);
		   while (isempty(splits) || splits <= 0 || splits > r)
				splits = input('Inserisci il numero di splits: ');  % calcolo ogni quanti campioni ne tolgo uno
		   end 
		else
			splits = 1;                                     % il leave one out equivale ad un venetian blind con splits a 1
		end
				
		disp('...Calcolo cv...');
		[sensitivity specificity efficiency avg_q_t2] = cross_validation(ndata_all, alg, splits, cat_all, cat, scala);		% funzione cross_validation per i calcoli
				
		%% grafici			
		select_cat = cat;		% se siamo in simca, a main_pca è stata passata una sola categoria cat
			
		best_efficiency = max(efficiency(select_cat,:));
		best_pcn = find(efficiency(select_cat,:) == best_efficiency);		% trovo indice di best_efficiency (num pcs)
			
		% per categoria/classe
		sens_fig = scree_plot(rank(ndata), sensitivity(select_cat,:));
		ylabel('Sensitivity');
		title(['CV Sensitivity class  ',num2str(select_cat)]);
			
		spec_fig = scree_plot(rank(ndata), specificity(select_cat,:));
		ylabel('Specificity');
		title(['CV Specificity class  ',num2str(select_cat)]);
				
		eff_fig = scree_plot(rank(ndata), efficiency(select_cat,:));
		ylabel('Efficiency');
		title(['CV Efficiency class  ',num2str(select_cat)]);
			
		% aggiungo grafico q e t2 vs pc
		fig_q_pc = scree_plot(rank(ndata), avg_q_t2(:,1)');
		ylabel('Avg Q');
		title('Average Q in CV');
		
		fig_t2_pc = scree_plot(rank(ndata), avg_q_t2(:,2)');
		ylabel('Avg T^2');
		title('Average T^2 in CV');
			
		fig_cv = [sens_fig spec_fig eff_fig fig_q_pc fig_t2_pc];
			
        % salvo le immagini se l'utente vuole
        save_images(fig_cv);
    end
    
    % mostro grafici fit
	cv = [];
	while (isempty(cv) || ~any(ismember(cv,['y', 'n'])))
		cv = input('\nVedere anche grafici fit per scegliere numero pc? "y" o "n": ','s');
	end
	
	if strcmp(cv,'y')
		%% fit
		disp('...Calcolo fit...');
		[sensitivity_fit specificity_fit efficiency_fit avg_q_t2_fit] = fit(ndata_all, cat_all, cat, scala);		% funzione fit per i calcoli
				
		%% grafici			
		select_cat = cat;		% se siamo in simca, a main_pca è stata passata una sola categoria cat
			
		best_efficiency = max(efficiency_fit(select_cat,:));
		best_pcn = find(efficiency_fit(select_cat,:) == best_efficiency);		% trovo indice di best_efficiency (num pcs)
			
		% per categoria/classe
		sens_fig = scree_plot(rank(ndata), sensitivity_fit(select_cat,:));
		ylabel('Sensitivity');
		title(['Fit Sensitivity class  ',num2str(select_cat)]);
			
		spec_fig = scree_plot(rank(ndata), specificity_fit(select_cat,:));
		ylabel('Specificity');
		title(['Fit Specificity class  ',num2str(select_cat)]);
				
		eff_fig = scree_plot(rank(ndata), efficiency_fit(select_cat,:));
		ylabel('Efficiency');
		title(['Fit Efficiency class  ',num2str(select_cat)]);
			
		% aggiungo grafico q e t2 vs pc
		fig_q_pc = scree_plot(rank(ndata), avg_q_t2_fit(:,1)');
		ylabel('Avg Q');
		title('Average Q in Fit');
		
		fig_t2_pc = scree_plot(rank(ndata), avg_q_t2_fit(:,2)');
		ylabel('Avg T^2');
		title('Average T^2 in Fit');
			
		fig_cv = [sens_fig spec_fig eff_fig fig_q_pc fig_t2_pc];
			
        % salvo le immagini se l'utente vuole
        save_images(fig_cv);
	end
	

    % chiedo all'utente il numero delle pc
    pcn = [];
    % non valido se: pcn vuoto, pcn negativo, pcn maggiore delle componenti disponibili, utente ha inserito più di un valore, utente ha scelto una sola pc
    while (isempty(pcn) || pcn < 0 || pcn > rank(ndata) || length(pcn) > 1 || pcn == 1)
        pcn = input('\nNumero di componenti principali, per il rango mettere 0: ');
    end
    if (pcn == 0)
        pcn = rank(ndata);
    end

    % controllo tabelle fat
    [rig_m col_m] = size(ndata);
    if (rig_m > col_m)
        [model, ndata] = pca_algo_mod(ndata_orig, scala, pcn, true);
    else
        [model, ndata] = pca_algo_mod(ndata_orig', scala, pcn, true);
    end

	q = [];
	while true
		
		% stampa del menu
		fprintf('\n1: esegui grafico scores\n');
		disp('2: esegui grafico loadings');
		disp('3: esegui scree plot');
		disp('4: esegui grafici validazione modello (Q e T^2)');
		disp('5: esegui contribution plot');
		disp('6: elimina un valore anomalo');
		disp('7: esci');
		
		scelta = [];
		while (isempty(scelta))
			scelta = input('Indica il numero dell''operazione da eseguire: ');
		end
		
		switch(scelta)
			case 1
				
				% fare grafico scores
				[rig, col] = size(model.scores);
				
				var_x = [];
				var_y = [];
				
				while (isempty(var_x) || ~any(ismember(var_x,[1:col])) || length(var_x) > 1)
					var_x = input('Indica un numero relativo alla pc1 sull asse x nello scatter plot degli scores: ');
				end
				while (isempty(var_y) || ~any(ismember(var_y,[1:col])) || length(var_y) > 1)
					var_y = input('Indica un numero relativo alla pc2 sull asse y nello scatter plot degli scores: ');
				end
				
				fig_h = scatter_mod(model.scores, cat, [var_x var_y], false);
			   
				% salvo le immagini se l'utente vuole
				save_images(fig_h);

				continue;
			case 2
			   
				% fare grafico loadings
				[rig, col] = size(model.loadings);
				
				var_x = [];
				var_y = [];
				
				while (isempty(var_x) || ~any(ismember(var_x,[1:col])) || length(var_x) > 1)
					var_x = input('Indica un numero relativo alla pc1 sull asse x nello scatter plot dei loadings: ');
				end
				while (isempty(var_y) || ~any(ismember(var_y,[1:col])) || length(var_y) > 1)
					var_y = input('Indica un numero relativo alla pc2 sull asse y nello scatter plot dei loadings: ');
				end
						   
				fig_b = scatter_loadings(model.loadings, var, [var_x var_y]);
				
				% salvo le immagini se l'utente vuole
				save_images(fig_b);
				
				continue;
				
			case 3
			   
				% fare scree plot
				fig_bc = scree_plot(pcn, model.autovalori);            
				
				% salvo le immagini se l'utente vuole
				save_images(fig_bc);
				
				continue;
			case 4
				
				% q e tquadro
				[fig_q_tquadro q tquadro] = compute_q_tquadro(model, cat, true);
				
				% salvo le immagini se l'utente vuole
				save_images(fig_q_tquadro);
				
				continue;
			case 5
				% faccio contribution plot
				
				sample = [];
				if isempty(q)
					fprintf('\nDovresti prima controllare il numero del campione nel grafico di Q e T^2!\n\n');
				else
					while (isempty(sample) || ~any(ismember(sample,[1:length(q)])))
						sample = input('Indica il numero del campione per cui fare il contribution plot: ');
					end
					fig_cont = contribution_plot(var, sample, model, ndata);
					
					% salvo le immagini se l'utente vuole
					save_images(fig_cont);
				end
				continue;
			case 6
				% eliminazione outlier/s secondo richiesta dell'utente
				if isempty(q)
					fprintf('\nDovresti prima controllare il numero del campione nel grafico di Q e T^2!\n\n');
				else
					while true
						%variabile che registra la scelta dell'utente
						rm_index = input('\nSeleziona indice (se piu di uno, es. [1 2]: ');

						%finchè non viene scelto niente, dai errore
						if isempty(rm_index)
							fprintf('\t\tErrore: devi scegliere almeno un indice!\n\n');
							
						%se è stata fatta una scelta non accettabile
						elseif ~any(ismember(rm_index,[1:length(q)]))
							fprintf('\t\tErrore: indice inserito non corretto!\n\n');

						%se non ci sono stati errori, ferma il ciclo
						%(dati inseriti correttamente)
						else
							break;
						end
					end
					
					ndata_modified = remove_outlier(model, ndata, rm_index, q, tquadro, cat);
					
					% richiamo pca per fare calcoli e grafici senza il campione rimosso
					[model, ndata] = pca_algo_mod(ndata_modified, scala, pcn, false);
				end
				continue;
			case 7
				
				%prima di uscire, riempio i campi del modello
				fprintf('\nPrima di uscire, indica il nome del modello da memorizzare\n');
				name = [];
				while (isempty(name))
					name = input('Inserire nome modello: ','s');
				end
				
				model.name = name;
				model.var = var;
				model.ndata = ndata;
				model.ndata_orig = ndata_orig;
				model.pcn = pcn;
				model.cat = cat;
				
				return;
			otherwise
				disp('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!');
				continue;
		end

	end

end

