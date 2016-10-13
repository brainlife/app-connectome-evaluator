function [fh, output] = connectome_evaluator(config)
% This function does... 
% 
% Below we will first load part of the data used in Figure 3 of the
% original publication (Caiafa and Pestilli, submitted)
%
% After that we will add one additional point to the plot. Using data from
% a different subject.
%
% This plots shows in a compact form two fundamental properties of a brain
% connectome:
% - the error of the conenctome in predicting the measured diffusion
%   signal, the root-mean-squared error.
% - the density of a connectome. More specifcially the number of fibers
%   supported by the measured diffusion-weighted data in the provided
%   tractography solution.
%
%  Copyright (2016), Franco Pestilli Indiana University 

%% (0) Check matlab, data dependencies and path settings.
if ~exist('vistaRootPath.m','file');
    disp('Vistasoft package either not installed or not on matlab path.')
    error('Please, download it from https://github.com/vistalab/vistasoft');
end
if ~exist('feDemoDataPath.m','file');
    disp('ERROR: demo dataset either not installed or not on matlab path.')
    error('Please, download it from http://purl.dlib.indiana.edu/iusw/data/2022/20995/Demo_Data_for_Multidimensional_Encoding_of_Brain_Connectomes.tar.gz')
end

%% (1) Figure 3 from Multidimensional encoding of brain connectomes

% We brighten the symbols to use them as background.
[fh, reference.rmse, reference.nnz] = Generate_Fig3_paper_Caiafa_Pestilli('gray');
output.reference = reference;

% We load the FE structure from the file path stored locally on the SCA
% configuration file.
%
load(config.input_fe);

% We use the core function feGet.m to extract the RMSE and the B0 (MRI
% measureemnts without the diffusion-weighted gradient applied).
% 
% We compute the mean RMSE across the whole white matter volume.
output.rmse = nanmean(feGet(fe,'voxrmses0norm'));

% We find the positive weights and disregard the NaNs. THen compute the
% number of postive weights (number of fascicles with non-zero weight, alse
% referred to as conenctome density).
output.nnz = feGet(fe,'connectome density'); 

% Finally we add the new data point to the plot we have generted. This si
% doen by plotting connectome density on the ordinate and RMSE on the
% abscissa.
plot(output.rmse, output.nnz,'o', ...
     'markerfacecolor','r', ...
     'markeredgecolor','k', ...
     'linewidth',2,'markersize',18);
drawnow

end

% Below is a series of local helper functions.
function [fh, rmse, nnz] = Generate_Fig3_paper_Caiafa_Pestilli(color_mode)
%
% Load data from the demo data repositroy and geenrate a plot similar to
% the one in Figure 3 of Caiafa and Pestilli under review.
%

DataPath = feDemoDataPath('Figs_data');

HCP_subject_set = {'111312','105115','113619','110411'};
STN_subject_set = {'KK_96dirs_b2000_1p5iso','FP_96dirs_b2000_1p5iso','HT_96dirs_b2000_1p5iso','MP_96dirs_b2000_1p5iso'};
HCP7T_subject_set = {'108323','131217','109123','910241'};

fh = figure('name','combined scatter mean +-sem across repeats','color','w');
set(fh,'Position',[0,0,800,600]);

Nalg = 13; % We plot a few data points (13 in total, 6 Prob + 6 Stream + Tensor)

% plot HCP
[rmse(1), nnz(1)] = Gen_plot(HCP_subject_set,'cold',DataPath,Nalg,'HCP3T90',color_mode);

% plot STN
[rmse(2), nnz(2)] = Gen_plot(STN_subject_set,'medium',DataPath,Nalg,'STN96',color_mode);

Nalg = 9; % We plot a few data points (9 in total, 4 Prob + 4 Stream + Tensor)

% plot HCP7T
[rmse(3), nnz(3)] = Gen_plot(HCP7T_subject_set,'hot',DataPath,Nalg,'HCP7T60',color_mode);

set(gca,'tickdir','out', 'ticklen',[0.025 0.025], ...
         'box','off','ytick',[2 9 16].*10^4, 'xtick', [0.04 0.07 0.1], ...
         'ylim',[2 16].*10^4, 'xlim', [0.04 0.1],'fontsize',20)
