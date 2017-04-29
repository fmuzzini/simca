file = [];
modello = [];

while(true)
    fprintf('\nSoftware di Analisi PCA\n\n');
    disp('Operazioni disponibili:');
    
    disp('1) Crea modello pca su intero dataset');
	disp('2) Fai grafici');
    disp('3) Esci');
    
	s1 = [];
	while (isempty(s1))
		s1 = input('Inserire operazione desiderata: ');
	end
    
    switch(s1)
			
		case 1
			file = input('Inserire il nome del file contenente il dataset: ','s');
				
			% se il file non esiste
			if (exist(file,'file') == 0 || isempty(file))
				fprintf('Nome file non valido!\n\n');
			else
				%% come prima cosa vengono richiesti gli input dell'utente

				% centratura delle colonne, scaling o autoscaling
				cent_auto = [];
				while (isempty(cent_auto) || ~any(ismember(cent_auto,[0,1,2])))
					cent_auto = input('\nScegli 0-mean centring, 1-scaling, 2-autoscaling: ');
				end
				
				% metodo SVD
				fprintf('Tipo di algoritmo pca disponibile: svd\n');			
				
				% salvataggio immagini dei grafici
				save = [];
				while (isempty(save) || ~any(ismember(save,[0,1])))
					save = input('\nVuoi salvare le immagini prodotte? 0-no, 1-yes: ');
				end
				
				if save
					%creo cartella per memorizzare le immagini, se non esiste già
					if exist('plots') ~= 7
						mkdir('plots');
					end
				end
				
				modello = pca_algo(file,cent_auto);
			end

			continue;

		case 2
			if isempty(modello)
				fprintf('\nDevi prima creare un modello!\n\n');
			else
				pca_grafici(modello, save);
			end
			continue;
			
		case 3
			return;
			
		otherwise
			fprintf('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!\n\n');
			continue;
    end
end
