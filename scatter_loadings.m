function [ fig ] = scatter_loadings( loadings, var, pca_scelte )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fig = [];
fig = [fig figure()];

hold on;

% plotto i loadings
[rig col] = size(loadings);
for i=1:rig
    plot([0 loadings(i,pca_scelte(1))], [0 loadings(i,pca_scelte(2))]);
    t = text(loadings(i, pca_scelte(1)), loadings(i, pca_scelte(2)), var(i));
    set(t,'HorizontalAlignment','left','VerticalAlignment','bottom');
	
	% per disegnare la freccia
    quiver(0,0,loadings(i,pca_scelte(1)),loadings(i,pca_scelte(2)),'k');
end

% disegno l'asse x e y
xL = xlim;
yL = ylim;
line([0 0], yL,'LineStyle','--');  %x-axis
line(xL, [0 0],'LineStyle','--');  %y-axis

title(['Loadings PC', num2str(pca_scelte(1)), ' VS PC', num2str(pca_scelte(2))]);
xlabel(['PC', num2str(pca_scelte(1))]);
ylabel(['PC', num2str(pca_scelte(2))]);

hold off;

end

