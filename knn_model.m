% training=data_tr, test=data_ts

file = input('Inserire nome file: ', 's');

while (exist(file,'file') == 0 || isempty(file))
    fprintf('Nome file non valido!\n\n');
    file = input('Inserire nome file: ', 's');
end

model = load(file);
data_tr = model.data_tr;
data_ts = model.data_ts;
class_ind_tr = model.class_ind_tr;
class_ind_ts = model.class_ind_ts;

cat = unique(class_ind_tr);

[tr_n tr_m] = size(data_tr);
[ts_n ts_m] = size(data_ts);
%Y = cell(tr_n,1);
%Y = repmat('',1,tr_n);		% array of char vectors(empty)




while true
	select_k = input('\nVuoi scegliere un numero di vicini k? "y" o "n"? ', 's');
			
	if strcmp(select_k,'y')
		while true
			%variabile che registra la scelta dell'utente
			k = input('\nSeleziona numero di vicini: ');
			
			%finchè non viene scelto niente, dai errore
			if isempty(k)
				fprintf('\t\tErrore: devi scegliere un numero!\n\n');
				
			%se è stata fatta una scelta non accettabile
			elseif k > tr_n
				fprintf(strcat('\t\tErrore: numero inserito non valido! I vicini possono essere massimo ', tr_n, ' \n\n'));
			
			%se non ci sono stati errori, ferma il ciclo
			%(dati inseriti correttamente)
			else
				break;
			end
		end
		break;
    elseif strcmp(select_k,'n')
        break;
    else
		fprintf('\t\tErrore: devi selezionare "y" o "n"!\n\n');
	end
end

%funzione matlab
mdl = fitcknn(data_tr, class_ind_tr);

if strcmp(select_k,'y')
	mdl.NumNeighbors = k;
end

res = predict(mdl, data_ts);

ner = non_error_rate(res', class_ind_ts, unique(class_ind_ts));

disp({'NER% tot: ', sum(ner)/length(cat)});
for i = cat
    disp({'cat ', i, 'NER%: ', ner(i)});
end


