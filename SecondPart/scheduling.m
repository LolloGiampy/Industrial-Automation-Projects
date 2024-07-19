clc 
clear

%% Definizione delle Matrici di Input
% Esempio con 4 tubi (job)
P = [3, 5, 2, 7;  % Tempi di saldatura
     4, 6, 3, 8]; % Tempi di forno

GM = {[1,1], [2,1];  % Tubi devono passare prima per saldatura, poi per forno
      [1,2], [2,2];
      [1,3], [2,3];
      [1,4], [2,4]};

%% Chiamata alla Funzione di Makespan
fig = uifigure;
dep = uiprogressdlg(fig,'Title','Computing JSSP Makespan...','Indeterminate','on');
drawnow
MakespanFcn(P,GM)
close(dep)
delete(fig)

function MakespanFcn(P,GM)
    [MC, NJ] = size(P); % Dimensione della matrice P
    t = optimvar('t', MC, NJ, 'Type', 'integer', 'LowerBound', 0); 
    Cmax = optimvar('Cmax', NJ, 1, 'Type', 'integer', 'LowerBound', 0);

    C = optimconstr(2*NJ);
    for ii = 1:NJ
        X = cell2mat(GM(ii, 1:end));
        C(ii) = Cmax(ii) >= t(X(end-1), X(end)) + P(X(end-1), X(end)); % Ultima operazione dei job
    end

    JSP = optimproblem;
    obj = sum(Cmax);
    JSP.Objective = obj;

    count1 = NJ + 1;
    for j = 1:NJ
        X = cell2mat(GM(j, 1:end));
        for k = 2:2:length(X)-2
            C(count1) = t(X(k+1), X(k+2)) >= t(X(k-1), X(k)) + P(X(k-1), X(k));
            count1 = count1 + 1;
        end
    end

    x = optimvar('x', MC, NJ-1, NJ, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

    M = 1;
    T = t;
    while t ~= 0 
        k = 0;
        count = 0;
        for j = 1:NJ 
            s = 1;
            while s < NJ 
                for m = 1:MC 
                    count = count + 1;
                    k = j + s;
                    D(count) = t(m,j) + P(m,j) <= t(m,k) + M*(1-x(m,j,k));
                    count = count + 1;
                    D(count) = t(m,k) + P(m,k) <= t(m,j) + M*x(m,j,k);
                end
                s = s + 1;
                if (k == NJ)
                    break
                end
            end
            if ([m, j, k] == [m, NJ-1, NJ])
                break
            end
        end
        JSP.Constraints.C = C;
        JSP.Constraints.D = D;
        [Jobs, fval] = solve(JSP, 'solver', 'intlinprog');
        t = (Jobs.t);
        Cmax = max(Jobs.Cmax);
        if isempty(t)
            M = M + 1;
            t = T;
        end
    end

    % Stampa della sequenza dei job e del makespan
    disp('Sequenza dei Job (Tubi):');
    for n = 1:NJ
        fprintf('Job %d (Saldatura: %d, Forno: %d)\n', n, t(1,n), t(2,n));
    end
    fprintf('Makespan: %d\n', Cmax);
end
