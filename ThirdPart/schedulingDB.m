function schedulingDB()
    % Aggiungi il driver JDBC al java class path di Matlab
    javaaddpath('C:\Users\loren\sqljdbc_12.6.3.0_ita\sqljdbc_12.6\ita\jars\mssql-jdbc-12.6.3.jre8.jar')
    
    % Configurazione della connessione al database
    driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
    serverName = 'LOLLOASUS'; 
    portNumber = '1433';
    databaseName = 'Scheduling';
    
    % URL di connessione
    url = sprintf('jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=false;', serverName, portNumber, databaseName);
    
    % Configurazione della connessione al database
    conn = database(databaseName,'admin', 'password456', driver, url);
    
    % Verifica della connessione
    if isopen(conn)
        disp('Connessione al database riuscita')
    else
        disp('Connessione al database fallita')
        disp(conn.Message);
        return;
    end
    % Reset delle tabelle
    execute(conn, 'BEGIN TRANSACTION;');
    execute(conn, 'DELETE FROM processing_times');
    execute(conn, 'COMMIT;');

    execute(conn, 'BEGIN TRANSACTION;');
    generate_pt(conn, 10);
    execute(conn, 'COMMIT;');
    data = sqlread(conn, "processing_times");
    table2array(data)

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

    % Extract job assignments, these variables contain the optimal sequences of jobs found by the genetic algorithm 
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
    for job = jobs_path1
        sqlquery = sprintf("INSERT INTO processing_times (id, path) VALUES (%d, %d)", ...
        job,1 );
        execute(conn, sqlquery);
    end
    for job = jobs_path2
        sqlquery = sprintf("INSERT INTO processing_times (id, path) VALUES (%d, %d)", ...
        job,2 );
        execute(conn, sqlquery);
    end
end

function combined_makespan = calculate_combined_makespan(x, processing_times)
    % Number of jobs
    num_jobs = size(processing_times, 2);

    % Extract job assignments
    jobs_path1 = find(x(1:num_jobs) > 0.5); % extract jobs assigned to the first path
    jobs_path2 = find(x((num_jobs+1):end) > 0.5); % extract jobs assigned to the second path

    % Check if any jobs are not assigned
    if isempty(jobs_path1) || isempty(jobs_path2)
        combined_makespan = inf; % if one of the two paths does not have any assigned jobs, the function returns an infinite makespan, reporting an invalid solution 
        return;
    end

    % Calculate makespans for the path calling the function calculate_makespan
    makespan1 = calculate_makespan(processing_times, jobs_path1, [1, 3, 5]);
    makespan2 = calculate_makespan(processing_times, jobs_path2, [2, 4, 5]);

    % calculate combined makespan, it is determined by the path which takes longer
    combined_makespan = max(makespan1, makespan2);
end

function makespan = calculate_makespan(processing_times, sequence, machines)
    % if the job sequence is empty, then the function immediately returns a makespan equal to zero
    if isempty(sequence)
        makespan = 0;
        return;
    end

    % variable initialization
    num_jobs = length(sequence);
    num_machines = length(machines);
    completion_times = zeros(num_machines, num_jobs); % matrix which will be used to keep track of jobs' completion times 

    % Fill the completion times for the first job
    completion_times(1, 1) = processing_times(machines(1), sequence(1)); % set completion time of the first job on the first machine
    % for each subsequent machine sum processing times, accumulating completion times
    for m = 2:num_machines
        completion_times(m, 1) = completion_times(m-1, 1) + processing_times(machines(m), sequence(1));
    end

    % Fill the completion times for the rest of the jobs
    for j = 2:num_jobs
        % compute completion time on the first machine as the sum of completion time of the previous job and the current processing time
        completion_times(1, j) = completion_times(1, j-1) + processing_times(machines(1), sequence(j));
        % for each subsequent machine the completion time is the max between the completion time of the previous job on the same machine and the completion time of the current job on the previous machine
        for m = 2:num_machines
            completion_times(m, j) = max(completion_times(m-1, j), completion_times(m, j-1)) + processing_times(machines(m), sequence(j)); % then sum the current processing time with this max valuue
        end
    end

    % Makespan is the last element in the completion times matrix
    makespan = completion_times(end, end);
end
