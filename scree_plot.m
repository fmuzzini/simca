function [ fig ] = scree_plot( pcn, autovalori )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
fig = [];
fig = [fig figure()];

hold on;

% grafico autovalori vs componenti
plot([1:pcn],autovalori,'o-','MarkerSize',6,'MarkerFace','b');
xlabel('Component Number');
ylabel('Eigenvalue');

end

