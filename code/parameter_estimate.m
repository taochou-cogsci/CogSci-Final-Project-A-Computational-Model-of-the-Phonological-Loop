% this script is to estimate the parameters
% to best fit the raw data

function [decRate, minAct, actDec, assocStrength] = parameter_estimate(decayType, rehearseType, actDiff, assocRetrieval)
    if strcmp(decayType, 'linear')
        DecRate = linspace(0, 1, 21);
        MinAct = 0;
    else
        DecRate = linspace(0.2, 0.8, 31);
        MinAct = linspace(0.2, 0.8, 31);  % 51
    end
       
    if strcmp(actDiff, 'on')
        ActDec = linspace(0.01, 0.19, 19);
    else
        ActDec = 0;
    end

    if strcmp(assocRetrieval, 'on')
        AssocStrength = linspace(0.01, 0.19, 19);
    else
        AssocStrength = 0;
    end

    [DR, MA, AD, AS] = ndgrid(DecRate, MinAct, ActDec, AssocStrength);

    numComb = numel(DR);
    minRMSD = 10000;
    %RMSD = zeros(length(DecRate), length(MinAct), length(ActDec), length(AssocStrength));

    for idx = 1:numComb
        currDecRate = DR(idx);
        currMinAct = MA(idx);
        currActDec = AD(idx);
        currAssocStrength = AS(idx);

        % pos1 = mod(idx - 1, length(DecRate)) + 1;
        % pos2 = mod(idx - 1, length(MinAct)) + 1;
        % pos3 = mod(idx - 1, length(ActDec)) + 1;
        % pos4 = mod(idx - 1, length(AssocStrength)) + 1;

        RMSD = run_model(decayType, rehearseType, actDiff, assocRetrieval, ...
            currDecRate, currMinAct, currActDec, currAssocStrength, 1);

        if RMSD < minRMSD
            decRate = currDecRate;
            minAct = currMinAct;
            actDec = currActDec;
            assocStrength = currAssocStrength;
            minRMSD = RMSD;
            fprintf('adjust parameters:\n');
            fprintf('decRate: %.3f, minAct: %.3f, actDec: %.3f, assocStrength: %.3f\n', ...
                decRate, minAct, actDec, assocStrength);
            fprintf('minRMSD: %.4f\n', minRMSD);
        end

    end
    
    fprintf('final defined parameters:\n');
    fprintf('decRate: %.3f, minAct: %.3f, actDec: %.3f, assocStrength: %.3f\n', ...
            decRate, minAct, actDec, assocStrength);
    fprintf('minRMSD: %.4f\n', minRMSD);

end