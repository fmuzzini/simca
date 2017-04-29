function [  ] = pca_grafici( model, save )

	ndata = model.ndata;
	scores = model.scores;
	loadings = model.loadings;
	autovalori = model.autovalori;
	residuals = model.residui;
	variabili = model.variabili;
	categorie = model.categorie;
	allcat = model.allcat;
	vettore_indici = model.indici;
	num_pc = model.pcs;
	
	ncat = length(categorie);
	usercat = [1:ncat];
	gruppi_cat = categorie;
	
loop = 0;
while true
	if loop > 0
		%matrice con una colonna per categoria, ogni colonna avrà gli indici
		%dei campioni (righe) che fanno parte di quella categoria
		vettore_indici = zeros(length(allcat)-1,ncat);
			
		%per ogni categoria, riempio una colonna di vettore_indici
		for v=1:ncat
			% prendo pezzo di matrice di una categoria (indici)
			righe = find(allcat == v);
			%trovo quanti campioni ne fanno parte (nomi uguali)
			num = length(righe);
			%trovo gli indici delle categorie (uso num per vettore_indici)
			vettore_indici(1:num,v) = righe;
		end
	end

	%% scree plot (con solo le componenti scelte)
    scree_plot(num_pc,autovalori);
    title('\bfScree plot with selected pcas');
	

	%% per score e loadings plot, chiedo quali pc graficare
    fprintf('\tComponenti principali disponibili: [');
    for pc=1:num_pc
        fprintf('%d ',pc);
    end
    fprintf(']\n');
	
	pc_plot = [];
	while (isempty(pc_plot) || ~any(ismember(pc_plot,[1:num_pc])) || length(pc_plot) > 2 || length(pc_plot) < 2)
		pc_plot = input('\nScegli 2 pc per graficare scores e loadings (es. [1 2]): ');
	end           
	
            
	cmap = hsv(40);
	num = randint(1,1,[1 40]);
	random = [num];
	for r=1:length(usercat)
		while ismember(num,random)
			num = randint(1,1,[1 40]);
		end
		random = [random num];
	end
    %% score plot

    figure;
	ind = 0;
	for scelta=1:length(usercat)
					
		%per ogni giro, prendo gli indici di riga corrispondenti
		%alle categorie scelte ( mi serve sapere solo quanti sono)
		effettivi = length(find(vettore_indici(:,usercat(scelta)) ~= 0));
		indici_graf = vettore_indici(1:effettivi,usercat(scelta));
						
		valori_score1 = scores([ind+1:length(indici_graf)+ind],pc_plot(1));
		valori_score2 = scores([ind+1:length(indici_graf)+ind],pc_plot(2));
						
		hold on;
		h(scelta) = plot(valori_score1,valori_score2,'.','Color',cmap(random(scelta),:));
						
		legendInfo{scelta} = [num2str(gruppi_cat(usercat(scelta)))];
						
		ind = ind + length(indici_graf);
	end
		
	% disegno l'asse x e y
	xL = xlim;
	yL = ylim;
	line([0 0], yL,'LineStyle','--');  %x-axis
	line(xL, [0 0],'LineStyle','--');  %y-axis
					
	grid on;					
	title('\bfScore plot');
	xlabel(['\bfPC',num2str(pc_plot(1))]);
	ylabel(['\bfPC',num2str(pc_plot(2))]);
		
	legend(h,legendInfo);
	
	if save
		%salvo plot
		print('.\plots\scores','-dpng');
	end
		

    %% loadings plot
    figure;
    plot(loadings(:,pc_plot(1)),loadings(:,pc_plot(2)),'k.');
	%metto etichette con nomi delle variabili
	text(loadings(:,pc_plot(1))+0.01,loadings(:,pc_plot(2))+0.01,variabili);
                    
    [n m] = size(loadings);
    for lo=1:n
		hold on;
		%per disegnare la freccia
        quiver(0,0,loadings(lo,pc_plot(1)),loadings(lo,pc_plot(2)),'k');
    end
				
	% disegno l'asse x e y
	xL = xlim;
	yL = ylim;
	line([0 0], yL,'LineStyle','--');  %x-axis
	line(xL, [0 0],'LineStyle','--');  %y-axis
					
    grid on;
    title('\bfLoadings plot');
    xlabel(['\bfPC',num2str(pc_plot(1))]);
	ylabel(['\bfPC',num2str(pc_plot(2))]);
	
	if save
		%salvo plot
		print('.\plots\loadings','-dpng');
	end


    %% biplot
    figure;
    biplot(loadings(:,[pc_plot(1) pc_plot(2)]),'scores',scores(:,[pc_plot(1) pc_plot(2)]),'varlabels',variabili);
    title('\bfBiplot');
    xlabel(['\bfPC',num2str(pc_plot(1))]);
	ylabel(['\bfPC',num2str(pc_plot(2))]);
                    
	if save
		%salvo plot
		print('.\plots\biplot','-dpng');
	end

            
    %% plot residui
    figure;
	plot(residuals,'.');
	a = axis;
	hold on;
	plot(a(1:2),[0,0],'g-');
			
    title('\bfResiduals plot');
	xlabel('\bfSamples');
	ylabel(strcat('\bfResiduals after ',num2str(num_pc),' pcs'));
			
	if save
		%salvo plot
		print('.\plots\residuals','-dpng');
	end
            
            
    %% plot Q e T^2
    [rig col] = size(scores);
	Q = diag(residuals*residuals');
    T2 = diag(scores*inv(diag(autovalori))*scores');
			
	% livello di confidenza al 95%
	[reslim,s] = residuallimit(residuals,0.95);
	%tlim = tsqlim(rig,col,0.95);

	figure;				
		
	%plot semplice
	subplot(2,2,1);
	ind = 0;
	for scelta=1:length(usercat)
					
		effettivi = length(find(vettore_indici(:,usercat(scelta)) ~= 0));
		indici_graf = vettore_indici(1:effettivi,usercat(scelta));
					
		hold on;
		%disegno in corrispondenza degli indici delle righe scelte (asse x)
		h(scelta) = plot([ind+1:length(indici_graf)+ind],Q([ind+1:length(indici_graf)+ind]),'Color',cmap(random(scelta),:));
					
		title('\bfQ');
		ylabel('\bfQ values');
		legendInfo{scelta} = [num2str(gruppi_cat(usercat(scelta)))];
			
		ind = ind + length(indici_graf);
	end
	a = axis;
	hold on;
	h(length(usercat)+1) = plot(a(1:2),[reslim,reslim],'r');
	legendInfo{length(usercat)+1} = ['95% confidence level'];
				
	l = legend(h,legendInfo);
	set(l,'FontSize',7);
				
	%plot con numeri di indice (righe scelte per categoria)
	subplot(2,2,3);
	ind = 0;
	for scelta=1:length(usercat)
				
		effettivi = length(find(vettore_indici(:,usercat(scelta)) ~= 0));
		indici_graf = vettore_indici(1:effettivi,usercat(scelta));
					
		for q=ind+1:length(indici_graf)+ind
			hold on;
			h(scelta) = plot(q,Q(q),'Color',cmap(random(scelta),:));
			%etichetta
			text(q,Q(q),num2str(q));
		end
		hold on;
		h(scelta) = plot([ind+1:length(indici_graf)+ind],Q([ind+1:length(indici_graf)+ind]),'Color',cmap(random(scelta),:));
					
		title('\bfQ (with indices)');
		ylabel('\bfQ values');
		legendInfo{scelta} = [num2str(gruppi_cat(usercat(scelta)))];
					
		ind = ind + length(indici_graf);
	end
	a = axis;
	hold on;
	h(length(usercat)+1) = plot(a(1:2),[reslim,reslim],'r');
	legendInfo{length(usercat)+1} = ['95% confidence level'];
				
	l = legend(h,legendInfo);
	set(l,'FontSize',7);
					
					
	%stessa cosa per i grafici di T2				
	subplot(2,2,2);
	ind = 0;
	for scelta=1:length(usercat)
				
		effettivi = length(find(vettore_indici(:,usercat(scelta)) ~= 0));
		indici_graf = vettore_indici(1:effettivi,usercat(scelta));
				
		hold on;
		h(scelta) = plot([ind+1:length(indici_graf)+ind],T2([ind+1:length(indici_graf)+ind]),'Color',cmap(random(scelta),:));
					
		title('\bfT^2');
		ylabel('\bfT^2 values');
		legendInfo{scelta} = [num2str(gruppi_cat(usercat(scelta)))];
					
		ind = ind + length(indici_graf);
	end
	%a = axis;
	%hold on;
	h(length(usercat)+1) = [];%plot(a(1:2),[tlim,tlim],'g');
	%legendInfo{length(usercat)+1} = char({'Hotelling T^2', 'confidence limit'});
				
	l = legend(h,legendInfo);
	set(l,'FontSize',7);
					
	subplot(2,2,4);
	ind = 0;
	for scelta=1:length(usercat)
			
		effettivi = length(find(vettore_indici(:,usercat(scelta)) ~= 0));
		indici_graf = vettore_indici(1:effettivi,usercat(scelta));
				
		for t=ind+1:length(indici_graf)+ind
			hold on;
			h(scelta) = plot(t,T2(t),'Color',cmap(random(scelta),:));
			%etichetta
			text(t,T2(t),num2str(t));
		end
		hold on;
		h(scelta) = plot([ind+1:length(indici_graf)+ind],T2([ind+1:length(indici_graf)+ind]),'Color',cmap(random(scelta),:));
					
		title('\bfT^2 (with indices)');
		ylabel('\bfT^2 values');
		legendInfo{scelta} = [num2str(gruppi_cat(usercat(scelta)))];
					
		ind = ind + length(indici_graf);
	end
	%a = axis;
	%hold on;
	%h(length(usercat)+1) = plot(a(1:2),[tlim,tlim],'g');
	%legendInfo{length(usercat)+1} = char({'Hotelling T^2', 'confidence limit'});
				
	l = legend(h,legendInfo);
	set(l,'FontSize',7);
					
	if save
		%salvo plot
		print('.\plots\Q_T2_plots','-dpng');
	end
			            
            
    %% Q vs T^2 plot
    figure;
	legendInfo = [];
			
	subplot(1,2,1);
	ind = 0;
	for scelta=1:length(usercat)
				
		effettivi = length(find(vettore_indici(:,usercat(scelta)) ~= 0));
		indici_graf = vettore_indici(1:effettivi,usercat(scelta));
				
		hold on;
		h(scelta) = plot(T2([ind+1:length(indici_graf)+ind]),Q([ind+1:length(indici_graf)+ind]),'.','Color',cmap(random(scelta),:));
					
		title('\bfQ vs T^2');
		xlabel('\bfHotelling T^2');
		ylabel('\bfQ residuals');
		legendInfo{scelta} = [num2str(gruppi_cat(usercat(scelta)))];
					
		ind = ind + length(indici_graf);
	end
	%a = axis;
	%y1=get(gca,'ylim');
	%hold on;
	%plot(a(1:2),[reslim,reslim],'r--');
	%plot([tlim,tlim],y1,'g--');
	
	legend(h,legendInfo);
					
	subplot(1,2,2);
	ind = 0;
	for scelta=1:length(usercat)
					
		effettivi = length(find(vettore_indici(:,usercat(scelta)) ~= 0));
		indici_graf = vettore_indici(1:effettivi,usercat(scelta));
		
		for v=ind+1:length(indici_graf)+ind
			hold on;
			h(scelta) = plot(T2(v),Q(v),'.','Color',cmap(random(scelta),:));
			%etichetta
			text(T2(v),Q(v),num2str(v));
		end
		title('\bfQ vs T^2 (with indices)');
		xlabel('\bfHotelling T^2');
		ylabel('\bfQ residuals');
		legendInfo{scelta} = [num2str(gruppi_cat(usercat(scelta)))];
					
		ind = ind + length(indici_graf);
	end
	%a = axis;
	%y1=get(gca,'ylim');
	%hold on;
	%plot(a(1:2),[reslim,reslim],'r--');
	%plot([tlim,tlim],y1,'g--');
	
	legend(h,legendInfo);
				
	if save
		%salvo plot
		print('.\plots\QvsT2_plot','-dpng');
	end

            
    %% contribution plot
	cp = [];
	while (isempty(cp) || ~any(ismember(cp,[0,1])))
		cp = input('Vuoi vedere il contribution plot di un campione? 0-no, 1-yes: ');
	end
	
	if cp
		% chiedo all'utente di scegliere un componente per il contribution plot
		index = [];
        while (isempty(index) || ~any(ismember(index,[1:length(Q)])) || length(index) > 1)
            index = input('\nYour choice: ');
		end
		
		% contribution plot per tquadro
		figure;
		subplot(2,1,1);
		rig_score = scores(index, :);
		rig_ndata = ndata(index, :);

		cont_t = [];
		for i=1:length(variabili)
			cont_t(i) = rig_score*diag(autovalori.^(-1/2))*rig_ndata(i)*loadings(i,:)'; 
		end
		bar(cont_t, 'histc');
		xticks((1:length(variabili)) + 0.5);
		xticklabels(variabili);
		set(gca, 'XTickLabelRotation', 90);

		title(['Contribution plot del campione ', num2str(index)]);
		xlabel('Variabili');
		ylabel('contributi di T^2');
		hold on;

		% contribution plot per q
		subplot(2,1,2);
		bar(residui(index, :).^2, 'histc');
		xticks((1:length(variabili)) + 0.5);
		xticklabels(variabili);
		set(gca, 'XTickLabelRotation', 90);

		title(['Contribution plot del campione ', num2str(index)]);
		xlabel('Variabili');
		ylabel('contributi di Q');
			
		if save
			%salvo plot
			print('.\plots\contribution_plot','-dpng');
		end
			
	end
	
	
	%% rimozione di un campione anomalo
	rm = [];
	while (isempty(rm) || ~any(ismember(rm,[0,1])))
		rm = input('Vuoi rimuovere un campione anomalo? 0-no, 1-yes: ');
	end
	
	if rm
		% chiedo all'utente di scegliere un componente da rimuovere
		ind = [];
        while (isempty(ind) || ~any(ismember(ind,[1:length(Q)])) || length(ind) > 1)
            ind = input('\nYour choice: ');
		end
		
		%% faccio passaggi inversi per risalire alla matrice dei dati (senza outlier rimosso)
		res = residuals;
		scores_loadings = scores*loadings';

		% elimino da residuals e da matrice scores*loadings'
		[n m] = size(res);
		for i=1:length(ind)
			if ind(i) > 1
				res = [res(1:ind(i)-1,:) ; res(ind(i)+1:n,:)];
				scores_loadings = [scores_loadings(1:ind(i)-1,:) ; scores_loadings(ind(i)+1:n,:)];
				allcat = [allcat(1:ind(i)-1) allcat(ind(i)+1:length(allcat))];
			else
				res = res(ind(i)+1:n,:);
				scores_loadings(ind(i)+1:n,:);
				allcat = allcat(ind(i)+1:length(allcat));
			end
		end

		% ottengo matrice prima di svd (dopo preprocessing)
		ndata_no_outliers = res + scores_loadings;
		NUM = ndata_no_outliers;
		
		% metodo SVD        
		[U,S,V] = svds(NUM,num_pc);
			
		nvar = length(variabili);
		autovalori = (diag(S).^2)./(nvar-1);
		loadings = V;			
		scores = U*S;
					
		%convenzione di segno sui loadings --> l'elemento più
		%grande di ogni colonna deve avere segno positivo
		[~,maxind] = max(abs(loadings), [], 1);
		[d1, d2] = size(loadings);
		colsign = sign(loadings(maxind + (0:d1:(d2-1)*d1)));
		loadings = bsxfun(@times, loadings, colsign);
		scores = bsxfun(@times, scores, colsign);
		
		% calcolo della matrice dei residui
		residuals = NUM - (scores*loadings');
		
		loop = loop+1;
	else
		break;
	end
	
end
	
end