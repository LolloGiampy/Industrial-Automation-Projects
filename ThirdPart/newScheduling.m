% Definizione dei dati
p = [
    [5, 3, 6, 8, 4, 12, 12, 5, 3, 2],
    [12, 6, 1, 5, 6, 15, 3, 2, 8, 8],
    [1, 20, 2, 5, 7, 11, 12, 2, 5, 4],
    [13, 10, 1, 15, 6, 12, 11, 4, 4, 13],
    [2, 6, 2, 1, 5, 13, 2, 7, 18, 3]
];
n = 10;  % Numero di job
m = 5;  % Numero di macchine

% Variabili decisionali
x = zeros(m,n);  % Matrice di assegnazione (x_ij)

% Funzione obiettivo
f = sum(max(p.*x));  % Minimizzare Cmax

% Vincoli
A = zeros(3*n + 5*m, n*m);  % Matrice dei coefficienti dei vincoli
b = zeros(3*n + 5*m, 1);    % Vettore dei termini noti dei vincoli

% Vincoli di assegnazione
for j = 1:n
    A(j,:) = ones(1,n*m);
    b(j) = 1;
end

% Vincoli di sequenza
for i = 2:m
    for j = 1:n
        % Job i può iniziare solo dopo il completamento del job i-1 sulla stessa macchina
        A(n + (i-2)*n + j, m*(j-1) + i) = 1;
        A(n + (i-2)*n + j, m*(j-1) + i-1) = -1;
    end
end

% Vincoli di flusso
for j = 1:n
  

    % Option 1 (Reshape x elements)
A(2*n + j,:) = [x(1,j) x(3,j) x(5,j)];

% Option 2 (Reshape A elements)
A(2*n + j,:) = A(2*n + j, [1 3 5]);

end

% Vincoli di tempo
for i = 1:m
    for j = 1:n
        A(end + j, m*(j-1) + i) = -p(i,j);
        b(end + j) = 0;
    end
end

% Risoluzione del problema
options = optimoptions('linprog');
[xopt, fval, exitflag, info] = linprog(f, A, b, [], [], zeros(n*m,1), options);

% Visualizzazione dei risultati
Cmax = fval;
x = reshape(xopt, [m, n]);

fprintf('Tempo di completamento massimo (Cmax): %f\n', Cmax);
fprintf('Assegnazione dei job alle macchine:\n');
for i = 1:m
    for j = 1:n
        if x(i,j) > 0
            fprintf('Job %d assegnato a macchina %d\n', j, i);
        end
    end
end
