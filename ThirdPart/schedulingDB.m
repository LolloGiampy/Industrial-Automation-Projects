function schedulingDB()
    % Aggiungi il driver JDBC al java class path di Matlab
    javaaddpath('C:\Users\loren\sqljdbc_12.6.3.0_ita\sqljdbc_12.6\ita\jars\mssql-jdbc-12.6.3.jre8.jar')
    
    % Configurazione della connessione al database
    driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
    serverName = 'LOLLOASUS'; 
    portNumber = '1433';
    databaseName = 'Scheduling';
    
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
    execute(conn, 'DELETE FROM processing_times');
    execute(conn, 'COMMIT;');

    execute(conn, 'BEGIN TRANSACTION;');
    generate_pt(conn, 10);
    execute(conn, 'COMMIT;');
    data = sqlread(conn, "processing_times");
    rows2vars(data)
   


