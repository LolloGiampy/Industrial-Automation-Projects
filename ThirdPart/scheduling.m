% Definire la matrice dei tempi di lavorazione
processing_times = [
    5, 3, 6, 8, 4, 12, 12, 5, 3, 2;
    12, 6, 1, 5, 6, 15, 3, 2, 8, 8;
    1, 20, 2, 5, 7, 11, 12, 2, 5, 4;
    13, 10, 1, 15, 6, 12, 11, 4, 4, 13;
    2, 6, 2, 1, 5, 13, 2, 7, 18, 3
];

% Numero di lavori e macchine
[num_machines, num_jobs] = size(processing_times);

% Inizializzazione delle sequenze ottimali
sequence = 1:num_jobs;

% Calcolo del makespan (Cmax)
current_time = zeros(num_machines, 1);
for job = sequence
    current_time(1) = current_time(1) + processing_times(1, job);
    for machine = 2:num_machines
        current_time(machine) = max(current_time(machine), current_time(machine-1)) + processing_times(machine, job);
    end
end

Cmax = current_time(end);

% Output
fprintf('La sequenza ottimale dei lavori è:\n');
disp(sequence);
fprintf('Il makespan (Cmax) è: %d\n', Cmax);
