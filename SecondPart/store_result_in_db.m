% store_results_in_db.m

function store_results_in_db(conn, schedule)
    for i = 1:size(schedule, 1)
        id = schedule(i, 1);
        machine_id = schedule(i, 2);
        tube_id = id;  % Assumendo che l'ID del tubo sia lo stesso dell'ID
        start_time = datetime('now');  % Esempio di orario di inizio
        end_time = start_time + hours(1);  % Esempio di orario di fine, da regolare secondo necessità
        
        % Inserisci i dati nella tabella jobs_assignment
        sqlquery = sprintf("INSERT INTO jobs_assignment (id, tube_id, machine_id, start_time, end_time) VALUES (%d, %d, %d, '%s', '%s')", ...
            id, tube_id, machine_id, datestr(start_time, 'yyyy-mm-dd HH:MM:SS'), datestr(end_time, 'yyyy-mm-dd HH:MM:SS'));
        exec(conn, sqlquery);
    end
end
