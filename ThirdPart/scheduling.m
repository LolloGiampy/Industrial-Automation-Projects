function optimize_job_scheduling()
    % Job processing times
    processing_times = [
        5, 3, 6, 8, 4, 12, 12, 5, 3, 2;    % M1
        12, 6, 1, 5, 6, 15, 3, 2, 8, 8;    % M2
        1, 20, 2, 5, 7, 11, 12, 2, 5, 4;   % M3
        13, 10, 1, 15, 6, 12, 11, 4, 4, 13;% M4
        2, 6, 2, 1, 5, 13, 2, 7, 18, 3     % M5
    ];

    % Number of jobs and machines
    num_jobs = size(processing_times, 2);

    % Decision variables: x(i,j) = 1 if job j is assigned to path i, 0 otherwise
    % Path 1: M1 -> M3 -> M5
    % Path 2: M2 -> M4 -> M5

    % Variables: x1, x2, ..., xn (for Path 1) and y1, y2, ..., yn (for Path 2)
    % Total variables: 2 * num_jobs
    f = zeros(2 * num_jobs, 1);
    
    % Constraints
    Aeq = [eye(num_jobs), eye(num_jobs)];
    beq = ones(num_jobs, 1);
    
    A = [];
    b = [];
    
    lb = zeros(2 * num_jobs, 1);
    ub = ones(2 * num_jobs, 1);
    
    intcon = 1:(2 * num_jobs);
    
    % Optimize using intlinprog
    options = optimoptions(@intlinprog, 'Display', 'off');
    [x, ~] = intlinprog(f, intcon, A, b, Aeq, beq, lb, ub, options);
    
    % Extract job assignments
    jobs_path1 = find(x(1:num_jobs) == 1);
    jobs_path2 = find(x((num_jobs+1):end) == 1);
    
    % Calculate makespans for the paths
    makespan1 = calculate_makespan(processing_times, jobs_path1, [1, 3, 5]);
    makespan2 = calculate_makespan(processing_times, jobs_path2, [2, 4, 5]);
    
    % Combined makespan
    combined_makespan = max(makespan1, makespan2);
    
    % Convert job indices to 1-based
    jobs_path1 = jobs_path1;
    jobs_path2 = jobs_path2;
    
    disp(['Best sequence path 1: ', num2str(jobs_path1')]);
    disp(['Best sequence path 2: ', num2str(jobs_path2')]);
    disp(['Best combined makespan: ', num2str(combined_makespan)]);
end

function makespan = calculate_makespan(processing_times, sequence, machines)
    num_jobs = length(sequence);
    num_machines = length(machines);

    if num_jobs == 0
        makespan = 0;
        return;
    end

    completion_times = zeros(num_machines, num_jobs);

    % Fill the completion times for the first job
    completion_times(1, 1) = processing_times(machines(1), sequence(1));
    for m = 2:num_machines
        completion_times(m, 1) = completion_times(m-1, 1) + processing_times(machines(m), sequence(1));
    end

    % Fill the completion times for the rest of the jobs
    for j = 2:num_jobs
        completion_times(1, j) = completion_times(1, j-1) + processing_times(machines(1), sequence(j));
        for m = 2:num_machines
            completion_times(m, j) = max(completion_times(m-1, j), completion_times(m, j-1)) + processing_times(machines(m), sequence(j));
        end
    end

    % Makespan is the last element in the completion times matrix
    makespan = completion_times(end, end);
end
