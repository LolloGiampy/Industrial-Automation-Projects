function pts = generate_pt(num_jobs)
    pts = zeros(num_jobs, 5); % Columns: [id, machine_1, machine_2, machine_3, machine_4, machine_5]
    pts(1) = [];
    for i = 1:num_jobs
        processing_time = randi([1, 20]);
        for j = 1:5
            machine_id = j;
            pts(machine_id,i) = [i, machine_id, processing_time];
        end
    end
