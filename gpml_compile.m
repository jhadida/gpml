function gpml_compile( cpp_comp, fortran_comp, lbfgsb_ver )
%
% gpml_compile( cpp_comp=g++, fortran_comp=gfortran, lbfgsb_ver=3.0 )
%
% Compile GPML sources (C/Fortran) prior to running the optimisation.
% This requires the Deck library to be on the path (https://github.com/jhadida/deck).
%
% JH

    if nargin < 3, lbfgsb_ver = '3.0'; end
    if nargin < 2, fortran_comp='gfortran'; end
    if nargin < 1, cpp_comp='g++'; end

    % Substitutions
    sub.Cpp_Comp = cpp_comp;
    sub.Fortran_Comp = fortran_comp;
    sub.Fortran_Libs = fortran_libs();
    sub.LBFGSB_obj = lbfgsb_obj(lbfgsb_ver);
    sub.Matlab_Root = matlabroot;
    sub.Matlab_Arch = computer('arch');
    sub.Mex_Ext = mexext;
    
    % Build Makefile
    current = pwd;
    here = fileparts(mfilename('fullpath'));
    util = fullfile( here, 'gpml', 'util' );
    tpl = dk.str.Template( fullfile(here,'Makefile.tpl'), true );
    back = fullfile(util,'lbfgsb','Makefile.old');
    dest = fullfile(util,'lbfgsb','Makefile');
    
    % Compile solve_chol
    dk.disp('Compiling solve_chol...');
    cd(util);
    mex -O -lmwlapack solve_chol.c
    
    % Compile lbfgsb
    dk.disp('Compiling lbfgsb...');
    cd lbfgsb
    
    movefile(dest,back);
    dk.fs.puts( dest, tpl.substitute(sub), true );
    system('make');
    delete(dest);
    movefile(back,dest);
    
    % Compile minfunc
    dk.disp('Compiling minfunc...');
    cd ../minfunc
    if ~dk.fs.isdir('compiled')
        [s,m,k] = mkdir('compiled');
        assert( s == 1, 'Could not create folder: compiled' );
    end
    tomex = { 'lbfgsAddC.c', 'lbfgsC.c', 'lbfgsProdC.c', 'mcholC.c' };
    cellfun( @(f) mex('-O', '-outdir', 'compiled', fullfile('mex',f)), tomex );
    
    cd(current);
    
end

function obj = lbfgsb_obj( ver )

    if nargin < 1, ver='default'; end

    switch ver
        
        case {'2.4'}
            obj = {'solver_2_4.o'};
            
        case {'3.0','default'}
            obj = { 'solver_3_0.o', 'linpack.o', 'timer.o', 'blas.o' };
        
    end
    
    obj = strjoin(obj,' ');
    
end

function lib = fortran_libs()

    lib = '-lgfortran';
    
    % On standard Xcode install with Xcode 4.2, libgfortran cannot be found
    % This shouldn't hurt for earlier versions
    if ismac
        [s,o] = system('gfortran --print-file-name libgfortran.dylib');
        assert( s==0, 'gfortran does not seem to be installed' );
        lib = ['-L' dk.fs.realpath(fileparts(o)) ' ' lib];
    end

end
