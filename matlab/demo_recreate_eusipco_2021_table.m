%%



%%



speedofsound = 343.2;

%% Add paths

addpath(genpath(pwd))

%% Set folder names

file_list = {'0008','0009','0010','0011','0012','0014','0015'};
real_or_simulated_list = ('','_simulated','_simulated1','_simulated2','_simulated3'}
method_list = {@estimate_spoints_ChanHo,@estimate_spoints_velasco,@estimate_spoints_random_1_truncl1, ...
    @estimate_spoints_random_1_l1,@estimate_spoints_random_10_truncl1,@estimate_spoints_nonlinearleastsquares, ...
    @estimate_spoints_ransac_truncl2};

ex.savefiledir = '/Users/kalle/Documents/projekt/tdoa/matlab_new_system_for_eusipco_2021/eusipco_2021_data_files';
ex.XXXX = '0015';
ex.savename_u   = fullfile(ex.savefiledir,['music_' ex.XXXX '_tdoa_detections']);
ex.savename_gt   = fullfile(ex.savefiledir,['music_' ex.XXXX '_gt']);
ex.speedofsound = 343.2;
ex.a_sr = 96000;

%% Read sound files

load(ex.savename_u);

%% Read microphone positions - either ground truth from motion capture system of from autocalibration

[r, s, o, sol] = tdoa(ztmp, 'display', 'iter', 'sigma', 0.01);

%% Refine sound source positions - eusipco 2021 paper

% asol_out = estimate_spoints_ChanHo(r,u,raw.speedofsound,raw.a_sr);
% asol_out = estimate_spoints_velasco(r,u,raw.speedofsound,raw.a_sr);
% asol_out = estimate_spoints_random_1_truncl1(r,u,raw.speedofsound,raw.a_sr);
% asol_out = estimate_spoints_random_1_l1(r,u,raw.speedofsound,raw.a_sr);
% asol_out = estimate_spoints_random_10_truncl1(r,u,raw.speedofsound,raw.a_sr);
% asol_out = estimate_spoints_nonlinearleastsquares(r,u,raw.speedofsound,raw.a_sr);
asol_out = estimate_spoints_ransac_truncl2(r,u,ex.speedofsound,ex.a_sr);

%% Use the time continuity

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

%% Load ground truth

load(ex.savename_gt); % Ground Truth gt
gt.rgt = rgt;
gt.sgt_resamp = sgt_resamp;
gt.sgt_mocap = s_gt;
gt.tt_mocap = tt_mocap;

% It is perhaps only reasonable to check the positions when the music has
% started. OK is a vector that indicates if there is music at this time
filenr = 14;
musikstarter = [0 , 0 , 0 , 0 , 0 , 0 , 0 , 458699 , 366220 , 259188 , 313408 , 380186 , 0 , 746817 , 405888 ];
musikstart = musikstarter(filenr);
musikstart_toas = round(musikstart/1000);
OK = isfinite(gt.sgt_resamp(1,:));
OK(1:musikstart_toas)=zeros(1,musikstart_toas);

%% Visualize/evaluate

asol_out2 = calculate_IJKU(asol_out,u,raw.speedofsound,raw.a_sr);
brief_display_solution(asol_out2,gt,OK);
brief_display_solution(asol3,gt,OK);
brief_display_solution(asol3b,gt,OK);
brief_display_solution(asol3c,gt,OK);
brief_display_solution(asol4a,gt,OK);
brief_display_solution(asol4b,gt,OK);
brief_display_solution(asol4c,gt,OK);

figure(1); evalres = plot_solution(asol_out2,gt);
figure(2); evalres = plot_solution(asol3,gt);
figure(3); evalres = plot_solution(asol3b,gt);
figure(4); evalres = plot_solution(asol3c,gt);
figure(5); evalres = plot_solution(asol4a,gt);
figure(6); evalres = plot_solution(asol4c,gt);

%evaluate_solution(asol_out2,gt,OK);


