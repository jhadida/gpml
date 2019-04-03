function gpml_stop()
%
% gpml_stop()
%
% Remove GPML sources from the path.

    if isempty(which('gp'))
        return;
    end

    dirs = gpml_path();
    rmpath(dirs{:});

end
