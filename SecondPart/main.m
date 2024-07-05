% main.m

% Connessione al database
conn = database('DibrisBike', 'username', 'password', 'Vendor', 'Microsoft SQL Server', 'Server', 'LOLLOASUS');

% Genera istanze del problema
num_instances = 10;
num_tubes = 5;
instances = generate_instances(num_instances, num_tubes);

% Processa ogni istanza e memorizza i risultati nel database
for i = 1:num_instances
    tubes = instances{i};
    schedule = johnsons_algorithm(tubes);
    store_results_in_db(conn, schedule);
end

% Verifica le prestazioni
verify_performance(conn);

% Chiudi la connessione al database
close(conn);