axis square
ylabel('Fascicles number','fontsize',20)
xlabel('Connectome error (r.m.s.)','fontsize',20)
drawnow

end

function [rmse, nnz] = Gen_plot(subject_set,color_type,DataPath,Nalg,dataset,color_mode)
%
% Generate a scatter plot similar to Caiafa and Pestilli Figure 3
%
nnz_all  = zeros(length(subject_set),Nalg,10);
nnz.mean = zeros(length(subject_set),Nalg);
nnz.std  = zeros(length(subject_set),Nalg);

alg_names = cell(1,Nalg);

if Nalg==13
    range_prob = 2:2:12;
    range_det = 3:2:13;
    prob_ix_low = [2:7];
    prob_ix_high = [15:20];
    det_ix_low = [8:13];
    det_ix_high = [21:26];
    ten_ix_low = [1];
    ten_ix_high = [14];
    lmax_order = [3,4,5,6,1,2];
else
    range_prob = 2:2:8;
    range_det = 3:2:9;
    prob_ix_low = [2:5];
    prob_ix_high = [11:14];
    det_ix_low = [6:9];
    det_ix_high = [15:18];
    ten_ix_low = [1];
    ten_ix_high = [10];
    lmax_order = [1,2,3,4];
end

n = 1;
for subject = subject_set;
    switch dataset
        case {'HCP7T60','STN96','HCP3T90'}
            DataFile = char(fullfile(DataPath,strcat('Rmse_nnz_10_connectomes_',subject,'_run01','.mat')));
        case {'HCP3T60','STN60'}
            DataFile = char(fullfile(DataPath,strcat('Rmse_nnz_10_connectomes_',subject,'_60dir*run01','.mat'))); 
    end    
    
    load(DataFile)
    
    m = 1;
    % Tensor
    for p=1:1
        rmse_all(n,m,:) = Result_alg(p).rmse;
        rmse.mean(n,m)  = nanmean(Result_alg(p).rmse);
        rmse.std(n,m)   = nanstd(Result_alg(p).rmse)./sqrt(length(Result_alg(p).rmse));
        
        nnz_all(n,m,:) = Result_alg(p).nnz;
        nnz.mean(n,m)  = nanmean(Result_alg(p).nnz);
        nnz.std(n,m)   = nanstd(Result_alg(p).nnz)./sqrt(length(Result_alg(p).nnz));
        
        alg_names{m} = char(alg_info(p).description);
        m = m +1;
    end

    % Prob
    for p = range_prob  
        rmse_all(n,m,:) = Result_alg(p).rmse;
        rmse.mean(n,m) = nanmean(Result_alg(p).rmse);
        rmse.std(n,m)  = nanstd(Result_alg(p).rmse)./sqrt(length(Result_alg(p).rmse));       
        
        nnz_all(n,m,:) = Result_alg(p).nnz;
        nnz.mean(n,m)  = mean(Result_alg(p).nnz);
        nnz.std(n,m)   = std(Result_alg(p).nnz)./sqrt(length(Result_alg(p).nnz));
        
        alg_names{m} = char(alg_info(p).description);
        m = m +1;
    end

    % Det
    for p = range_det           
        rmse_all(n,m,:) = Result_alg(p).rmse;
        rmse.mean(n,m) = nanmean(Result_alg(p).rmse);
        rmse.std(n,m)  = nanstd(Result_alg(p).rmse)./sqrt(length(Result_alg(p).rmse));
        
        nnz_all(n,m,:) = Result_alg(p).nnz;
        nnz.mean(n,m) = nanmean(Result_alg(p).nnz);
        nnz.std(n,m)  = nanstd(Result_alg(p).nnz)./sqrt(length(Result_alg(p).nnz)); 
        
        alg_names{m} = char(alg_info(p).description);
        m = m +1;
    end

    n = n + 1;
end

switch color_mode
    case 'original'
        c = getNiceColors(color_type);
    case 'gray'
        c = repmat([.9,.9,.9], [4,1]);
end


