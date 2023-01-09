%% Kyra M. Bryant, PhD | First Street Foundation
% January 9th, 2023
% This script clears old jobs from ParallelCluster.

c=parcluster;
delete(c.Jobs)
cleanJobStorageLocation(c)