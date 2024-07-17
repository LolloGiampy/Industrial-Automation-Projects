function new_scheduling()
    % Job processing times for each machine (10 jobs, 5 machines)
    processing_times = [
        5, 3, 6, 8, 4, 12, 12, 5, 3, 2;    % M1
        12, 6, 1, 5, 6, 15, 3, 2, 8, 8;    % M2
        1, 20, 2, 5, 7, 11, 12, 2, 5, 4;   % M3
        13, 10, 1, 15, 6, 12, 11, 4, 4, 13;% M4
        2, 6, 2, 1, 5, 13, 2, 7, 18, 3     % M5
    ];

    % Get number of jobs
    num_jobs = size(processing_times, 2);

    % Define the fitness function
    fitnessFunction = @(x) calculate_combined_makespan(x, processing_times, num_jobs);

    % Define the number of variables (num_jobs * 2)
    nvars = num_jobs * 2;

    % Define the constraints
    Aeq = [eye(num_jobs), eye(num_jobs)];
    beq = ones(num_jobs, 1);

    % Define the bounds
    lb = zeros(nvars, 1);
    ub = ones(nvars, 1);

    % Define the options for the genetic algorithm
    ga_options = optimoptions('ga', ...
        'Display', 'iter', ...
        'PopulationSize', 200, ...
        'MaxGenerations', 200, ...
        'CrossoverFraction', 0.8, ...
        'EliteCount', 10, ...
        'FunctionTolerance', 1e-6, ...
        'UseParallel', false, ...
        'HybridFcn', @patternsearch ...
    );

    % Run the genetic algorithm
    [x, fval] = ga(fitnessFunction, nvars, [], [], Aeq, beq, lb, ub, [], ga_options);

    % Extract job assignments
    jobs_path1 = find(x(1:num_jobs) > 0.5);
    jobs_path2 = find(x((num_jobs+1):end) > 0.5);

    % Display results
    disp(['Best sequence path 1: ', mat2str(jobs_path1)]);
    disp(['Best sequence path 2: ', mat2str(jobs_path2)]);

    % Combined makespan
    combined_makespan = calculate_combined_makespan_on_M5(processing_times, jobs_path1, jobs_path2);

    disp(['Best combined makespan: ', num2str(combined_makespan)]);
end

function combined_makespan = calculate_combined_makespan(x, processing_times, num_jobs)
    % Extract job assignments
    jobs_path1 = find(x(1:num_jobs) > 0.5);
    jobs_path2 = find(x((num_jobs+1):end) > 0.5);

    if isempty(jobs_path1) || isempty(jobs_path2)
        combined_makespan = inf;
        return;
    end

    % Combined makespan considering the order on M5
    combined_makespan = calculate_combined_makespan_on_M5(processing_times, jobs_path1, jobs_path2);
end

function combined_makespan = calculate_combined_makespan_on_M5(processing_times, jobs_path1, jobs_path2)
    % Calculate completion times up to M4 for both paths
    completion_times1 = calculate_completion_times(processing_times, jobs_path1, [1, 3, 4]);
    completion_times2 = calculate_completion_times(processing_times, jobs_path2, [2, 4]);

    % Initialize variables
    time_on_m5 = 0;
    job_sequence_on_m5 = [];

    % Combine jobs from both paths to be processed on M5
    jobs_on_m5 = [jobs_path1, jobs_path2];
    completion_times_on_m5 = [completion_times1(end, :), completion_times2(end, :)];
    [sorted_completion_times, sort_idx] = sort(completion_times_on_m5);

    % Process jobs on M5 in order of completion times
    for i = sort_idx
        job = jobs_on_m5(i);
        job_time_on_m5 = processing_times(5, job);
        time_on_m5 = max(time_on_m5, sorted_completion_times(i)) + job_time_on_m5;
        job_sequence_on_m5 = [job_sequence_on_m5, job];
    end

    combined_makespan = time_on_m5;
end

function completion_times = calculate_completion_times(processing_times, sequence, machines)
    if isempty(sequence)
        completion_times = [];
        return;
    end

    num_jobs = length(sequence);
    num_machines = length(machines);
    completion_times = zeros(num_machines, num_jobs);

    completion_times(1, 1) = processing_times(machines(1), sequence(1));
    for m = 2:num_machines
        completion_times(m, 1) = completion_times(m-1, 1) + processing_times(machines(m), sequence(1));
    end

    for j = 2:num_jobs
        completion_times(1, j) = completion_times(1, j-1) + processing_times(machines(1), sequence(j));
        for m = 2:num_machines
            % Ensure indices are within bounds
            if m > 1 && j > 1
                completion_times(m, j) = max(completion_times(m-1, j), completion_times(m, j-1)) + processing_times(machines(m), sequence(j));
            elseif m > 1
                completion_times(m, j) = completion_times(m-1, j) + processing_times(machines(m), sequence(j));
            elseif j > 1
                completion_times(m, j) = completion_times(m, j-1) + processing_times(machines(m), sequence(j));
            end
        end
    end
end
