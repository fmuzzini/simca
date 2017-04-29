function [ fig ] = scatter_mod(ndata, cat, var_scelte, flag )
%SCATTER_MOD disegna lo score plot delle variabili scelte
fig = [];
fig = [fig figure()];

[rig_ndata col_ndata] = size(ndata);

pc1 = ndata(:,var_scelte(1));
pc2 = ndata(:,var_scelte(2));
	
h(1) = plot(pc1,pc2,'.','Color','b');
hold on;
legendInfo{1} = [num2str(cat)];
		                       
if (flag)   % se devo scrivere i numeri dei campioni sui cerchi
	for r=1:rig_ndata
		text(pc1(r), pc2(r), num2str(r));
	end
end

% disegno l'asse x e y
xL = xlim;
yL = ylim;
line([0 0], yL,'LineStyle','--');  %x-axis
line(xL, [0 0],'LineStyle','--');  %y-axis

title(['Scores plot PC', num2str(var_scelte(1)), ' VS PC', num2str(var_scelte(2))]);
xlabel(['Scores on PC', num2str(var_scelte(1))]);
ylabel(['Scores on PC', num2str(var_scelte(2))]);

legend(h,legendInfo);
hold off;

end

