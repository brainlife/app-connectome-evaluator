function main
%
%
%
disp('loading application paths')

% TODO - move this to more permanent location - probably even /N/soft?
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/mba'))
addpath(genpath(fullfile(pwd,'lib')))

%disp("loading demo data")
addpath(genpath('/N/dc2/scratch/hayashis/sca/demo_data_encode'))

config = loadjson('config.json');
disp(config)

disp('running connectome_data_comparison')
connectome_evaluator(config)

%all sca service needs to write products.json - empty for now
products = [];
savejson('', products, 'FileName', 'products.json')
