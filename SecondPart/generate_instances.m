function instances = generate_instances(num_instances, num_tubes, max_batch_size)
    instances = cell(num_instances, 1);
    batch_id = 1;
    global_tube_id = 1;  % Aggiunto per garantire unicità globale degli ID
    
    for instance = 1:num_instances % da 1 a 10
        num_batches = ceil(num_tubes / max_batch_size); % 15/5=3
        tubes = [];
        
        for batch = 1:num_batches % 3
            batch_size = min(max_batch_size, num_tubes - (batch - 1) * max_batch_size); % 5
            batch_tubes = [(global_tube_id:global_tube_id + batch_size - 1)', randi([1, 20], batch_size, 1), randi([1, 20], batch_size, 1), repmat(batch_id, batch_size, 1)];
            tubes = [tubes; batch_tubes];
            global_tube_id = global_tube_id + batch_size;
            batch_id = batch_id + 1;
        end
        
        instances{instance} = tubes;
    end
end
