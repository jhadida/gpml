function [dirs,root] = gpml_path()
%
% dirs = gpml_path()
%
% Returns cell-array of GPML folders to be added to/removed from the path.

    root = fileparts(mfilename('fullpath'));
    gpml = fullfile(root,'gpml');
    dirs = {'cov','doc','inf','lik','mean','prior','util'};
    subs = {{'util','minfunc'},{'util','minfunc','compiled'},{'util','lbfgsb'},{'util','sparseinv'}};
    
    dirs = cellfun( @(x) fullfile(gpml,x), dirs, 'UniformOutput', false );
    subs = cellfun( @(x) fullfile(gpml,x{:}), subs, 'UniformOutput', false );
    dirs = [ {gpml}, dirs, subs ];

end