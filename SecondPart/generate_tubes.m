function tubes = generate_tubes(num_tubes, batch_size)
    % Inizializza l'array dei tubi
    tubes = zeros(num_tubes, 4); % Colonne: [id, batch_id, welding_time, oven_time]
    
    % Genera i tubi con tempi casuali e assegna batch_id
    for i = 1:num_tubes
        processing_time_on_welding = randi([1, 10]);
        processing_time_on_oven = randi([1, 10]);
        batch_id = ceil(i / batch_size);
        tubes(i, :) = [i, processing_time_on_welding, processing_time_on_oven, batch_id];
    end
end
