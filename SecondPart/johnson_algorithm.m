function ordered_tubes = johnson_algorithm(tubes)
    % Estrae i tempi di welding e oven
    a = tubes(:, 2); % processing_time_on_welding
    b = tubes(:, 3); % processing_time_on_oven
    
    left = [];
    right = [];

    while ~isempty(tubes)
        [min_a, idx_a] = min(a);
        [min_b, idx_b] = min(b);

        % Se a è il valore minimo J viene aggiunto a sinistra
        if min_a <= min_b
            left = [left; tubes(idx_a, :)];
            tubes(idx_a, :) = [];
            a(idx_a) = [];
            b(idx_a) = [];
        % Se b è il valore minimo J viene aggiunto a destra
        else
            right = [tubes(idx_b, :); right];
            tubes(idx_b, :) = [];
            a(idx_b) = [];
            b(idx_b) = [];
        end
    end

    ordered_tubes = [left; right];
end
