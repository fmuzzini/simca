vet_cat = [];

while(true)
    fprintf('\nSoftware di classificazione SIMCA\n');
    fprintf(strcat('Categorie attualmente inserite:\t', num2str(length(vet_cat)), '\n\n'));
    disp('Operazioni disponibili:');
    
    disp('1) Aggiungi modelli categorie');
    if (length(vet_cat) > 0)
       disp('2) Analizza modello categoria');
       disp('3) Salva modelli categoria su file');
       disp('4) Classifica campioni con SIMCA');
    end
    disp('5) Esci');
    
	s1 = [];
	% se ci sono solo le opzioni 1 e 6
	if (length(vet_cat) == 0)
		while (isempty(s1) || ~any(ismember(s1,[1,5])))
			s1 = input('Inserire operazione desiderata: ');
		end
	else
		while (isempty(s1))
			s1 = input('Inserire operazione desiderata: ');
		end
	end
    
    switch(s1)
        case 1
			c = aggiungi_cat();
            vet_cat = [vet_cat c];
			continue;
            
        case 2
            disp('Categorie:');
            for i = 1:length(vet_cat)
                fprintf(strcat(num2str(i),')\t', vet_cat(i).name, '\n'));
            end
			to_an = [];
			while (isempty(to_an) || ~any(ismember(to_an,[1:length(vet_cat)])))
				to_an = input('Inserire la Categoria da analizzare: ');
			end
			
            analizza(vet_cat(to_an));
			continue;            
        case 3
            disp('Categorie:');
            for i = 1:length(vet_cat)
                fprintf(strcat(num2str(i),')\t', vet_cat(i).name, '\n'));
            end
			to_save = [];
			while (isempty(to_save) || ~any(ismember(to_save,[1:length(vet_cat)])))
				to_save = input('Inserire vettore categorie da salvare, es. [1 2 3]: ');
			end
			
            file = input('Inserire nome del file: ','s');
			vet_cat_to_save = vet_cat(to_save);
            save(file, 'vet_cat_to_save');
			continue;
            
        case 4
		
			disp('Categorie:');
            for i = 1:length(vet_cat)
                fprintf(strcat(num2str(i),')\t', vet_cat(i).name, '\n'));
            end
		
			while true
				cat = input('Indica le categorie su cui fare classificazione (Enter per tutte le categorie), es. [1 2 3]: ');
				
				if isempty(cat)
					cat = 1:length(vet_cat);
                    break;
				elseif (~any(ismember(cat,[1:length(vet_cat)])))
					disp('Errore: categorie non valide!');
				else
					break;
				end
			end
			
            simca(vet_cat(cat));
			continue;
            
        case 5
            return;
            
        otherwise
            fprintf('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!\n\n');
            continue;
            
    end
    
end

