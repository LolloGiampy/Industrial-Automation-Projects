import numpy as np
from itertools import combinations

# Job processing times
processing_times = np.array([
    [5, 3, 6, 8, 4, 12, 12, 5, 3, 2],   # M1
    [12, 6, 1, 5, 6, 15, 3, 2, 8, 8],   # M2
    [1, 20, 2, 5, 7, 11, 12, 2, 5, 4],  # M3
    [13, 10, 1, 15, 6, 12, 11, 4, 4, 13], # M4
    [2, 6, 2, 1, 5, 13, 2, 7, 18, 3]    # M5
])

# Number of jobs and machines
num_jobs = processing_times.shape[1]

# Function to calculate makespan for a given sequence on a given set of machines
def calculate_makespan(sequence, machines):
    num_path_jobs = len(sequence)
    num_path_machines = len(machines)
    
    if num_path_jobs == 0:
        return 0

    completion_times = np.zeros((num_path_machines, num_path_jobs))
    
    # Fill the completion times for the first job
    completion_times[0, 0] = processing_times[machines[0], sequence[0]]
    for m in range(1, num_path_machines):
        completion_times[m, 0] = completion_times[m-1, 0] + processing_times[machines[m], sequence[0]]

    # Fill the completion times for the rest of the jobs
    for j in range(1, num_path_jobs):
        completion_times[0, j] = completion_times[0, j-1] + processing_times[machines[0], sequence[j]]
        for m in range(1, num_path_machines):
            completion_times[m, j] = max(completion_times[m-1, j], completion_times[m, j-1]) + processing_times[machines[m], sequence[j]]
    
    # Makespan is the last element in the completion times matrix
    makespan = completion_times[-1, -1]
    return makespan

# All possible job indices
jobs = list(range(num_jobs))

# Generate all possible splits of the jobs into two groups
best_combined_makespan = float('inf')
best_split = None
best_sequence1 = None
best_sequence2 = None

for i in range(1, num_jobs):
    for group1_indices in combinations(jobs, i):
        group2_indices = [job for job in jobs if job not in group1_indices]
        
        # Calculate makespan for the first group (M1->M3->M5)
        makespan1 = calculate_makespan(group1_indices, [0, 2, 4])
        
        # Calculate makespan for the second group (M2->M4->M5)
        makespan2 = calculate_makespan(group2_indices, [1, 3, 4])
        
        # Combined makespan is the maximum of the two makespans
        combined_makespan = max(makespan1, makespan2)
        
        # Check if this is the best combined makespan
        if combined_makespan < best_combined_makespan:
            best_combined_makespan = combined_makespan
            best_split = (group1_indices, group2_indices)
            best_sequence1 = group1_indices
            best_sequence2 = group2_indices

# Convert job indices to 1-based
best_sequence1 = [job + 1 for job in best_sequence1]
best_sequence2 = [job + 1 for job in best_sequence2]

print(f"Best sequence path 1: {best_sequence1}")
print(f"Best sequence path 2: {best_sequence2}")
print(f"Best combined makespan: {best_combined_makespan}")
