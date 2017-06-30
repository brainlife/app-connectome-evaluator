function main

%if exist('/N/u/hayashis/BigRed2/git', 'dir') == 7
%if exist('/home/hayashis/git', 'dir') == 7
switch getenv('ENV')
case 'IUHPC'
    disp('loading paths (HPC)')
    addpath(genpath('/N/u/hayashis/BigRed2/git/encode-mexed'))
    addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
    addpath(genpath('/N/u/hayashis/BigRed2/git/mba'))
    addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))

    addpath(genpath('/N/u/hayashis/Karst/testdata/demo_data_encode'))
case 'VM'
    disp('loading paths (VM)')
    addpath(genpath('/usr/local/encode-mexed'))
    addpath(genpath('/usr/local/vistasoft'))
    addpath(genpath('/usr/local/mba'))
    addpath(genpath('/usr/local/jsonlab'))

    addpath(genpath('/usr/local/demo_data_encode'))
end

config = loadjson('config.json');
disp(config)

disp('Running connectome_evaluator...')
[fh, out] = connectome_evaluator(config);

% all sca service needs to write products.json - empty for now
savejson('',     out, 'FileName', 'out.json');
savejson('w',    out.nnz,         'life_connectome_density.json');
savejson('rmse', out.rmse,        'life_error.json');
saveas(fh, 'figure1.png')

% TODO - generate output
savejson('',     {}, 'products.json');
system('echo 0 > finished');

end
