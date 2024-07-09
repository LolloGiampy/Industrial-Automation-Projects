function save_job_assignments_to_db(conn, ordered_instances)
    current_time = datetime('now');
    machine_id_welding = 1;
    machine_id_oven = 2;

    for i = 1:length(ordered_instances)
        tubes = ordered_instances{i};
        
        for j = 1:size(tubes, 1)
            id = tubes(j, 1);
            welding_time = tubes(j, 2);
            oven_time = tubes(j, 3);
            batch_id = tubes(j, 4);
            
            % Calcola start_time e end_time per il welding
            start_time_welding = current_time;
            end_time_welding = start_time_welding + hours(welding_time);
            
            % Inserisci il job di welding nella tabella job_assignments
            sqlquery_welding = sprintf("INSERT INTO job_assignments (tubes_id, machine_id, start_time, end_time, batch_id) VALUES (%d, %d, '%s', '%s', %d)", ...
                id, machine_id_welding, start_time_welding, end_time_welding, batch_id);
            execute(conn, sqlquery_welding);
            
            % Aggiorna current_time per il job di oven
            current_time = end_time_welding;
            start_time_oven = current_time;
            end_time_oven = start_time_oven + hours(oven_time);
            
            % Inserisci il job di oven nella tabella job_assignments
            sqlquery_oven = sprintf("INSERT INTO job_assignments (tubes_id, machine_id, start_time, end_time, batch_id) VALUES (%d, %d, '%s', '%s', %d)", ...
                id, machine_id_oven, start_time_oven, end_time_oven, batch_id);
            execute(conn, sqlquery_oven);
            
            % Aggiorna current_time per il prossimo job
            current_time = end_time_oven;
        end
    end
end
