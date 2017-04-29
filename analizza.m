function [ ] = analizza( modello )

	ndata = modello.ndata;
	ndata_orig = modello.ndata_orig;
	pcn = modello.pcn;
	cat = modello.cat;
	scores = modello.scores;
	loadings = modello.loadings;
	var = modello.var;

	while true
    
    % stampa del menu
    fprintf('\n1: esegui grafico scores\n');
    disp('2: esegui grafico loadings');
    disp('3: esegui grafici validazione modello (Q e T^2)');
    disp('4: esegui contribution plot');
    disp('5: esci');
    
    scelta = [];
    while (isempty(scelta))
        scelta = input('indica il numero dell''operazione da eseguire: ');
    end
    
    switch(scelta)
        case 1
            
            % fare grafico scores
            [rig, col] = size(scores);
            
            var_x = [];
            var_y = [];
            
            while (isempty(var_x) || ~any(ismember(var_x,[1:col])) || length(var_x) > 1)
                var_x = input('indica un numero relativo alla pc1 sull asse x nello scatter plot degli scores: ');
            end
            while (isempty(var_y) || ~any(ismember(var_y,[1:col])) || length(var_y) > 1)
                var_y = input('indica un numero relativo alla pc2 sull asse y nello scatter plot degli scores: ');
            end
            
            fig_h = scatter_mod(scores, cat, [var_x var_y], false);
           
            % salvo le immagini se l'utente vuole
            save_images(fig_h);

            continue;
        case 2
           
            % fare grafico loadings
            [rig, col] = size(loadings);
            
            var_x = [];
            var_y = [];
            
            while (isempty(var_x) || ~any(ismember(var_x,[1:col])) || length(var_x) > 1)
                var_x = input('indica un numero relativo alla pc1 sull asse x nello scatter plot dei loadings: ');
            end
            while (isempty(var_y) || ~any(ismember(var_y,[1:col])) || length(var_y) > 1)
                var_y = input('indica un numero relativo alla pc2 sull asse y nello scatter plot dei loadings: ');
            end
                       
            fig_b = scatter_loadings(loadings, var, [var_x var_y]);
            
            % salvo le immagini se l'utente vuole
            save_images(fig_b);
            
            continue;
        case 3            
            % q e tquadro
            [fig_q_tquadro q tquadro] = compute_q_tquadro(modello, cat, true);
            
            % salvo le immagini se l'utente vuole
            save_images(fig_q_tquadro);
            
            continue;
        case 4
            % faccio contribution plot
            
            sample = [];
            while (isempty(sample) || ~any(ismember(sample,[1:length(q)])))
                sample = input('indica il numero del campione per cui fare il contribution plot: ');
            end
            fig_cont = contribution_plot(var, sample, modello, ndata);
            
            % salvo le immagini se l'utente vuole
            save_images(fig_cont);
            
            continue;
        case 5
            return;
			
        otherwise
			fprintf('ATTENZIONE: devi indicare un numero rappresentante le opzioni disponibili!\n\n');
            continue;
    end

end