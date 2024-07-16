function generate_pt(num_jobs)
    pts = zeros(6, num_jobs); 
    pts(1,:) =1:num_jobs;
    for job = 1:(num_jobs)
        for machine = 2:6
            processing_time = randi([1, 20]);
            pts(machine,job) = processing_time;
        end
    end
  
    pts.'
