function dirname = r_out_paths(type)
    base_dir = fullfile(fileparts(which(mfilename)), '..');
    switch type
        case 'cache', dirname = fullfile(guru_getOutPath('cache'), 'ringo');
        %case 'plot', dirname = fullfile(guru_getOutPath('results'), 'ringo');
        %case '', fullfile(base_dir,'runs');
        otherwise,    dirname = guru_getOutPath(type);
    end;
