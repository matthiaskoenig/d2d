% arQlogParameters(whichone,newval)
% 
%   This function can be used to change ar.qLog10
%   The parameter values (ar.p), upper and lower bounds (ar.lb, ar.ub) are
%   updated accordingly.
% 
% 
%   Examples:
% arQlogParameters(1,1) % log-trsf of the first parameters (if not already done)
% 
% arQlogParameters(1,0) % inverse log-trsf of the first parameters (if not already done)
% 
% arQlogParameters('init_Epo',1) % log-trsf of parameter 'init_Epo' (if not already done)
% 
% arQlogParameters([1,3,4],1) % log-trsf of the parameters 1, 3, 4 (if not already done)

function arQlogParameters(whichone,newval)
global ar

if ischar(whichone)
    jp = find(strcmp(ar.pLabel,whichone));
    if length(jp)~=1        
        error('No unique hit for parameter ''%s''',whichone);
    end
elseif isnumeric(whichone)
    if length(whichone)>1
        if length(newval)==1
            newval = newval*ones(size(whichone));
        elseif length(newval)~=length(whichone)
            error('length(newval)~=length(whichone)')
        end
        for i=1:length(whichone)
            arQlogParameters(whichone(i),newval(i));
        end
        return
    else
        jp = whichone;
    end
else
    error('Please specify parameters either by name (according to ar.pLabel) or by index.');
end


if(newval == 1)
    if(ar.qLog10(jp)==0)
        ar.qLog10(jp) = true;
        if(ar.p(jp)<=1e-10)
            ar.p(jp) = -10;
        else
            ar.p(jp) = log10(ar.p(jp));
        end
        if(ar.lb(jp)<=1e-10)
            ar.lb(jp) = -10;
        else
            ar.lb(jp) = log10(ar.lb(jp));
        end
        ar.ub(jp) = log10(ar.ub(jp));
        ar.mean(jp) = log10(ar.mean(jp));
    else
        fprintf('Parameter %s is already treated on the log-scale. Nothing changed.\n',ar.pLabel{jp});        
    end
else
    if(ar.qLog10(jp)==1)
        ar.qLog10(jp) = false;
        ar.p(jp) = 10^(ar.p(jp));
        ar.lb(jp) = 10^(ar.lb(jp));
        ar.ub(jp) = 10^(ar.ub(jp));
        ar.mean(jp) = 10^(ar.mean(jp));
    else
        fprintf('Parameter %s is already treated on the non-logarithmic scale. Nothing changed.\n',ar.pLabel{jp});
    end
end

