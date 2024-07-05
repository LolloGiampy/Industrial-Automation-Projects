% johnsons_algorithm.m

function schedule = johnsons_algorithm(tubes)
    n = size(tubes, 1);  % Numero di tubi
    schedule = zeros(n, 2);  % Inizializza la matrice del programma
    left = 1;  % Puntatore sinistro per la schedulazione
    right = n;  % Puntatore destro per la schedulazione

    % Ordina i tubi
    for i = 1:n
        if tubes(i, 2) <= tubes(i, 3)  % Confronta i tempi di saldatura con i tempi di forno
            schedule(left, :) = [tubes(i, 1), 1];  % Assegna prima alla saldatura
            left = left + 1;
        else
            schedule(right, :) = [tubes(i, 1), 2];  % Assegna prima al forno
            right = right - 1;
        end
    end
end
