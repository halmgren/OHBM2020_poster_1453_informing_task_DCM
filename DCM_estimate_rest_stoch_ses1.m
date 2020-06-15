addpath(genpath('/home/hannes/Desktop/spm12_v7486'));

Nsub=21;
subfold={'415.conte69_74k.lh','417.conte69_74k.lh','418.conte69_74k.lh','420.conte69_74k.lh','421.conte69_74k.lh','422.conte69_74k.lh'...
    '423.conte69_74k.lh','424.conte69_74k.lh','425.conte69_74k.lh','426.conte69_74k.lh','427.conte69_74k.lh','443.conte69_74k.lh'...
    '451.conte69_74k.lh','452.conte69_74k.lh','453.conte69_74k.lh','457.conte69_74k.lh','458.conte69_74k.lh','459.conte69_74k.lh'...
    '461.conte69_74k.lh','462.conte69_74k.lh','478.conte69_74k.lh',...
    };
region_names_ses1={'VOI_lV1_1' 'VOI_lOPA_1' 'VOI_lPPA_1' 'VOI_lRSCs_1'};
region_names_ses2={'VOI_lV1_2' 'VOI_lOPA_2' 'VOI_lPPA_2' 'VOI_lRSCs_2'};
modality = 'rest_stoch';

parfor isub=1:Nsub
    
    cd('/media/hannes/Almgren_Disk4/Project_OHBM_2020/Specific Data/Rest/');
    
    %%%%%%%%%%%%%%%%%%%
    %%Estimation of DCM
    %%%%%%%%%%%%%%%%%%%
    DCM=[];
    K=[];
    xY=[];
    number_regions=[]
    
    number_regions=length(region_names_ses1); %include number of regions
    
    DCM.a=ones(number_regions,number_regions);
    DCM.b=ones(number_regions,number_regions); %only in resting state differences between sessions
    DCM.c=zeros(number_regions,1);
    DCM.d=zeros(number_regions,number_regions,0);
    
    %DCM.U.u=zeros(length_scan,1);
    DCM.U.name={'null'};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%session1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd('/media/hannes/Almgren_Disk4/Project_OHBM_2020/Specific Data/Rest/');
    cd('drive-download-20191219T153119Z-001');
    cd([subfold{isub}]);
    
    SPM=load_SPM_estimated;
    TR = SPM.xY.RT;
    
    xY=[];
    for region_number=1:number_regions
        
        K=load(region_names_ses1{region_number},'xY');
        xY = spm_cat_struct(xY,K.xY); %Here just add xY's of all regions, and use spm_cat_struct to concatenate them. You might want to ignore the previous 5 lines
        
    end
    
    length_scan=length(xY(1).u);
    DCM.U.u=zeros(length_scan,1);
    
    DCM.Y.dt=TR; %TR %or using funcDir .jason file
    
    for  region_number = 1:number_regions
        DCM.Y.y(:,region_number)  = xY(region_number).u;
        DCM.Y.name{region_number} = xY(region_number).name;
    end
    
    length_scan=length(xY(1).u);
    
    DCM.v=length_scan;
    DCM.n=number_regions;
    
    DCM.delays=ones(number_regions,1)*TR/2;
    
    DCM.options.nonlinear=0;
    DCM.options.two_state=0;
    DCM.options.stochastic=1;
    DCM.options.centre=0; %if you use an input
    DCM.options.induced=0;
    disp(num2str(number_regions))
    DCM_raw=DCM;
    
    DCM_est=spm_dcm_fit(DCM_raw);
    DCM=DCM_est;
    save_DCM_estimated(DCM,modality);
end
