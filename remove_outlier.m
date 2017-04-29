function [ ndata_no_outliers ] = remove_outlier( model, ndata, index, q, tquadro, cat )

% rimozione outlier/s

fprintf('\n...Eliminazione outlier...\n');

%% elimino da Q e T2 -> per fare vedere il nuovo grafico subito (l'utente ha un riscontro immediato)
for indx=1:length(index)
	if index(indx) > 1
		q = [ q(1:index(indx)-1) q(index(indx)+1:length(q)) ];
		tquadro = [ tquadro(1:index(indx)-1) tquadro(index(indx)+1:length(tquadro)) ];
	else		% se l'indice da rimuovere è 1, parto da 2
		q = q(index(indx)+1:length(q));
		tquadro = tquadro(index(indx)+1:length(tquadro));
	end
end

	
% disegno grafico tquadro vs q
mat_t_q = [tquadro; q]';
scatter_mod(mat_t_q, cat, [1 2], true);
            
title('T^2 VS Q (outliers removed)');
xlabel('T^2');
ylabel('Q');
            
% disegno l'asse x e y
xL = xlim;
yL = ylim;
line([0 0], yL,'LineStyle','--');  %x-axis
line(xL, [0 0],'LineStyle','--');  %y-axis
           			
	
%% faccio passaggi inversi per risalire alla matrice dei dati (senza outlier rimosso)
res = model.residui;
scores_loadings = model.scores*model.loadings';

% elimino da residuals e da matrice scores*loadings'

for i=1:length(index)
	[n m] = size(res);
    if index(i) > 1
		res = [res(1:index(i)-1,:) ; res(index(i)+1:n,:)];
		scores_loadings = [scores_loadings(1:index(i)-1,:) ; scores_loadings(index(i)+1:n,:)];
	else
		res = res(index(i)+1:n,:);
		scores_loadings(index(i)+1:n,:);
	end
end

% ottengo matrice prima di svd (dopo preprocessing)
ndata_no_outliers = res + scores_loadings;

end
