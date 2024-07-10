function scheduling()
    % Job processing times
    processing_times = [
        5, 3, 6, 8, 4, 12, 12, 5, 3, 2;    % M1
        12, 6, 1, 5, 6, 15, 3, 2, 8, 8;    % M2
        1, 20, 2, 5, 7, 11, 12, 2, 5, 4;   % M3
        13, 10, 1, 15, 6, 12, 11, 4, 4, 13;% M4
        2, 6, 2, 1, 5, 13, 2, 7, 18, 3     % M5
    ];

    % Number of jobs
    num_jobs = size(processing_times, 2);

    % Define the fitness function
    fitnessFunction = @(x) calculate_combined_makespan(x, processing_times);

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
        'PopulationSize', 200, ...          % Increased population size
        'MaxGenerations', 200, ...          % Increased number of generations
        'CrossoverFraction', 0.8, ...       % Crossover fraction
        'EliteCount', 10, ...               % Number of elite individuals
        'FunctionTolerance', 1e-6, ...      % Function tolerance
        'UseParallel', false, ...           % Disable parallel computation
        'HybridFcn', @patternsearch ...     % Use pattern search as hybrid function
    );

    % Run the genetic algorithm
    [x, fval] = ga(fitnessFunction, nvars, [], [], Aeq, beq, lb, ub, [], ga_options);

    % Extract job assignments
    jobs_path1 = find(x(1:num_jobs) > 0.5);
    jobs_path2 = find(x((num_jobs+1):end) > 0.5);

    % Display results
    disp(['Best sequence path 1: ', mat2str(jobs_path1)]);
    disp(['Best sequence path 2: ', mat2str(jobs_path2)]);

    % Calculate makespans for the paths
    makespan1 = calculate_makespan(processing_times, jobs_path1, [1, 3, 5]);
    makespan2 = calculate_makespan(processing_times, jobs_path2, [2, 4, 5]);

    % Combined makespan
    combined_makespan = max(makespan1, makespan2);

    disp(['Best combined makespan: ', num2str(combined_makespan)]);
end

function combined_makespan = calculate_combined_makespan(x, processing_times)
    % Number of jobs
    num_jobs = size(processing_times, 2);

    % Extract job assignments
    jobs_path1 = find(x(1:num_jobs) > 0.5);
    jobs_path2 = find(x((num_jobs+1):end) > 0.5);

    % Check if any jobs are not assigned
    if isempty(jobs_path1) || isempty(jobs_path2)
        combined_makespan = inf;
        return;
    end

    % Calculate makespans for the paths
    makespan1 = calculate_makespan(processing_times, jobs_path1, [1, 3, 5]);
    makespan2 = calculate_makespan(processing_times, jobs_path2, [2, 4, 5]);

    % Combined makespan
    combined_makespan = max(makespan1, makespan2);
end

function makespan = calculate_makespan(processing_times, sequence, machines)
    if isempty(sequence)
        makespan = 0;
        return;
    end

    num_jobs = length(sequence);
    num_machines = length(machines);

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
