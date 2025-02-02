% load model parameters and parameter setting from .mat
% and reconcile with current parameters
%
% arLoadPars(filename, fixAssigned, only_values, path, pattern)
%
% filename:     source file name
%               or number according to the filelist
%               or a previously created global variable ar
% fixAssigned:  fix the assigned parameters
% only_values:  only load parameter values, not bound and status
% path:         path to the results folder, default: './Results'
% pattern:      search pattern for parameter names
% 
% 
% Examples for loading several parameter sets:
%   ars = arLoadPars({2,5});
%   [ars,ps] = arLoadPars({'Result1','ResultNr2'});
% 
% Examples for loading all parameter sets:
%   ars = arLoadPars('all');
%   [ars,ps] = arLoadPars('all');
%   arFits(ps)
% 
% Example:
%   arLoadPars('20141112T084549_model_fitted',[],[],'../OtherFolder/Results')

function varargout = arLoadPars(filename, fixAssigned, pars_only, pfad, pattern)
if(~exist('pfad','var') || isempty(pfad))
    pfad = './Results';
else
    if(strcmp(pfad(end),filesep)==1)
        pfad = pfad(1:end-1);
    end
end

global ar

if(~exist('fixAssigned', 'var') || isempty(fixAssigned))
    fixAssigned = false;
end
if(~exist('pars_only', 'var') || isempty(pars_only))
    pars_only = false;
end
if(~exist('pattern', 'var') || isempty(pattern))
    pattern = [];
end

if(~exist('filename','var') || isempty(filename))
    [~, filename] = fileChooser(pfad, 1, true);
elseif(isnumeric(filename)) % filename is the file-number
    [~, ~, file_list] = fileChooser(pfad, 1, -1);    
    filename = file_list{filename};
elseif(strcmp(filename,'end'))
    filelist = fileList(pfad);
    filename = filelist{end};
elseif(strcmp(filename,'all'))
    filename = fileList(pfad);
elseif ischar(filename)
    [~,filename]=fileparts(filename);    % remove path
end


if(~iscell(filename))    
    ar = arLoadParsCore(ar, filename, fixAssigned, pars_only, pfad, pattern);
    varargout = cell(0);
else
    ars = cell(size(filename));
    for i=1:length(filename)
        if(isnumeric(filename{i}))
            [~, ~, file_list] = fileChooser(pfad, 1, -1);
            file = file_list{filename{i}};
        else
            file = filename{i};
        end

        ars{i} = arLoadParsCore(ar, file, fixAssigned, pars_only, pfad, pattern);
    end
    varargout{1} = ars;
    if nargout>1
        ps = NaN(length(ars),length(ar.p));
        for i=1:length(ars)
            ps(i,:) = ars{i}.p;
        end
        varargout{2} = ps;
    end
end

% Invalidate cache so simulations do not get skipped
arCheckCache(1);

function ar = arLoadParsCore(ar, filename, fixAssigned, pars_only, pfad, pattern)

if(ischar(filename))
    filename_tmp = filename;
    
    filename = [pfad,'/' filename '/workspace.mat'];
    filename_pars = [pfad,'/' filename_tmp '/workspace_pars_only.mat'];
    if(exist(filename_pars,'file'))
        S = load(filename_pars);
    else
        S = load(filename);
    end
    arFprintf(1, 'parameters loaded from file %s:\n', filename);
elseif(isstruct(filename))
    S = struct([]);
    S(1).ar = filename;
else
    error('not supported variable type for filename');
end

ar = arImportPars(S.ar, pars_only, pattern, fixAssigned, ar);

