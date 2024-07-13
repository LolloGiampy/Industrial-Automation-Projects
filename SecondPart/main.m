% Aggiungi il driver JDBC al java class path di Matlab
javaaddpath('C:\Users\loren\sqljdbc_12.6.3.0_ita\sqljdbc_12.6\ita\jars\mssql-jdbc-12.6.3.jre8.jar')

% Configurazione della connessione al database
driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
serverName = 'LOLLOASUS'; 
portNumber = '1433';
databaseName = 'DibrisBike';

% URL di connessione
url = sprintf('jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=false;', serverName, portNumber, databaseName);

% Configurazione della connessione al database
conn = database(databaseName,'admin', 'password456', driver, url);

% Verifica della connessione
if isopen(conn)
    disp('Connessione al database riuscita')
else
    disp('Connessione al database fallita')
    disp(conn.Message);
    return;
end
% Reset delle tabelle
execute(conn, 'BEGIN TRANSACTION;');
execute(conn, 'DELETE FROM job_assignments');
execute(conn, 'COMMIT;');

execute(conn, 'BEGIN TRANSACTION;');
execute(conn, 'DELETE FROM cutted_tubes');
execute(conn, 'COMMIT;');

% Genera istanze del problema
% num_instances = 1;
num_tubes = 6;
batch_size = 3;
tubes = generate_tubes(num_tubes, batch_size);

% Display dei tubi generati
disp('Tubes: ');
disp(tubes);

execute(conn, 'BEGIN TRANSACTION;');

% Salva le istanze nel database nella tabella "cutted_tubes"
save_instances_to_db(conn, tubes);

% Applica il johnson algorithm e salva la schedule ottima nel database
% nella tabella "job_assignments
ordered_tubes = johnson_algorithm(tubes);
save_job_assignments_to_db(conn, ordered_tubes)

execute(conn, 'COMMIT;');

% Verifica le prestazioni
total_time = verify_performance(ordered_tubes);

% Chiudi la connessione al database
close(conn);

% Mostra i risultati
fprintf('Ordered Tubes:\n');
disp(ordered_tubes);
fprintf('Total Time: %f\n', total_time);