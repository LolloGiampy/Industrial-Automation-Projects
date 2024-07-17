function scheduling()
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
    fitnessFunction = @(x) calculate_combined_makespan(x, processing_times); % calculate_combined_makespan function is used as fitness function by the genetic algorithm

    % Define the number of variables (num_jobs * 2)
    nvars = num_jobs * 2;

    % Define the constraints
    Aeq = [eye(num_jobs), eye(num_jobs)]; % concatenate the two identity matrices with dimension num_jobs
    beq = ones(num_jobs, 1); % right hand side of constraints equations

    % Define the bounds
    lb = zeros(nvars, 1); % lower bound for decision variables
    ub = ones(nvars, 1); % upper bound for decision variables

    % Define the options for the genetic algorithm
    ga_options = optimoptions('ga', ...
        'Display', 'iter', ...
        'PopulationSize', 200, ...          % population size
        'MaxGenerations', 200, ...          % number of generations
        'CrossoverFraction', 0.8, ...       % crossover fraction
        'EliteCount', 10, ...               % number of elite individuals
        'FunctionTolerance', 1e-6, ...      % function tolerance
        'UseParallel', false, ...           % disable parallel computation
        'HybridFcn', @patternsearch ...     % use pattern search as hybrid function
    );

    % Run the genetic algorithm
    [x, fval] = ga(fitnessFunction, nvars, [], [], Aeq, beq, lb, ub, [], ga_options);

    indices_path1 = find(x(1:num_jobs) > 0.5);
    indices_path2 = find(x((num_jobs+1):end) > 0.5);
    
    % Estrai i valori corrispondenti a questi indici
    values_path1 = x(indices_path1);
    values_path2 = x(indices_path2);
    
    % Ordina i valori in ordine decrescente e mantieni gli indici
    [~, sorted_indices1] = sort(values_path1, 'descend');
    [~, sorted_indices2] = sort(values_path2, 'descend');
    
    % Ottieni gli indici originali ordinati
    jobs_path1 = indices_path1(sorted_indices1);
    jobs_path2 = indices_path2(sorted_indices2);

    % Display results
    disp(['Best sequence path 1: ', mat2str(jobs_path1)]);
    disp(['Best sequence path 2: ', mat2str(jobs_path2)]);


    % Combined makespan
    combined_makespan = calculate_makespan(processing_times, jobs_path1,jobs_path2, [1, 3, 5],[2, 4, 5]);

    disp(['Best combined makespan: ', num2str(combined_makespan)]);
end

function combined_makespan = calculate_combined_makespan(x, processing_times)
    % Number of jobs
    num_jobs = size(processing_times, 2);

    indices_path1 = find(x(1:num_jobs) > 0.5);
    indices_path2 = find(x((num_jobs+1):end) > 0.5);
    
    % Estrai i valori corrispondenti a questi indici
    values_path1 = x(indices_path1);
    values_path2 = x(indices_path2);
    
    % Ordina i valori in ordine decrescente e mantieni gli indici
    [~, sorted_indices1] = sort(values_path1, 'descend');
    [~, sorted_indices2] = sort(values_path2, 'descend');
    
    % Ottieni gli indici originali ordinati
    jobs_path1 = indices_path1(sorted_indices1);
    jobs_path2 = indices_path2(sorted_indices2);
    


    % Check if any jobs are not assigned
    if isempty(jobs_path1) || isempty(jobs_path2)
        combined_makespan = inf; % if one of the two paths does not have any assigned jobs, the function returns an infinite makespan, reporting an invalid solution 
        return;
    end

    % calculate combined makespan, it is determined by the path which takes longer
    combined_makespan = calculate_makespan(processing_times, jobs_path1,jobs_path2, [1, 3, 5],[2, 4, 5]);
end

function makespan = calculate_makespan(processing_times, sequence_path1,sequence_path2,machines_path1,machines_path2)
    % if the job sequence is empty, then the function immediately returns a makespan equal to zero
    if isempty(sequence_path1)
        makespan = 0;
        return;
    end
    if isempty(sequence_path2)
        makespan = 0;
        return;
    end
    % variable initialization
    num_jobs_path1 = length(sequence_path1);
    num_jobs_path2 = length(sequence_path2);
    completion_times_path1 = zeros(3, num_jobs_path1); % matrix which will be used to keep track of jobs' completion times 

    % Fill the completion times for the first job
    completion_times_path1(1, 1) = processing_times(machines_path1(1), sequence_path1(1)); % set completion time of the first job on the first machine
    % for each subsequent machine sum processing times, accumulating completion times
    
    completion_times_path1(2, 1) = completion_times_path1(1, 1) + processing_times(machines_path1(2), sequence_path1(1));
    
    queque_machine5=[zeros(num_jobs_path1+num_jobs_path2,2)];
    queque_machine5(1,1) = completion_times_path1(2, 1);
    queque_machine5(1,2) = processing_times(machines_path1(3), sequence_path1(1));

    % Fill the completion times for the rest of the jobs
    for j = 2:num_jobs_path1
        % compute completion time on the first machine as the sum of completion time of the previous job and the current processing time
        completion_times_path1(1, j) = completion_times_path1(1, j-1) + processing_times(machines_path1(1), sequence_path1(j));
        % for each subsequent machine the completion time is the max between the completion time of the previous job on the same machine and the completion time of the current job on the previous machine
        
        completion_times_path1(2, j) = max(completion_times_path1(1, j), completion_times_path1(2, j-1)) + processing_times(machines_path1(2), sequence_path1(j)); % then sum the current processing time with this max valuue
        queque_machine5(j,1)=completion_times_path1(2, j);
        queque_machine5(j,2)=processing_times(machines_path1(3), sequence_path1(j));
    end


    % repeat for path2

       % variable initialization
    
    completion_times_path2 = zeros(3, num_jobs_path2); % matrix which will be used to keep track of jobs' completion times 

    % Fill the completion times for the first job
    completion_times_path2(1, 1) = processing_times(machines_path2(1), sequence_path2(1)); % set completion time of the first job on the first machine
    % for each subsequent machine sum processing times, accumulating completion times
    
    completion_times_path2(2, 1) = completion_times_path2(1, 1) + processing_times(machines_path2(2), sequence_path2(1));
    
    queque_machine5(num_jobs_path1+1,1)=completion_times_path2(2, 1);
    queque_machine5(num_jobs_path1+1,2)=processing_times(machines_path2(3), sequence_path2(1));

    % Fill the completion times for the rest of the jobs
    for j = 2:num_jobs_path2
        % compute completion time on the first machine as the sum of completion time of the previous job and the current processing time
        completion_times_path2(1, j) = completion_times_path2(1, j-1) + processing_times(machines_path2(1), sequence_path2(j));
        % for each subsequent machine the completion time is the max between the completion time of the previous job on the same machine and the completion time of the current job on the previous machine
        
        completion_times_path2(2, j) = max(completion_times_path2(1, j), completion_times_path2(2, j-1)) + processing_times(machines_path2(2), sequence_path2(j)); % then sum the current processing time with this max valuue
        queque_machine5(num_jobs_path1+j,1)=completion_times_path2(2, j);
        queque_machine5(num_jobs_path1+j,2)=processing_times(machines_path2(3), sequence_path2(j));
    end


    queque_machine5=sortrows(queque_machine5,1);
    total_time=queque_machine5(1,1)+queque_machine5(1,2);
    for j = 2:(num_jobs_path1+num_jobs_path2)
        total_time=max(queque_machine5(j,1),total_time)+queque_machine5(j,2);
    end
    % Makespan is the last element in the completion times matrix
    makespan = total_time;
end
