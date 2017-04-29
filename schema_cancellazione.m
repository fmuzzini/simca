function [ vect_ind, ndata_solo_i] = schema_cancellazione(ndata, alg, splits, start)
% funzione che individua, in base allo schema di cancellazione, i campioni da predirre

% parametri input: 
%             - matrice dei dati su cui applicare lo schema di cancellazione
%             - tipo di schema di cancellazione (1: loo, 2:vb)
%             - ogni quanti campioni estraggo un campione
%			  - punto di partenza da cui eliminare i campioni, per cambiare cancellazione ad ogni chiamata
%   parametri output:
%             - vettore utilizzato per filtrare la matrice di partenza per individuare i campioni da eliminare
%             - matrice/riga dei campioni eliminati
            
    [rig_ndata col_ndata] = size(ndata);
	vect_ind = zeros(1,rig_ndata);

	% vale per alg 1 e 2
	start = mod(start,rig_ndata);
	if start == 0
		start = rig_ndata;
	end
		
    if (alg == 1)                                	% leave one out 
        vect_ind(start) = 1;                        % vettore di indice con 1 nella riga da togliere
    elseif (alg == 2)                            	% venetian blind		
        for k=start:splits:rig_ndata
            vect_ind(k) = 1;
        end
	end

    ndata_solo_i = ndata(vect_ind == 1, :);           % matrice dei soli campioni tolti

end