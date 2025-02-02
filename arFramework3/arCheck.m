% check systems setup
% addpath and configure sundials

function docontinue = arCheck

symbtool = ver('symbolic');
if(~isempty(symbtool) && verLessThan('symbolic', '5.5'))
	error('MUPAD symbolic toolbox version >= 5.5 required');
end

ar_path = fileparts(which('arInit.m'));

warning('off','MATLAB:rmpath:DirNotFound')

% add all subfolders of arFramework3 folder to MATLAB search path
if(exist([ar_path,'/PM'], 'dir'))
    rmpath(genpath( [ar_path,'/PM']))
    arFprintf(2, 'arCheck.m: rm PM from matlab path\n');
end

% removes Examples folder and subfolders of arFramework3 from the MATLAB
% serach path to avoid loading data from those examples for accidentially
% identical file names
rmpath(genpath([ar_path '/Examples']))

warning('on','MATLAB:rmpath:DirNotFound')

% load path of sub-directories
if(exist('pleInit','file') == 0)
    addpath([ar_path '/PLE2'])
end
if(exist('doPPL','file') == 0)
    addpath([ar_path '/PPL'])
end
if(exist('fileChooser','file') == 0)
    addpath([ar_path '/arTools'])
end
if(exist('l1Init','file') == 0)
    addpath([ar_path '/l1'])
end

[has_git, is_repo] = arCheckGit(ar_path);

% check if submodules have been pulled from github
submodules = {'matlab2tikz','https://github.com/matlab2tikz/matlab2tikz/zipball/3a1ee10';...
    'parfor_progress','https://github.com/dumbmatter/parfor_progress/zipball/fcb9d86';...
    'plot2svg','https://github.com/jschwizer99/plot2svg/zipball/839a919';...
    'export_fig','https://github.com/altmany/export_fig/zipball/d8131e4';...
    'Ceres/ceres-solver','https://github.com/ceres-solver/ceres-solver/zipball/8ea86e1';...
    'NL2SOL','https://github.com/JoepVanlier/mexNL2SOL/zipball/daabaac';...
    };
for jsm = 1:length(submodules)
    submodule = submodules{jsm,1};
    submod_dir = [ar_path '/ThirdParty/' submodule];
    url = submodules{jsm,2};
    if( (exist(submod_dir,'dir')==7 && isempty(ls(submod_dir))) || (~exist(submod_dir,'file')) )
        arFprintf(2,'Downloading submodule "%s" from github...',submodule);
        if(has_git && is_repo)
            % fetch submodule via git
            library_path = getenv('LD_LIBRARY_PATH');
            setenv('LD_LIBRARY_PATH', '');
            old_path = pwd;
            cd(ar_path);
            if(isunix)
                system('git submodule update --init --recursive >/dev/null 2>&1');
            else
                system('git submodule update --init --recursive >nul 2>&1');
            end
            cd(old_path);
            setenv('LD_LIBRARY_PATH', library_path);
        else
            % fetch submodule as zip file
            if(exist(submod_dir,'dir'))
                rmdir(submod_dir);
            end
            fname = [submod_dir '.zip'];
            arDownload(url, fname);
            dirnames = unzip(fname, [ar_path filesep 'ThirdParty']);
            dirnames = unique(cellfun(@fileparts,dirnames,'UniformOutput',false));
            dirname = dirnames{1};
            movefile(dirname, submod_dir);
            delete(fname);
        end
        arFprintf(2,' done!\n');
    end
end


% path of third party software
if(exist('JEInterface','file') == 0)
    addpath([ar_path '/ThirdParty/EvA2/JEInterface'])
    javaaddpath([ar_path '/ThirdParty/EvA2/EvA2Base.jar'])
end
if(exist('suptitle','file') == 0)
    addpath([ar_path '/ThirdParty/BlandAltman'])
end
if(exist('export_fig','file') == 0)
    addpath([ar_path '/ThirdParty/export_fig'])
end
if(exist('plot2svg','file') == 0)
    addpath([ar_path '/ThirdParty/plot2svg/src'])
end
if(exist('matlab2tikz','file') == 0)
    addpath([ar_path '/ThirdParty/matlab2tikz/src'])
