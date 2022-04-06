%%
speedofsound = 343.2;

%% Add paths
addpath(genpath(pwd))

%% Set folder names
file_list = {'0008','0009','0010','0011','0012','0014','0015'}; % the seven datasets
real_or_simulated_list = {'_simulated2','_simulated3','_real','_real',}; % only used four variants in paper
% _simulated0 - no noise, no outliers, no missing data, 1 hypothesis
% _simulated1 - same as simulated0 ??? I think
% _simulated2 - std 2 in sample points of gaussian noise, no outliers, no missing data, 1 hypothesis
% _simulated3 - std 2 in sample points of gaussian noise, 20% outliers, 20% missing data, 1 hypothesis
% _real - from gcc_phat detections - estimated to have std 5 in sample points, ≈86% outliers, ??% missing data, 4 hypothesis
method_list = {@estimate_spoints_ChanHo,@estimate_spoints_velasco,@estimate_spoints_nonlinearleastsquares, ...
    @estimate_spoints_random_1_l1,@estimate_spoints_random_1_truncl1,@estimate_spoints_random_10_truncl1, ...
    @estimate_spoints_ransac_truncl2}; % Same order as in paper
n_files = length(file_list);
n_realsim = length(real_or_simulated_list);
n_methods = length(method_list);

ex.loadfiledir = '/Users/kalle/Documents/projekt/github/StructureFromSound2/data/eusipco_2021_detection_files/';
ex.speedofsound = 343.2;
ex.a_sr = 96000;

%
if 0,
    all_nr_ok = zeros(n_files,n_realsim,n_methods);
    max_nr_ok = zeros(n_files,n_realsim,n_methods);
end


%% Make the table

for file_i = 1:n_files;      % chooose i between 1 and n_files
    for realsim_j = 1:n_realsim;   % chooose j between 1 and n_realsim
        for method_k = 1:n_methods;    % chooose k between 1 and n_methods
            [file_i realsim_j method_k]
            
            % hack: re-running those experiments that haven't run before
            %
            if max_nr_ok(file_i,realsim_j,method_k)==0,
                
                % Read tdoa detections, depending on file_i and realsim_j setting.
                ex.XXXX = file_list{file_i};
                ex.loadname_u   = fullfile(ex.loadfiledir,['music_' ex.XXXX '_tdoa_detections' real_or_simulated_list{realsim_j}]);
                ex.loadname_gt   = fullfile(ex.loadfiledir,['music_' ex.XXXX '_gt']);
                ex.loadname_rstart   = fullfile(ex.loadfiledir,['music_' ex.XXXX '_rstarting']);
                load(ex.loadname_u);
                multilatfun = method_list{method_k};
                
                % Read microphone positions, from motion capture system or from
                % autocalibration depending on setting realsim_j.
                load(ex.loadname_rstart);
                if realsim_j == 4,
                    r = rstart.r_autocalib;  % For first dataset use microphone positions from autocalibration system
                else
                    r = rstart.r_mocap;      % For all the rest use microphone positions from motion capture
                end
                
                % Calculate sound positions using multilateration, depending on which
                % method method_k is used
                asol_out = multilatfun(r,tdoa_detections.u,ex.speedofsound,ex.a_sr);
                
                % Optional (for figure 3b) Use the time continuity
                if 0,
                    asol3 = more_spoints_v3_use_interval_1(asol_out,u,raw.speedofsound,raw.a_sr);
                    asol3b = more_spoints_v3_use_interval_1(asol3,u,raw.speedofsound,raw.a_sr);
                    asol3c = more_spoints_v3_use_interval_1(asol3b,u,raw.speedofsound,raw.a_sr);
                    model.smeas = 0.1;
                    model.smotion = 0.01;
                    threshold_dist = 0.05;
                    asol4a = more_spoints_v5_bundle_all_channels(asol3c,u,raw.speedofsound,raw.a_sr,threshold_dist,model);
                    asol4b = more_spoints_v5_bundle_all_channels(asol4a,u,raw.speedofsound,raw.a_sr,threshold_dist,model);
                    asol4c = more_spoints_v5_bundle_all_channels(asol4b,u,raw.speedofsound,raw.a_sr,threshold_dist,model);
                    asol4c = more_spoints_v5_bundle_all_channels(asol4c,u,raw.speedofsound,raw.a_sr,threshold_dist,model);
                    asou_out = asol4c;
                end
                
                % Load ground truth for evaluation
                load(ex.loadname_gt); % Ground Truth gt
                gt.rgt = rgt;
                gt.sgt_resamp = sgt_resamp;
                gt.sgt_mocap = s_gt;
                gt.tt_mocap = tt_mocap;
                % It is perhaps only reasonable to check the positions when the music has
                % started. OK is a vector that indicates if there is music at this time
                filenr_list = [8 9 10 11 12 14 15];
                filenr = filenr_list(file_i);
                musikstarter = [0 , 0 , 0 , 0 , 0 , 0 , 0 , 458699 , 366220 , 259188 , 313408 , 380186 , 0 , 746817 , 405888 ];
                musikstart = musikstarter(filenr);
                musikstart_toas = round(musikstart/1000);
                OK = isfinite(gt.sgt_resamp(1,:));
                OK(1:musikstart_toas)=zeros(1,musikstart_toas);
                % Visualize/evaluate
                asol_out2 = calculate_IJKU(asol_out,tdoa_detections.u,ex.speedofsound,ex.a_sr);
                evalres = brief_display_solution(asol_out2,gt,OK);
                %figure(1); evalres = plot_solution(asol_out2,gt);
                all_nr_ok(file_i,realsim_j,method_k)=evalres.nrok;
                max_nr_ok(file_i,realsim_j,method_k)=evalres.maxok;
            end;
        end
    end
end

%%

all_acc = all_nr_ok./max_nr_ok;
table1 = round(100*squeeze(all_acc(:,4,:))');
%table1 = table1([1 2 6 4 3 5 7],:); % I have reordered in the list instead.
figure3a = squeeze(mean(all_acc,1))';
%figure3a = figure3a(:,[4 5 1]); % I have reordered in the list instead.
%figure3a = figure3a([1 2 6 4 3 5 7],:)

table1
figure3a


%%
% if 0,
%     for i = 1:7;
%         tmp = file_list{i};
%         tmp1 = load(['/Users/kalle/Documents/projekt/tdoa/matlab/preprocessfiler_nya/music_' tmp '_rso_estimate.mat']);
%         tmp2 = load(['/Users/kalle/Documents/projekt/tdoa/matlab/preprocessfiler_nya/music_' tmp '_gt.mat']);
%         rstart.r_autocalib = tmp1.firstsol.r;
%         rstart.r_mocap = tmp2.rgt;
%         save(['/Users/kalle/Documents/projekt/github/StructureFromSound2/data/eusipco_2021_detection_files/music_' tmp '_rstarting.mat'],'rstart');
%     end;
% end;
%
