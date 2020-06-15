addpath(genpath('/home/hannes/Desktop/spm12_v7486'));

Nsub=21;
subfold={'415.conte69_74k.lh','417.conte69_74k.lh','418.conte69_74k.lh','420.conte69_74k.lh','421.conte69_74k.lh','422.conte69_74k.lh'...
    '423.conte69_74k.lh','424.conte69_74k.lh','425.conte69_74k.lh','426.conte69_74k.lh','427.conte69_74k.lh','443.conte69_74k.lh'...
    '451.conte69_74k.lh','452.conte69_74k.lh','453.conte69_74k.lh','457.conte69_74k.lh','458.conte69_74k.lh','459.conte69_74k.lh'...
    '461.conte69_74k.lh','462.conte69_74k.lh','478.conte69_74k.lh',...
    };

region_names={'VOI_lV1_1' 'VOI_lOPA_1' 'VOI_lPPA_1' 'VOI_lRSCs_1'};
modality = 'task_stoch';

number_regions=length(region_names);

for isub=1:Nsub
    clearvars -except Nsub subfold region_names modality number_regions isub Nsub;
    cd('/media/hannes/Almgren_Disk4/Project_OHBM_2020/Specific Data/Task/drive-download-20191219T153905Z-001');

    cd([subfold{isub}]);

    DCM=[];
    K=[];
    SPM=[];
    length_scan1=[];
    DCM_est=[];
    
    SPM=load_SPM_estimated;
    
    %% DCM estimation for one hemisphere
    DCM.a=ones(number_regions,number_regions);
    DCM.b(:,:,1)=zeros(number_regions,number_regions);
    DCM.b(:,:,2)=[0 0 0 0;1 0 1 0;1 1 0 0;0 1 1 0];
    DCM.c=zeros(number_regions,2);
    DCM.c(1,1)=1;
    DCM.d=zeros(number_regions,number_regions,0);
    
    
    for region_number=1:number_regions
        K = load([region_names{region_number}], 'xY');
        DCM.Y.name{region_number} = K.xY.name;
        DCM.Y.y(:,region_number) = K.xY.u;
        length_scan1=length(K.xY.u);
    end

    DCM.v = length_scan1; %total length of scan
    DCM.n = number_regions;

    DCM.U.u(:,1) = [SPM.Sess(1).U(1).u(33:end,1); SPM.Sess(2).U(1).u(33:end,1)];
    DCM.U.u(:,2) = [SPM.Sess(1).U(2).u(33:end,1); SPM.Sess(2).U(2).u(33:end,1)];

    DCM.Y.dt = SPM.xY.RT; %TR
    
    %Inform priors based on csd rsDCM
    DCM_stoch=load_prior_DCM(['/media/hannes/Almgren_Disk4/Project_OHBM_2020/Specific Data/Rest/drive-download-20191219T153119Z-001/' subfold{isub} '/DCM_estimated_stoch.mat']);
    DCM.M.pE.A = DCM_stoch{1}.Ep.A;
    
    pC=DCM_stoch{1}.Cp; %posterior becomes prior
    DCM_task_uninf=load_prior_DCM(['DCM_estimated_task_uninf.mat']);
    
    DCM.M.pE.B = DCM_task_uninf{1}.M.pE.B;
    DCM.M.pE.C = DCM_task_uninf{1}.M.pE.C;
    DCM.M.pE.D = DCM_task_uninf{1}.M.pE.D;
    DCM.M.pE.transit = DCM_task_uninf{1}.M.pE.transit;
    DCM.M.pE.decay = DCM_task_uninf{1}.M.pE.decay;
    DCM.M.pE.epsilon = DCM_task_uninf{1}.M.pE.epsilon;
    
    DCM.M.pC = DCM_task_uninf{1}.M.pC; %use standard priors for other parameters
    DCM.M.pC(1:16,1:16)=pC(1:16,1:16); %use posterior A-matrix Cov matrix as prior A-matix cov matrix

    DCM.TE = 0.04; %TE
    DCM.options.nonlinear = 0;
    DCM.options.two_state = 0;
    DCM.options.stochastic = 0;
    DCM.options.centre = 0; %if you use an input
    DCM.options.induced = 0;
    DCM.M.nograph = false; % to avoid the SPM window to pop up
    
    DCM_est = spm_dcm_fit(DCM);
    DCM=DCM_est;
    save_DCM_estimated(DCM,modality);
end