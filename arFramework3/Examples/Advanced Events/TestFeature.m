fprintf( 'INTEGRATION TEST FOR EQUILIBRATION\n' );

fprintf( 2, 'Loading model for equilibration test...\n' );
try
    arInit;
    arLoadModel('equilibration');
    arLoadData('cond1', 1, 'csv');
    arLoadData('cond2a', 1, 'csv');
    arLoadData('cond2b', 1, 'csv');
   
    % Use the event system (prerequisite for steady state sims)
    ar.config.useEvents = 1;

    %% Compile the model
    arCompileAll(true);

    % Don't fit the standard deviation
    ar.qFit(end)=0;

    % Set the parameters to wrong values
    arSetPars('k_basal', 0);
    arSetPars('k_deg', -2);
catch ME
    fprintf(getReport(ME));
    error( 'FAILED' );
end

try
    %% Equilibrate condition 1 and use that as initial value for condition 1
    %  Equilibrate condition 2 and use that as initial condition for 2 and 3
    arClearEvents(ar); % Clears events
    arFindInputs;
    arSteadyState(ar, 1, 1, 1, -1e7);
    arSteadyState(ar, 1, 2, [2,3], -1e7);
catch ME
    fprintf(getReport(ME));
    error( 'FAILED SETTING UP STEADY STATE' );
end

try
    arFit;
    fprintf( 2, 'Testing fitting with equilibration event...\n' );
    if ((norm(ar.model.data(1).res)+norm(ar.model.data(2).res)+norm(ar.model.data(3).res))<0.01)
        fprintf('PASSED\n');
    else
        error( 'FAILED TO MEET REQUIRED TOLERANCE' );
    end
catch ME
    fprintf(getReport(ME));
    error( 'FAILED' );
end
