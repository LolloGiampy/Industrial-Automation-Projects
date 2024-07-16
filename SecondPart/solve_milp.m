function [sequence, makespan] = solve_milp(tubes)
    % Define the number of jobs
    n = size(tubes, 1);

    % Processing times for the jobs
    a = tubes(:, 2); % Welding times
    b = tubes(:, 3); % Oven times

    % Define MILP variables
    x = optimvar('x', n, n, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
    s = optimvar('s', n, 'Type', 'continuous', 'LowerBound', 0);
    Cmax = optimvar('Cmax', 'Type', 'continuous', 'LowerBound', 0);

    % Objective: Minimize makespan
    obj = Cmax;

    % Empty constraints
    constraints = optimconstr(n^2 + 2*n, 1);

    % Each job is assigned to exactly one position
    % Somma di tutte le variabili decisionali per un tale lavoro, assegna quella che è uguale a 1 in quella posizione
    for i = 1:n
        constraints(i) = sum(x(i, :)) == 1;
    end

    % Each position is occupied by exactly one job
    for j = 1:n
        constraints(n + j) = sum(x(:, j)) == 1;
    end

    % Precedence constraints for jobs on two machines
    M = 1000; % A large number
    % Count è così perchè ci sono già 2*n vincoli assegnati
    count = 2 * n + 1;
    % confronto del job corrente (i) con tutti gli altri job (j)
    for i = 1:n
        for j = 1:n
            if i ~= j
                count = count + 1;
                constraints(count) = s(i) + a(i) <= s(j) + M * (1 - x(i, j));
            end
        end
    end
    
    % Makespan constraints
    for i = 1:n
        constraints(count + i) = Cmax >= s(i) + a(i) + b(i);
    end

    % Create the optimization problem
    prob = optimproblem('Objective', obj, 'Constraints', constraints);

    % Solve the MILP problem
    options = optimoptions('intlinprog', 'Display', 'off');
    [sol, fval, exitflag, output] = solve(prob, 'Options', options);

    % Extract sequence and makespan
    sequence = zeros(n, 1);
    for j = 1:n
        for i = 1:n
            if round(sol.x(i, j)) == 1
                sequence(j) = i;
            end
        end
    end
    makespan = fval;
end
