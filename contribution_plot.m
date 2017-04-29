function [ fig ] = contribution_plot( var, sample, model, ndata)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fig = [];
fig = [fig figure];

 
% contribution plot per tquadro
subplot(2,1,1);
rig_score = model.scores(sample, :);
rig_ndata = ndata(sample, :);

cont_t = [];
for i=1:length(var)
   cont_t(i) = rig_score*diag(model.autovalori.^(-1/2))*rig_ndata(i)*model.loadings(i,:)'; 
end
bar(cont_t, 'histc');
xticks((1:length(var)) + 0.5);
xticklabels(var);
set(gca, 'XTickLabelRotation', 90);

title(['Contribution plot del campione ', num2str(sample)]);
xlabel('Variabili');
ylabel('contributi di T^2');
hold on;

% contribution plot per q
subplot(2,1,2);
bar(model.residui(sample, :).^2, 'histc');
xticks((1:length(var)) + 0.5);
xticklabels(var);
set(gca, 'XTickLabelRotation', 90);

title(['Contribution plot del campione ', num2str(sample)]);
xlabel('Variabili');
ylabel('contributi di Q');

hold off;

end

