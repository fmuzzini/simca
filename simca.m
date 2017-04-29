function [  ] = simca(vet_cat)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nuovi_camp = [];
cat_file = [];

while (true)
   disp('1) Inserisci nuovi campioni');
   if (length(nuovi_camp) > 0)
       disp('2) Rimuovi campioni');
       disp('3) Visualizza grafici sui nuovi campioni');
       disp('4) Classifica nuovi campioni');
   end
   disp('5) Torna al menu precedente');
   
	s3 = [];
	% se ci sono solo le opzioni 1 e 5
	if (length(nuovi_camp) == 0)
		while (isempty(s3) || ~any(ismember(s3,[1,5])))
			s3 = input('Inserire operazione desiderata: ');
		end
	else
		while (isempty(s3))
			s3 = input('Inserire operazione desiderata: ');
		end
	end
   
   switch(s3)
       case 1
			file = input('Inserire il nome del file contenente i campioni: ','s');
				
			% se il file non esiste
			if (exist(file) == 0 || isempty(file))
				fprintf('Nome file non valido!\n\n');
			else
				tmp_dati_file = load(file);
                dati_file = tmp_dati_file.data_ts;
				tmp_cat_file = load(file);
                cat_file = tmp_cat_file.class_ind_ts;
				nuovi_camp = [nuovi_camp; dati_file];
			end

			continue;
           
       case 2
			to_remove = [];
			while (isempty(to_remove) || ~any(ismember(to_remove,[1:length(nuovi_camp)])))
				to_remove = input('Inserire gli indici dei campioni da eliminare, es. [1 2]: ');
			end
			
			% se l'indice non è 1
			if to_remove > 1
				nuovi_camp = [ nuovi_camp(1:to_remove-1,:) nuovi_camp(to_remove+1:end,:) ];
                cat_file = [ cat_file(1:to_remove-1) cat_file(to_remove+1:end) ];
			% se l'indice è 1, parto da 2
			else
				nuovi_camp = nuovi_camp(to_remove+1:end,:);
                cat_file = cat_file(to_remove+1:end);
			end
			continue;
           
       case 3
			for i=1:length(vet_cat)
				fprintf(strcat(num2str(i),')\t', vet_cat(i).name, '\n'));
			end
		   
			cat = [];
			while (isempty(cat) || ~any(ismember(cat,[1:length(vet_cat)])))
				cat = input('\nInserire modello di categoria sulla quale proiettare i campioni: ');
			end
			
			while true
			
				disp('1) scores plot');
				disp('2) loadings plot');
				disp('3) t2 e Q plot');
				disp('4) torna indietro');
				
				graf = [];
				while (isempty(graf) || ~any(ismember(graf,[1:4])))
					graf = input('Inserire grafico desiderato: ');
                end
                
                % faccio preprocessing ai campioni nuovi
                
                % calcolo valore medio per ogni colonna della matrice
                new_model = vet_cat(cat);
               
                mean_cols = mean(nuovi_camp);

                [rig_nc col_nc] = size(nuovi_camp);
                % caso mean centring o autoscaling (mean + scaling)
                if (strcmp(new_model.scala, 'mean') || strcmp(new_model.scala, 'auto'))

                    % sottraggo i valori medi di ogni colonna
                    nuovi_camp = nuovi_camp - (ones(rig_nc, 1) * mean_cols);
                end

                % caso solo scaling o autoscaling
                if (strcmp(new_model.scala, 'scaling') || strcmp(new_model.scala, 'auto'))

                    % divido per i valori della deviazione standard di ogni colonna
                    nuovi_camp = nuovi_camp ./ (ones(rig_nc, 1) * std(nuovi_camp));    
                end
			   		   
			   new_model.scores = nuovi_camp*new_model.loadings;            % calcolo i nuovi scores del nuovo campione nello spazio pca della j-esima classe
			   new_data = new_model.scores*new_model.loadings';            % ricalcolo i nuovi dati in fit nel modello pca
			   new_model.residui = nuovi_camp - new_data;
			   
			   switch(graf)
					case 1
						[rig, col] = size(new_model.scores);
						x = []; y = [];
						
						while (isempty(x) || ~any(ismember(x,[1:col])) || length(x) > 1)
							x = input('PC asse x: ');
						end
						while (isempty(y) || ~any(ismember(y,[1:col])) || length(y) > 1)
							y = input('PC asse y: ');
						end
						
						fig_scores = scatter_mod(new_model.scores, cat, [x y], true);
                        
                        save_images(fig_scores);
						continue;
					   
					case 2
						[rig, col] = size(new_model.loadings);
						x = []; y = [];
						
						while (isempty(x) || ~any(ismember(x,[1:col])) || length(x) > 1)
							x = input('PC asse x: ');
						end
						while (isempty(y) || ~any(ismember(y,[1:col])) || length(y) > 1)
							y = input('PC asse y: ');
						end
						
						fig_s_l = scatter_loadings(new_model.loadings, new_model.var, [x y]);
                        
                        save_images(fig_s_l);
						continue;
					   
					case 3
					   %essendo una sola cat è stato messo un vettore fittizzio come sopra
					   [fig_q_tquadro q tquadro] = compute_q_tquadro(new_model, cat, true);
					   
					   save_images(fig_q_tquadro);
					   continue;
					   
					case 4
						break;
					
					otherwise
						fprintf('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!\n\n');
						continue;
						
				end
			end
			continue;
           
       case 4
			% ordino matrice test esterno
			mat_ordinata = [];
			for c=unique(cat_file)
				mat_ordinata = [mat_ordinata ; nuovi_camp(cat_file == c,:)];
            end
            
            % ricostruisco il vettore delle categorie dei modelli creati
            cat_model = [];
            for k=1:length(vet_cat)
                cat_model = [cat_model vet_cat(k).cat];
            end
            			
			% creo la matrice di confusione vuota -> mi serve per evitare di rifare tutti i calcoli
			confusion_mat = zeros(length(unique(cat_file)), length(unique(cat_model))+1);
            
            % classificazione test esterno
            [assegnati, mat_q_t, limiti] = classification(vet_cat, mat_ordinata, true);  % lo faccio fuori dai case perche' serve ad entrambi
             
            % ordino vettore delle classi vere del test set esterno
            cat_file_sort = [];
            for i=unique(cat_file)
                cat_file_sort = [cat_file_sort cat_file(cat_file == i)];
            end
           
            while true
			
				disp('1) visualizza grafici e statistiche per una specifica categoria');
				disp('2) visualizza accuratezza intero modello SIMCA');
                disp('3) torna indietro');
                
                ans_cla_or_val = [];
				while (isempty(ans_cla_or_val))
                    ans_cla_or_val = input('Inserire opzione: ');
                end
                                
                switch(ans_cla_or_val)
                   case 1
                       
                        for i=1:length(vet_cat)
                            fprintf(strcat(num2str(i),')\t', vet_cat(i).name,'\n'));
                        end
                       
                        cat = [];
                        while (isempty(cat) || ~any(ismember(cat,[1:length(vet_cat)])))
                            cat = input('Scegli la categoria su cui vedere la classificazione: ');
                        end
                                        
                        % calcolo t2ridotto e qridotto per solo la
                        % categorie indicata
                        vettore_q_rid = [];
                        vettore_t2_rid = [];
                        [rig_mat_q_t col_mat_q_t] = size(mat_q_t);
                        for i=1:rig_mat_q_t
                           vettore_q_rid = [vettore_q_rid mat_q_t(i,cat).q/limiti(cat).qlim];
                           vettore_t2_rid = [vettore_t2_rid mat_q_t(i,cat).t/limiti(cat).t2lim];
                        end
                        
                        % faccio grafico q ridotto e t2 ridotto
                        fig_t2rid_qrid = scatter_mod([vettore_t2_rid' vettore_q_rid'], cat, [1 2], true);
                        
                        % disegno la linea di appartenenza alla classe
                        hold on;
                        x_circ = [0:.0001:sqrt(2)];
                        y_circ=sqrt(2 - x_circ.^2);          % equivale a y^2 = sqrt(r^2 - x^2)
                        plot(x_circ, y_circ, 'LineStyle','--');
                        
                        title(['T^2 ridotto VS Q ridotto categoria ' num2str(cat)]);
                        xlabel('T^2 ridotto');
                        ylabel('Q ridotto'); 
                        
                        % calcolo metriche per la categoria indicata
						
                        if (not(confusion_mat))				% se la matrice di confusione e' vuota, e' la prima volta che si richiede tale case 						
							
							confusion_mat(:,1) = unique(cat_file);             % prima colonna matrice confusione (nomi categorie)                       		
							
							% estraggo gli assegnamenti dei campioni di ogni categoria
							assegnati_cat_i = [];
							index = 1;
							for s=unique(cat_file)
								num_sample_cat_i = sum(cat_file == s);				% numero campioni di quella categoria
                                if (index == 1)
                                    assegnati_cat_i{s} = assegnati(index:num_sample_cat_i); 
                                else
                                    assegnati_cat_i{s} = assegnati(index:(index-1)+num_sample_cat_i);
                                end
                                
								index = (index-1)+num_sample_cat_i+1;
                            end     
                            
                            pino=[];
                            for pp=1:length(assegnati_cat_i)
                                pino = [pino length(assegnati_cat_i{pp})];
                            end
                        
							% riempio matrice di confusione
							for cg=1:length(unique(cat_file))			% per le categorie vere
								for ctg=1:length(unique(cat_model))		% campioni di quella categoria assegnati alle varie categorie (in modo corretto o errato)
									% riempio cella della matrice confusione con somma campioni assegnati
									confusion_mat(cg,ctg+1) = sum(assegnati_cat_i{cg} == ctg);
								end						
                            end	
                            
                        end						% se la matrice di confusione l'avevo gia' calcolata
	
                        j = cat_model(cat);
                        % calcolo sensitivity
                        sensitivity = 100*confusion_mat(j,j+1)/(sum(confusion_mat(j,2:end)));
                        if isnan(sensitivity)
                           sensitivity = 0; 
                        end
                        % calcolo specificity
                        specificity = 100*confusion_mat(j,j+1)/(sum(confusion_mat(1:end,j+1)));
                        if isnan(specificity)
                           specificity = 0; 
                        end
                        % calcolo efficiency
                        efficiency = 100*sqrt((sensitivity/100)*(specificity/100));
                        

                        disp(['Statistiche classificazione test set nel modello della categoria ' num2str(cat) ':']);
                        disp(['efficiency: ' num2str(efficiency)]);
                        disp(['specificity: ' num2str(specificity)]);
                        disp(['sensitivity: ' num2str(sensitivity)]);
                        
                        
                        ner_cat = non_error_rate(assegnati, cat_file_sort, cat_model);
						                        
                        disp(['accuratezza: ' num2str(ner_cat(cat))]);
                        
                        save_images(fig_t2rid_qrid);
                        
                        continue;

                    case 2
                        
                        
                        ner_cat = non_error_rate(assegnati, cat_file_sort, cat_model);
						
                        % calcolo statistiche globali per tutte le categorie
                        accuratezza = mean(ner_cat);
                        
                        disp(['accuratezza: ' num2str(accuratezza)]);
                        
                        continue;
                        
                    case 3
                        break;
                         
                    otherwise
						fprintf('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!\n\n');
						continue;
                        
                end
            end   
			continue;
			
       case 5
           return;
		   
		otherwise
			fprintf('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!\n\n');
			continue;
           
   end
end

end

