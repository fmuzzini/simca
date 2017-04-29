function [ fig q tquadro] = compute_q_tquadro (model, cat, flag )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fig = [];
fig = [fig figure()];
                        
            [rig_res col_res] = size(model.residui);
            % calcolo i residui q
            q = [];
            for i=1:rig_res
                q = [q model.residui(i,:)*model.residui(i,:)'];
            end
            
            % li plotto con il limite di confidenza
            subplot(3,1,1);
            plot(q);
            text(1:rig_res, q, num2str([1:rig_res]'));
            h_limit = residuallimit(model.residui);
            line([1 rig_res], [h_limit h_limit], 'color', 'r');
            title('valori Q dei campioni');
            ylabel('Q');
            xlabel('Campioni');
            
            hold on;
            
           
            % calcolo i residui T^2
            subplot(3,1,2);
            tquadro = [];
            [rig_score col_score] = size(model.scores);
            for i=1:rig_score
               tquadro = [tquadro model.scores(i,:)*diag(model.autovalori)^-1*model.scores(i,:)']; 
            end
            
            % li plotto con il limite di confidenza
            plot(tquadro);
            text(1:rig_score, tquadro, num2str([1:rig_score]'));
            h_tquadro = tsqlim(rig_score, col_score, 0.95);
            line([1 rig_score], [h_tquadro h_tquadro], 'color', 'r');
            title('valori T^2 dei campioni');
            ylabel('T^2');
            xlabel('Campioni');
            
            %residual plot
            subplot(3,1,3);
            plot(model.residui);
            title('Residual plot');
            ylabel('Residui');
            xlabel('Campioni');

            mat_t_q = [tquadro; q]';
            scatter_mod(mat_t_q, cat, [1 2], flag);
            
            title('T^2 VS Q');
            xlabel('T^2');
            ylabel('Q');
            
			a = axis;
			y1=get(gca,'ylim');
			hold on;
			plot(a(1:2),[h_limit,h_limit],'r--');
			plot([h_tquadro,h_tquadro],y1,'r--');
            
            % disegno l'asse x e y
            xL = xlim;
            yL = ylim;
            line([0 0], yL,'LineStyle','--');  %x-axis
            line(xL, [0 0],'LineStyle','--');  %y-axis
            
            hold off;


end

