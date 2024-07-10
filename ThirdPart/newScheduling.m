% Number of jobs
n = 10;

% Processing times for each job on each machine
processing_times = [
    5, 3, 6, 8, 4, 12, 12, 5, 3, 2;    % M1
    12, 6, 1, 5, 6, 15, 3, 2, 8, 8;    % M2
    1, 20, 2, 5, 7, 11, 12, 2, 5, 4;   % M3
    13, 10, 1, 15, 6, 12, 11, 4, 4, 13;% M4
    2, 6, 2, 1, 5, 13, 2, 7, 18, 3     % M5
];

% Large constant for the constraints
M = sum(processing_times, 'all');

% Objective function: minimize C_max
f = [zeros(1, 2*n), 1]; % 2*n binary variables and 1 for C_max

% Constraints
A = [];
b = [];

% Job assignment constraints (each job must be assigned to exactly one path)
Aeq = [eye(n), eye(n), zeros(n, 1)];
beq = ones(n, 1);

% Path constraints
% Path 1: Machines 1, 3, 5
path1_machines = [1, 3, 5];
% Path 2: Machines 2, 4
path2_machines = [2, 4, 5];

for i = 1:n
    % Path 1 constraints
    for m = path1_machines
        tempA = zeros(1, 2*n+1);
        tempA(i) = processing_times(m, i); % Process time for job i on machine m
        tempA(end) = -1; % C_max >= sum of process times
        A = [A; tempA];
        b = [b; 0];
    end

    % Path 2 constraints
    for m = path2_machines
        tempA = zeros(1, 2*n+1);
        tempA(n+i) = processing_times(m, i); % Process time for job i on machine m
        tempA(end) = -1; % C_max >= sum of process times
        A = [A; tempA];
        b = [b; 0];
    end
end

% Lower and upper bounds for decision variables
lb = zeros(2*n+1, 1);
ub = [ones(2*n, 1); Inf];

% Binary variables for job assignment
intcon = 1:2*n;

% Solve the MILP
opts = optimoptions('intlinprog', 'Display', 'off');
[x, fval] = intlinprog(f, intcon, A, b, Aeq, beq, lb, ub, opts);

% Extract job assignments and makespan
C_max = fval;
assignments = x(1:2*n);

% Display results
disp('Job Assignments:');
disp(reshape(assignments, n, 2));

disp(['Minimum Makespan: ', num2str(C_max)]);
