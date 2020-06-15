function save_DCM_estimated(DCM,modality)
    if strcmp(modality,'rest_csd')
        save('DCM_estimated_csd','DCM');
    elseif strcmp(modality,'rest_stoch')
        save('DCM_estimated_stoch','DCM');
    elseif strcmp(modality,'task_uninf')
        save('DCM_estimated_task_uninf','DCM');
    elseif strcmp(modality,'task_csd')
        save('DCM_estimated_task_csd','DCM');
    elseif strcmp(modality,'task_stoch')
        save('DCM_estimated_task_stoch','DCM');
    elseif strcmp(modality,'task_csd_exp_only')
        save('DCM_estimated_task_csd_exp_only','DCM');
    elseif strcmp(modality,'task_stoch_exp_only')
        save('DCM_estimated_task_stoch_exp_only','DCM');
    end
    
end
