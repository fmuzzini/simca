function [ model_single_class ] = main_simca()

	%% caricamento e processing dataset
	while true
		file = input('Nome file: ','s');
				
		% se il file non esiste
		if (exist(file,'file') == 0 || isempty(file))
			disp('Nome file non valido!');
		else
			new_model = load(file);
			
			data_tr = new_model.data_tr;                    % matrice dati calibrazione
			data_ts = new_model.data_ts;                    % matrice dati test esterno

			class_ind_tr = new_model.class_ind_tr;          % categorie dati calibrazione
			class_ind_ts = new_model.class_ind_ts;          % categorie dati test esterno
			var_label = new_model.var_label;                % etichette variabili

			var = cellstr(var_label);                       % trasformo le label in string e non in char
			cat_tr = unique(class_ind_tr);                  % processamento categorie dati calibrazione
			cat_ts = unique(class_ind_ts);                  % processamento categorie dati test esterno
			break;
		end
	end


	%% ordinamento secondo categorie matrice completa
	mat_completa = [];
	for c = cat_tr
		mat_completa = [mat_completa ; data_tr(class_ind_tr == c,:)];
	end	
	
	%% preprocessing e analisi pca suddivisa per categorie
	model_single_class = [];                                                    % vettore che conterra' tutti i modelli pca delle classi scelte dall'utente (per il momento li salvo qua, ma andrebbero nel modello simca)
	fprintf(strcat('\nIn questo dataset ci sono\t', num2str(length(cat_tr)), ' categorie\n'));
	cat_scelta = [];
	while (isempty(cat_scelta) || ~any(ismember(cat_scelta,[1:length(cat_tr)])))
		cat_scelta = input('Indica il numero corrispondente alle categorie su cui effettuare analisi pca (es. [1 2 3]): ');
	end

	for i = cat_scelta
		data_tr_class_i = data_tr(class_ind_tr == i, :);                        % ottengo la matrice con soli campioni dell'i-esima categoria
		fprintf(strcat('Categoria:\t',num2str(i),'\n'));
		mod = main_pca(mat_completa, data_tr_class_i, class_ind_tr, i, var);
		model_single_class = [model_single_class mod];       % concateno i modelli su cui e' stata effettuata pca
	end

end

