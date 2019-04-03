function gpml_start()
%
% gpml_start()
%
% Add GPML sources to the path.

    if isempty(which('gp'))
        dirs = gpml_path();
        addpath(dirs{:});
    end

end
