% arImportPars(pStruct)
% arImportPars(pStruct, pars_only, pattern, fixAssigned)
% arImportPars(pStruct, pars_only, pattern, fixAssigned, ar)
% 
% 
%   Used by arLoadPars
% 
%   ar      ar-Struct if the parameters should not be imported into the
%           global ar
%           If empty or not provided, then the global ar is used.

function varargout = arImportPars(pStruct, pars_only, pattern, fixAssigned, ar)
if(~exist('fixAssigned', 'var') || isempty(fixAssigned))
    fixAssigned = false;
end
if(~exist('pars_only', 'var') || isempty(pars_only))
    pars_only = false;
end
if(~exist('pars_only', 'var') || isempty(pars_only))
    pars_only = false;
end
if(~exist('pattern', 'var') || isempty(pattern))
    pattern = [];
end
if(~exist('ar', 'var') || isempty(ar))
    global ar
end

N = 1000;  % Number of output message lines.

if(isempty(pattern))
    js = 1:length(ar.p);
else
    js = find(~cellfun(@isempty,regexp(ar.pLabel, pattern)));
end

ass = zeros(size(ar.p));
for j=js
    qi = ismember(pStruct.pLabel, ar.pLabel{j});
    
    if(isempty(qi) || sum(qi) == 0)
        ass(j) = 0;
        if(length(ar.p)<=N)
            arFprintf(1, '                      %s\n', ar.pLabel{j});
        end
    else
        ass(j) = 1;
        if(~pars_only)
            ar.p(j) = pStruct.p(qi);
            ar.qLog10(j) = pStruct.qLog10(qi);
            ar.qFit(j) = pStruct.qFit(qi);
            ar.lb(j) = pStruct.lb(qi);
            ar.ub(j) = pStruct.ub(qi);
            if isfield(pStruct,'type')
                ar.type(j) = pStruct.type(qi);
            end
            if isfield(pStruct,'mean')
                ar.mean(j) = pStruct.mean(qi);
            end
            if isfield(pStruct,'std')
                ar.std(j) = pStruct.std(qi);
            end
        else
            if(ar.qLog10(j) == pStruct.qLog10(qi))
                ar.p(j) = pStruct.p(qi);
            elseif(ar.qLog10(j)==1 && pStruct.qLog10(qi)==0)
                ar.p(j) = log10(pStruct.p(qi));
            elseif(ar.qLog10(j)==0 && pStruct.qLog10(qi)==1)
                ar.p(j) = 10^(pStruct.p(qi));
            end
            
            % check bound
            ar.p(ar.p<ar.lb) = ar.lb(ar.p<ar.lb);
            ar.p(ar.p>ar.ub) = ar.ub(ar.p>ar.ub);
        end
        
        if(fixAssigned)
            ar.qFit(j) = 0;
            if(length(ar.p)<=N)
                arFprintf(1, 'fixed and assigned -> %s\n', ar.pLabel{j});
            end
        else
            if(length(ar.p)<=N)
                arFprintf(1, '          assigned -> %s\n', ar.pLabel{j});
            end
        end
    end
end

nnot = length(ass)-sum(ass);
if ( nnot > 0 )
    arFprintf(1, '%i parameters were assigned in the destination model (%i not assigned).\n',sum(ass),nnot);
    if(nnot<=30 && nnot>0)
        arFprintf(1, 'Not assigned are: %s \n',sprintf('%s, ',ar.pLabel{ass==0}));
    end
else
    arFprintf(1, 'All parameters assigned.\n');
end

nnot = length(pStruct.p)-sum(ass);
if ( nnot > 0 )
    arFprintf(1, 'There were %i more parameters in the loaded struct than in the target model.\n',nnot);
end

if nargout>0
    varargout{1} = ar;
end