function total_time = verify_performance(ordered_jobs)
    num_jobs = size(ordered_jobs, 1);

    % Inizializzazione dei tempi di fine per le macchine
    welding_end_time = 0;
    oven_end_time = 0;

    % Itera attraverso i job ordinati per calcolare i tempi totali
    for i = 1:num_jobs
        welding_time = ordered_jobs(i, 2);
        oven_time = ordered_jobs(i, 3);

        % Il job sulla macchina di welding inizia quando la macchina di welding è disponibile
        welding_start_time = welding_end_time;
        welding_end_time = welding_start_time + welding_time;

        % Il job sulla macchina di oven inizia quando la macchina di oven è disponibile e il job di welding è completato
        oven_start_time = max(oven_end_time, welding_end_time);
        oven_end_time = oven_start_time + oven_time;
    end

    % Il tempo totale è determinato dal tempo di fine della macchina di oven
    total_time = oven_end_time;
end
