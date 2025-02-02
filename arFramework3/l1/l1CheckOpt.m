% L1 check optimum
% After most parsimoneous model is found, do single PLE for each non-specific
% parameter included in the fitted set to check if others cross 0 at
% re-optimization. If so, this parameter could also be cell-type specific.
% jks       relative parameters to be investigated by L1 regularization
% linv      width, i.e. inverse slope of L1 penalty (Inf = no penalty; small values = large penalty)
% gradient  use a small gradient on L1 penalty ([-1 0 1]; default = 0)

function l1CheckOpt(jks)

global ar
global pleGlobals

if(isempty(ar))
    error('please initialize by arInit')
end

if(~exist('jks','var') || isempty(jks))
    if(~isfield(ar,'L1jks') || isempty(ar.L1jks))
        error('please initialize by l1Init, run l1Scan, and l1Unpen')
    end
end
jks = ar.L1jks;

fixed_jks = find(abs(ar.L1ps(ar.L1final_ind,jks)) <= 1e-4);

ar.p = ar.L1ps_unpen(ar.L1final_ind,:);
ar.type(jks) = 0;
ar.qFit(jks) = 1;
ar.qFit(jks(fixed_jks)) = 2;

arPLEInit
for jk = 1:length(jks)
    pleGlobals.p = ar.L1ps_unpen(ar.L1final_ind,:);
    pleGlobals.q_fit(jks) = 1;
    pleGlobals.q_fit(jks(fixed_jks)) = 0;
    pleGlobals.q_fit(jks(jk)) = 1;
    ar.qFit(jks) = 1;
    ar.qFit(jks(fixed_jks)) = 2;
    ar.qFit(jks(jk)) = 1;
    
%     arFit(true)
%     arPLEInit
    
    do_plotting = pleGlobals.showCalculation;
    pleGlobals.showCalculation = false;
    ple(jks(jk),50,0.1,0.1,0.1)
    pleGlobals.showCalculation = do_plotting;
    
    ar.L1psPLE{jks(jk)} = pleGlobals.ps{jks(jk)};
    ar.L1chi2sPLE{jks(jk)} = pleGlobals.chi2s{jks(jk)};
    not_profiled = setdiff(jks,jks(jk));
    pleSigns = sign(ar.L1psPLE{jks(jk)}(:,not_profiled));
    exchange_jk = find(max(pleSigns)-min(pleSigns) == 2);
    if ~isempty(exchange_jk)
        fprintf('Parameter #%i: ''%s'' could be exchanged by #%i: ''%s''\n',jks(jk),ar.pLabel{jks(jk)},not_profiled(exchange_jk),ar.pLabel{not_profiled(exchange_jk)});
    end
end