for is  = 1:size(nnz_all,1)    
    tmp_rmse = squeeze(rmse_all(is,:,:));
    tmp_rmse(isinf(tmp_rmse)) = nan;
    
    tmp_nnz = squeeze(nnz_all(is,:,:));
    tmp_nnz(isinf(tmp_nnz)) = nan;
    
    % mu and sem RMSE
    rmse.mu(is,:) = squeeze(nanmean(tmp_rmse,2));
    rmse.ci(is,:) = [rmse.mu(is,:), rmse.mu(is,:)] + 5*([-nanstd(tmp_rmse,[],2),;nanstd(tmp_rmse,[],2)]' ./sqrt(size(tmp_rmse,2)));
    
    % mu and sem NNZ
    nnz.mu(is,:) = squeeze(nanmean(tmp_nnz,2));
    nnz.ci(is,:) = [nnz.mu(is,:), nnz.mu(is,:)] + 5*([-nanstd(tmp_nnz,[],2);nanstd(tmp_nnz,[],2)]' ./sqrt(size(tmp_rmse,2)));
end

% scatter plot with confidence intervals first all in gray
a = 0.5;

for ii = 1:length(subject_set) % subjects
   hold on
   % PROB
   for iii = lmax_order
       plot(rmse.mean(ii,prob_ix_low(iii)), nnz.mean(ii,prob_ix_low(iii)),'o','markerfacecolor',c(ii,:),'markeredgecolor',[.5,.5,.5],'linewidth',0.5,'markersize',14)
       plot([rmse.ci(ii,prob_ix_low(iii)); rmse.ci(ii,prob_ix_high(iii))], [nnz.mu(ii,prob_ix_low(iii)); nnz.mu(ii,prob_ix_low(iii))],'-','color',[a a a],'linewidth',2)
       plot([rmse.mu(ii,prob_ix_low(iii)); rmse.mu(ii,prob_ix_low(iii))], [nnz.ci(ii,[prob_ix_low(iii)]);  nnz.ci(ii,prob_ix_high(iii))],'-','color',[a a a],'linewidth',2)   
   end
   
   % DET
   for iii = lmax_order
       plot(rmse.mean(ii,det_ix_low(iii)), nnz.mean(ii,det_ix_low(iii)),'s','markerfacecolor',c(ii,:),'markeredgecolor',[.5,.5,.5],'linewidth',0.5,'markersize',14)
       plot([rmse.ci(ii,det_ix_low(iii)); rmse.ci(ii,[det_ix_high(iii)])], [nnz.mu(ii,det_ix_low(iii)); nnz.mu(ii,det_ix_low(iii))],'-','color',[a a a],'linewidth',2)
       plot([rmse.mu(ii,det_ix_low(iii)); rmse.mu(ii,det_ix_low(iii));], [nnz.ci(ii,det_ix_low(iii)); nnz.ci(ii,[det_ix_high(iii)])],'-','color',[a a a],'linewidth',2)
   end
   
   % TENSOR
   plot(rmse.mean(ii,ten_ix_low), nnz.mean(ii,ten_ix_low),'d','markerfacecolor',c(ii,:),'markeredgecolor',[.5,.5,.5],'linewidth',0.5,'markersize',14)
   plot([rmse.ci(ii,ten_ix_low); rmse.ci(ii,ten_ix_high)], [nnz.mu(ii,ten_ix_low); nnz.mu(ii,ten_ix_low)],'-','color',[a a a],'linewidth',2)
   plot([rmse.mu(ii,ten_ix_low); rmse.mu(ii,ten_ix_low)], [nnz.ci(ii,ten_ix_low); nnz.ci(ii,ten_ix_high)],'-','color',[a a a],'linewidth',2)
   
end

end


function c = getNiceColors(color_type)
%
% Load look-up-table for plot colors.
% 
dotest = false;
c1 = colormap(parula(32));
c2 = colormap(autumn(32));

if dotest
    figure('name','C1 color test');
    hold on
    for ii = 1:size(c1,1)
        plot(ii,1,'o','markerfacecolor',c1(ii,:),'markersize',12)
        text(ii-0.75,1,sprintf('%i',ii))
    end
    
    figure('name','C2 color test');
    hold on
    for ii = 1:size(c2,1)
        plot(ii,1,'o','markerfacecolor',c2(ii,:),'markersize',12)
        text(ii-0.75,1,sprintf('%i',ii))
    end
    keyboard
end

switch color_type
    case 'cold'
        c = [c1([1 3 6 9],:) ];
    case 'medium'
        c = [c1([12 16 19 23],:) ];
    case 'hot'
        c = [c2([32 25 13 5],:)];
end

end





