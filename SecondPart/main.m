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

execute(conn, 'BEGIN TRANSACTION;');
execute(conn, 'DELETE FROM cutted_tubes');
execute(conn, 'DELETE FROM job_assignments');
execute(conn, 'COMMIT;');

% Genera istanze del problema
num_instances = 3;
num_tubes = 10;
max_batch_size = 5;
instances = generate_instances(num_instances, num_tubes, max_batch_size);

execute(conn, 'BEGIN TRANSACTION;');

% Salva le istanze nel database
save_instances_to_db(conn, instances);

% Applica il johnson algorithm e salva la schedule ottima nel database
ordered_instances = johnson_algorithm(instances);
store_result_in_db(conn, ordered_instances,  batch_id)

execute(conn, 'COMMIT;');

% Verifica le prestazioni
% verify_performance(conn);

% Chiudi la connessione al database
close(conn);
