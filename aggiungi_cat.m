function [ vet_cat ] = aggiungi_cat()
%vet_cat Crea un vettore di modelli di categorie
%   permette di caricare un vettore da file o creare il modello partendo
%   da un set di dati

vet_cat = [];

while true

	fprintf('\nMenu aggiungi categoria\n');
	disp('1) Caricare da file');
	disp('2) Creare modello/i');
	disp('3) Torna al menu precedente');
	
	s2 = [];
	while (isempty(s2))
		s2 = input('Scegliere opzione: ');
	end

	switch(s2)
		case 1
			file = input('Nome file: ','s');
				
			% se il file non esiste
			if (exist(file,'file') == 0 || isempty(file))
				fprintf('Nome file non valido!\n\n');
			else
				tmp = load(file);
				vet_cat = tmp.vet_cat_to_save;
			end
				
			continue;
			
		case 2
			vet_cat = main_simca();
			continue;
			
		case 3
			return;
			
		otherwise
			fprintf('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!\n\n');
			continue;
	end
end

end

