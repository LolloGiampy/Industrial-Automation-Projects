% generate_instances.m

function instances = generate_instances(num_instances, num_tubes)
    instances = cell(num_instances, 1);
    for instance = 1:num_instances
        % tubes = [id, processing_time_on_welding, processing_time_on_oven]
        tubes = [(1:num_tubes)', randi([1, 20], num_tubes, 1), randi([1, 20], num_tubes, 1)];
        instances{instance} = tubes;
    end
end
