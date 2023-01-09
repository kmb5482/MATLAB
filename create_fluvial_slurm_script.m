%% Kyra M. Bryant, PhD | First Street Foundation
%  December 4th, 2022
%  This function creates a fluvial slurm bash script for each tile.

function create_fluvial_slurm_script
%% Load tile metadata and define/declare variable

load('D:\First Street\Slurm\tile_metadata.mat','CCF_model_spec',...
    'upstream_boundary_struc')
output_tile_path='D:\First Street\Slurm\';
tile_name='n40w98';
j=0; % Number of jobs/arrays
RT=[5,20,100,500];

%% Create slurm bash script

slurm_bash_script=fullfile(output_tile_path,strcat('fluvial_',tile_name,'.sh'));

% Append lines to file:
fout=fopen (slurm_bash_script,'w');
fprintf(fout,'%s','#!/bin/bash');
fprintf(fout,'\n\n%s','# /|||||||||   /||||     /||||   /|||| /|||||||||    /||||      /||||');
fprintf(fout,'\n%s','#/|||||||||||  /||||     /||||   /|||| /|||| /||||   /|||||    /|||||');
fprintf(fout,'\n%s','#/|||          /||||     /||||   /|||| /|||| /||||   /||||||  /||||||');
fprintf(fout,'\n%s','# /||||||||||  /||||     /||||   /|||| /||||/||||    /||||  ||| /||||');
fprintf(fout,'\n%s','#  /|||||||||| /||||     /||||   /|||| /|||||||      /||||   |  /||||');
fprintf(fout,'\n%s','#         /||| /||||     /||||   /|||| /||||/||||    /||||      /||||');
fprintf(fout,'\n%s','# /||||||||||  /||||||||| /|||| /||||  /||||  /||||  /||||      /||||');
fprintf(fout,'\n%s','#  /|||||||    /|||||||||   /||||||    /||||    /||| /||||      /||||');
fprintf(fout,'\n%s','#   ```````     `````````   ``````      ````     ```  ````      ````');
fprintf(fout,'\n%s','#   ____________________________________________________________Kyra');
fprintf(fout,'\n%s','#  |                                                    		   |');
fprintf(fout,'\n%s','#  |        F I R S T   S T R E E T   F O U N D A T I O N          |');
fprintf(fout,'\n%s','#  |_______________________________________________________________|');
fprintf(fout,'\n%s','#   ````````````````````````````````````````````````````````````````');
fprintf(fout,'\n\n%s%s%s','# Pluvial Bash Script Created ',date,'__________________________');
fprintf(fout,'\n\n%s%s\t\t%s','#SBATCH -J ',tile_name,'# Tile/Job Name');
fprintf(fout,'\n%s\t\t\t%s','#SBATCH -N 1','# Request 1 Node');
fprintf(fout,'\n%s\t\t%s','#SBATCH --exclusive','# Only 1 Job per Node');
fprintf(fout,'\n%s\t%s','#SBATCH --error=error_%A.err','# Error File');
fprintf(fout,'\n%s\t%s','#SBATCH --output=out_%A.out','# Standard Output File');

%% Determine number of array/jobs "j"

for model_ID=1:numel(CCF_model_spec)
    execute_RP=CCF_model_spec(model_ID).execute_RP;
    for rtn=1:numel(execute_RP) % loop return periods
        for sim_ID=1:max([upstream_boundary_struc.sim_ID]) % loop sim ID's
            j=j+1;
         end
    end
end
%% Append remaining #SBATCH commands

fprintf(fout,'\n%s%i\t%s','#SBATCH --array=1-',j,'# Number of Arrays/Jobs');
fprintf(fout,'\n\n%s','# _________________________________________________________________');
fprintf(fout,'\n');

%% Main loop for adding .par files
k=0;
for model_ID=1:numel(CCF_model_spec)
    time_horizon=CCF_model_spec(model_ID).year;
    CCF_percentile=CCF_model_spec(model_ID).percentile;
    execute_RP=CCF_model_spec(model_ID).execute_RP;
    for rtn=1:numel(execute_RP) % loop return periods
        dist=abs(RT-execute_RP(rtn));
        minDist=min(dist);
        rtn_idx=dist==minDist; % index of sim return period in full RP set
        for sim_ID=1:max([upstream_boundary_struc.sim_ID]) % loop sim ID's
            k=k+1;
            % build sim_ID string
            ID_str=strcat('parfile_array[',num2str(k),']=parfile_',num2str(time_horizon),'_0p',num2str(CCF_percentile*100),'PCTL_1in',num2str(RT(rtn_idx)),'_',num2str(sim_ID),'_fluv_def.par');
            fprintf(fout,'\n%s',ID_str);
        end
    end
end

%% Append remaining lines

fprintf(fout,'\n\n%s','# Working Directory');
fprintf(fout,'\n%s%s','cd /mnt/hyperion/v3_flood/inland/input_copy/tile_name');
fprintf(fout,'\n\n%s','# Executable');
fprintf(fout,'\n%s','/mnt/hyperion/flood/refroudelimitgcc/ssbn_flow_float_gcc_froude3 -v -log -cfl 0.7 ${parfile_array[$SLURM_ARRAY_TASK_ID]}');

end

