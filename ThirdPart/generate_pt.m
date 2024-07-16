function pts = generate_pt(num_jobs)
    pts = zeros(6, num_jobs+1); 
    pts(1,:) =0:num_jobs;
    pts(:,1) =0:5;
    for job = 2:(num_jobs+1)
        for machine = 2:6
            processing_time = randi([1, 20]);
            pts(machine,job) = processing_time;
        end
    end
    pts
    pts_cutted=pts(2:end,2:end)
