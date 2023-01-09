%% Kyra M. Bryant, PhD | First Street Foundation
%  December 4th, 2022
%  This function creates a pluvial slurm bash script for each tile.

function create_pluvial_slurm_script
%% Load tile metadata and define/declare variable

load('D:\Tile_Testing\v3\tile_metadata.mat','CCF_model_spec')
output_tile_path='D:\Tile_Testing\v3';
tile_name='n33w112';
j=0; % Number of jobs/arrays
P_events=[6,12,24]; % 6hr, 12hr, 24hr

%% Create slurm bash script

slurm_bash_script=fullfile(output_tile_path,strcat('pluvial_',tile_name,'.sh'));

% Append lines to file:
fout=fopen (slurm_bash_script,'w');
fprintf(fout,'%s','#!/bin/bash');
fprintf(fout,'\n\n%s','#############################################################');
fprintf(fout,'\n%s','## --------- PLUVIAL version 3 Slurm Bash Script --------- ##');
fprintf(fout,'\n%s%s%s','## ---- Created By Kyra M. Bryant, PhD on ',date,' ---- ##');
fprintf(fout,'\n%s','## ---- F I R S T   S T R E E T   F O U N D A T I O N ---- ##');
fprintf(fout,'\n%s','#############################################################');
fprintf(fout,'\n\n%s','##-----------------------------------------------------------');
fprintf(fout,'\n\n%s%s\t\t%s','#SBATCH -J ',tile_name,'# Tile/Job Name');
fprintf(fout,'\n%s\t\t\t%s','#SBATCH -N 1','# Request 1 Node');
fprintf(fout,'\n%s\t\t%s','#SBATCH --exclusive','# Only 1 Job per Node');
fprintf(fout,'\n%s\t%s','#SBATCH --error=error_%A.err','# Error File');
fprintf(fout,'\n%s\t%s','#SBATCH --output=out_%A.out','# Standard Output File');

%% Determine number of array/jobs "j"

for model_ID=1:numel(CCF_model_spec) % loop over scenario
    execute_RP=CCF_model_spec(model_ID).execute_RP;
    for rtn=1:numel(execute_RP) % loop over RP
        for i=1:numel(P_events) % loop over pluvial event duration
            j=j+1;           
        end
    end
end

%% Append remaining #SBATCH commands

fprintf(fout,'\n%s%i\t%s','#SBATCH --array=1-',j,'# Number of Arrays/Jobs');
fprintf(fout,'\n\n%s','##-----------------------------------------------------------');
fprintf(fout,'\n');

%% Main loop for adding .par files
k=0;
for model_ID=1:numel(CCF_model_spec) % loop over scenario
    time_horizon=CCF_model_spec(model_ID).year;
    CCF_percentile=CCF_model_spec(model_ID).percentile;
    execute_RP=CCF_model_spec(model_ID).execute_RP;
    for rtn=1:numel(execute_RP) % loop over RP
        RP=(execute_RP(rtn));
        for i=1:numel(P_events) % loop over pluvial event duration
            k=k+1;
            event_duration=P_events(i);
            % build sim_ID string
            ID_str=strcat('parfile_array[',num2str(k),']=parfile_',num2str(time_horizon),'_0p',num2str(CCF_percentile*100),'PCTL_1in',num2str(RP),'_',num2str(event_duration),'hr_pluv.par');
            fprintf(fout,'\n%s',ID_str);
            
        end
    end
end

%% Append remaining lines

fprintf(fout,'\n\n%s','# Working Directory');
fprintf(fout,'\n%s','?????????????????');
fprintf(fout,'\n\n%s','# Executable');
fprintf(fout,'\n%s','srun ???????????/ssbn_flow_double_gcc_froude3 -v -log -cfl 0.7 ${parfile_array[$SLURM_ARRAY_TASK_ID]}');

end

