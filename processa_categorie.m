function [gruppi_cat,num_gruppi,vettore_indici] = processa_categorie(categorie,ncat)

    %creo vettore colonna vuoto per i nomi delle categorie senza numeri
    newcategorie = cell(length(categorie),1);
        
    %pulizia colonna categorie (tolgo i numeri dai nomi)
    for c=1:ncat
            
        %indice per assegnare le lettere trovate alla variabile newname
        lettere = 1;
        %variabile che conterrà il nuovo nome senza numeri (ora vuota)
        newname = blanks(length(categorie(c)));
            
        %acquisisco il nome come stringa
        cat = categorie{c};
        %per tutta la lunghezza del nome
        for index=1:length(cat)
            %per ogni indice, cerco solo le lettere
            if isletter(cat(index))
                %assegno le lettere trovate ad una variabile
                newname(lettere) = cat(index);
            end
            %incremento l'indice per newname
            lettere = lettere + 1;
        end
            
        %inserisco il nuovo nome nella nuova colonna di nomi
        newcategorie{c} = newname;
    end
        
    %nomi delle categorie raggruppati (nomi uguali insieme)
    %il vettore potrebbe non riempirsi (la lunghezza assegnata è
    %per eccesso)
    gruppi_cat = cell(length(categorie),1);
    %indice per numero di gruppi di categorie trovati
    num_gruppi = 0;
        
    %inserisco primo gruppo (primo nome della colonna newcategorie)
    gruppi_cat{num_gruppi+1} = newcategorie{1};
    num_gruppi = num_gruppi+1;
        
    %scorro gli altri per trovare i gruppi diversi da quello già messo
    for cat=2:ncat
        %cerco nel vettore gruppi se esiste già il nome considerato
        %any dà 1 se esiste già il nome (entro nell'if se non esiste)
        if ~any(strcmp(newcategorie(cat),gruppi_cat))
            %aggiungo il nome (lavoro con stringhe)
            gruppi_cat{num_gruppi+1} = newcategorie{cat};
            num_gruppi = num_gruppi+1;
        end
    end
        
    %matrice con una colonna per gruppo, ogni colonna avrà gli indici
    %delle categorie che fanno parte di quel gruppo
    vettore_indici = zeros(ncat,num_gruppi);
        
    %per ogni gruppo, riempio una colonna di vettore_indici
    for v=1:num_gruppi
        %trovo quante categorie ne fanno parte (nomi uguali)
        num = length(find(strcmp(gruppi_cat(v),newcategorie)));
        %trovo gli indici delle categorie (uso num per vettore_indici)
        vettore_indici(1:num,v) = find(strcmp(gruppi_cat(v),newcategorie));
    end

end