end
if(exist('parfor_progress','file') == 0)
    addpath([ar_path '/ThirdParty/parfor_progress'])
end
if (exist('compileNL2SOL', 'file') == 0)
    addpath([ar_path '/ThirdParty/NL2SOL'])
end
if (exist('mota', 'file') == 0)
    addpath([ar_path '/ThirdParty/MOTA'])
end
if (exist('arTRESNEI', 'file') == 0)
    addpath([ar_path '/ThirdParty/TRESNEI'])
end
if (exist('compileCeres', 'file') == 0)
    addpath([ar_path '/ThirdParty/Ceres'])
end
if (exist('TranslateSBML', 'file') == 0)
    addpath([ar_path '/ThirdParty/libSBML'])
end
if (exist('fminsearchbnd', 'file') == 0)
    addpath([ar_path '/ThirdParty/FMINSEARCHBND'])
end

%% CVODES

% uncompress and expand CVODES
if(exist([ar_path '/sundials-2.6.1'],'dir') == 0)
    path_backup = cd;
    cd(ar_path);
    untar('sundials-2.6.1.tar');
    cd(path_backup);
end

% write sundials_config.h
if(exist([ar_path '/sundials-2.6.1/include/sundials/sundials_config.h'],'file') == 0)
    fid = fopen([ar_path '/sundials-2.6.1/include/sundials/sundials_config.h'], 'W');
    if(fid==-1)
        error('could not write file %s!', [ar_path '/sundials-2.6.1/include/sundials/sundials_config.h']),
    end
    fprintf(fid, '#define SUNDIALS_PACKAGE_VERSION "2.6.1"\n');
    fprintf(fid, '#define SUNDIALS_DOUBLE_PRECISION 1\n');
    fprintf(fid, '#define SUNDIALS_USE_GENERIC_MATH\n');
    fprintf(fid, '#define SUNDIALS_BLAS_LAPACK 0\n');
    fprintf(fid, '#define SUNDIALS_EXPORT\n');
    fclose(fid);
end

%% SuiteSparse 4.2.1

% uncompress and expand KLU solver
if(exist([ar_path '/KLU-1.2.1'],'dir') == 0)
    path_backup = cd;
    cd(ar_path);
    untar('KLU-1.2.1.tar');
    cd(path_backup);
end


%% check Windows libraries for pthread-win32
if(ispc)
%     if(exist(['.\pthreadGC2_',mexext,'.dll'],'file')==0)
    try
        copyfile([ar_path '\pthreads-w32_2.9.1\dll\' mexext '\pthreadGC2.dll'], ['pthreadGC2.dll']);
    catch ERR  % occurs (and can be ignored), if dll has been copied previously, is still loaded and therefore replacement is blocked by Windows OS
        disp(ERR.message)
    end
%     end
%     if(exist(['.\pthreadVC2_',mexext,'.dll'],'file')==0)
    try
        copyfile([ar_path '\pthreads-w32_2.9.1\dll\' mexext '\pthreadVC2.dll'], ['pthreadVC2.dll']);
    catch ERR  % occurs (and can be ignored), if dll has been copied previously, is still loaded and therefore replacement is blocked by Windows OS
        disp(ERR.message)
    end
%     end
end

%% user name

% check if arInitUser.m exists and create the file if necessary
if exist('arInitUser.m','file')==0
	fprintf(1,'\n%s\n\n','Welcome to Data 2 Dynamics Software');
	user = '';
	while isempty(user)
		user = input('Please enter your full name (e.g. John Doe)\n-> ','s');
	end
	fid = fopen([ar_path '/arInitUser.m'],'w');
    if(fid==-1)
        error('could not write file %s!', [ar_path '/arInitUser.m']),
    end
	fprintf(fid,'%s\n','% initialize user settings');
	fprintf(fid,'\n%s\n','function arInitUser');
	fprintf(fid,'\n%s\n','global ar');
	fprintf(fid,'\n%s%s%s','ar.config.username = ''',user,''';');
	fprintf(fid,'\n%s%s%s','ar.config.comment_string = ''//'';');
	fclose(fid);
	fprintf(1,'\n%s\n','Initialization successful');
    fprintf(1,'Please note that you can set additional default options in arInitUser.m\n' );
    rehash path
end

docontinue = true;
