function [ model ] = pca_algo( file,cent_auto )

	% acquisisco dataset da file
	if exist(file) == 2				% se è un file matlab
		new_model = load(file);
			
		NUM = new_model.data_tr;                    	% matrice dati calibrazione

		class_ind_tr = new_model.class_ind_tr;          % categorie dati calibrazione
		categorie = unique(class_ind_tr);               % processamento categorie dati calibrazione
			
		var_label = new_model.var_label;                % etichette variabili
		variabili = cellstr(var_label);                 % trasformo le label in string e non in char
			
		nvar = length(variabili);
		ncat = length(class_ind_tr);
		cat = length(categorie);
			
		% ordinamento secondo categorie matrice completa
		mat_completa = [];
		for c = categorie
			mat_completa = [mat_completa ; NUM(class_ind_tr == c,:)];
		end
		NUM = mat_completa;
			
		if ischar(categorie(1))
			[categorie,cat,vettore_indici] = processa_categorie(class_ind_tr,length(class_ind_tr));
		else
			%matrice con una colonna per categoria, ogni colonna avrà gli indici
			%dei campioni (righe) che fanno parte di quella categoria
			vettore_indici = zeros(ncat,cat);
        
			%per ogni categoria, riempio una colonna di vettore_indici
			for v=1:cat
				% prendo pezzo di matrice di una categoria (indici)
				righe = find(class_ind_tr == v);
				%trovo quanti campioni ne fanno parte (nomi uguali)
				num = length(righe);
				%trovo gli indici delle categorie (uso num per vettore_indici)
				vettore_indici(1:num,v) = righe;
			end
		end
			
			
	else
		[NUM,TXT,RAW] = xlsread(file);
			
		%creo vettore con nomi delle variabili (colonne)
		variabili = TXT(1,2:end);
		%lunghezza vettore (quanti nomi di variabili ci sono)
		nvar = length(variabili);
    
		%creo vettore con nomi delle categorie (righe)
		categorie = TXT(2:end,1);
		%lunghezza vettore (quanti nomi di categorie ci sono)
		ncat = length(categorie);
			
		% chiamo la funzione che processa i nomi delle categorie
		[gruppi_cat,num_gruppi,vettore_indici] = processa_categorie(categorie,ncat);
	end
        
	
	%% preprocessing
    % se l'utente ha scelto solo la centratura o autoscaling
	if (cent_auto == 0 || cent_auto == 2)
		%mean centring
        colonnaUno = ones(ncat,1);
        mediaCentrata = mean(NUM); %vettore riga con medie
        NUM = NUM - colonnaUno*mediaCentrata; %diventa matrice
    end
                
    % se l'utente ha scelto solo la scalatura o autoscaling
    if (cent_auto == 1 || cent_auto == 2)
        %autoscaling per tutta la colonna
        colonnaUno = ones(ncat,1);
        devStandard = std(NUM);
        NUM = NUM ./ (colonnaUno*devStandard);
    end
    
    
    %% faccio scegliere all'utente quanti componenti principali vuole
    num_pc = [];
    while (isempty(num_pc) || num_pc > rank(NUM) || num_pc == 1 || length(num_pc) > 1 || num_pc < 0)
		fprintf('\nQuante componenti principali?\n');
		fprintf('-1 per lo scree plot\n-2 per cross validation\n0 per non scegliere: \n');
        num_pc = input('\nNumero componenti principali: ');
		
		% calcolo gli autovalori per lo scree plot o cross-validation eventuali
		[U,S,V] = svds(NUM,rank(NUM));
		autovalori = (diag(S).^2)./(nvar-1);
			
		%se l'utente ha scelto di vedere prima lo scree plot
		if num_pc == -1
			fprintf('\t--> Scree plot\n\n');
			
			scree_plot(rank(NUM),autovalori);
			title('Scree plot');
		end
			
		if num_pc == -2
			% cross-validation
			cvi = {'vet' (4) (2)};
	
			[press,cumpress,rmsecv,rmsec,cvpred,misclassed] = crossval(NUM,[],'pca',cvi,length(autovalori));
			title('\bfCross-validation plot');
		end
	end
		    
    
    %% metodo SVD        
    [U,S,V] = svds(NUM,num_pc);
        
    autovalori = (diag(S).^2)./(nvar-1);
    loadings = V;			
    scores = U*S;
        
    var_spiegata = 100.*(autovalori/sum(autovalori));
	
	
	%convenzione di segno sui loadings --> l'elemento più
	%grande di ogni colonna deve avere segno positivo
	[~,maxind] = max(abs(loadings), [], 1);
	[d1, d2] = size(loadings);
	colsign = sign(loadings(maxind + (0:d1:(d2-1)*d1)));
	loadings = bsxfun(@times, loadings, colsign);
	scores = bsxfun(@times, scores, colsign);
    
	
	%% calcolo della matrice dei residui
    residuals = NUM - (scores*loadings');
	
	
	model.ndata = NUM;
	model.scores = scores;
	model.loadings = loadings;
	model.varsp = var_spiegata;
	model.autovalori = autovalori;
	model.residui = residuals;
	model.variabili = variabili;
	model.categorie = categorie;
	model.allcat = class_ind_tr;
	model.indici = vettore_indici;
	model.pcs = num_pc;
	
	fprintf('\nModello creato!\n\n');
	    
end
