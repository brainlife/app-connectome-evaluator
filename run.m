
disp('loading path')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/mba'))

%disp("loading demo data")
%addpath(genpath('/N/dc2/scratch/hayashis/sca/demo_data_encode'))

config = loadjson('config.json')
disp(config)

%run the app
%connectome_data_comparison
