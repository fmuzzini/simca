function [ ] = save_images( lista_fig )
%SAVE_IMAGES salva le immagini

	scelta_fig = [];
	while (isempty(scelta_fig) || ~any(ismember(scelta_fig,['y', 'n'])))
		scelta_fig = input('vuoi salvare le immagini prodotte? "y" o "n"? ', 's');
	end
	
	if (strcmp(scelta_fig, 'y'))
		filename = input('indica il nome del file in cui salvare le immagini: ', 's');
		
		%creo cartella per memorizzare le immagini, se non esiste già
		if exist('plots') ~= 7
			mkdir('plots');
		end
		filename = strcat('.\plots\',filename);
		
		% salvo le immagini su file
		hgsave(lista_fig, filename);
	end
	
end

