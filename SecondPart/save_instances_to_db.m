function save_instances_to_db(conn, tubes)
    for j = 1:size(tubes, 1)
        id = tubes(j, 1);
        batch_id = tubes(j, 2);
        processing_time_on_welding = tubes(j, 3);
        processing_time_on_oven = tubes(j, 4);
        
        % Inserisci i dati nella tabella cutted_tubes
        sqlquery = sprintf("INSERT INTO cutted_tubes (id, processing_time_on_welding, processing_time_on_oven, batch_id) VALUES (%d, %d, %d, %d)", ...
            id, processing_time_on_welding, processing_time_on_oven, batch_id);
        execute(conn, sqlquery);
    end
end
