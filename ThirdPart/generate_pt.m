function generate_pt(conn, num_jobs)
    pts = zeros(6, num_jobs); 
    pts(1,:) =1:num_jobs;
    for job = 1:(num_jobs)
        for machine = 2:6
            processing_time = randi([1, 20]);
            pts(machine,job) = processing_time;
        end
    end
    pts = pts.'
    for job = 1:(num_jobs)
        id = job;
        sqlquery = sprintf("INSERT INTO processing_times (id, machine_1, machine_2, machine_3, machine_4, machine_5) VALUES (%d, %d, %d, %d, %d, %d)", ...
            id, pts(job,2),pts(job,3),pts(job,4),pts(job,5),pts(job,6));
        execute(conn, sqlquery);
        
    end
end