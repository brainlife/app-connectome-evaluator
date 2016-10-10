
disp('loading application paths')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/mba'))
addpath('lib')

%disp("loading demo data")
%addpath(genpath('/N/dc2/scratch/hayashis/sca/demo_data_encode'))

config = loadjson('config.json')
disp(config)

disp('running connectome_data_comparison')
connectome_data_comparison(config)
