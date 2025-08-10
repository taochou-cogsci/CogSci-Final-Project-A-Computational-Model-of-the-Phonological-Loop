% this script is to run the computational model
% when all the parameters involved are reasonably defined

function RMSD = run_model(decayType, rehearseType, actDiff, assocRetrieval, decRate, minAct, actDec, assocStrength, Istest, Ispicture)
    
    % parameters:
    % 1 decayType: linear, exponential
    % 2 rehearseType: head to tail, random 
    % 3 actDiff: off, on
    % 4 assocRetrieval: off, on
    % 5 decRate
    % 6 minAct
    % 7 actDec
    % 8 assocStrength
    % 9 Istest: off (all points), on (test points)
    % 10 Ispicture: off (without picture), on (with picture)

    nReps = 1000;        %number of replications
    listLength = 5;     %number of list items
    delay = 5;          %retention interval (seconds)

    if strcmp(actDiff, 'off')
        initAct = [1 1 1 1 1];
        decSD = decRate/3;         %standard deviation of decay rate %*\label{line:decSD}*\%
    else
        initAct = 1 - (1:listLength) * actDec;
        decSD = decRate/6;         %standard deviation of decay rate %*\label{line:decSD}*\%
    end
        

    if ~Istest      
        rRange = linspace(1.5,4.,15);   %*\label{line:rRange2}*\%
    else
        rRange = [1.64 1.92 2.33 2.64 3.73 3.94]; % if it's evaluation, we'll use raw data
    end
    
    tRange = 1./rRange;
    pCor = zeros(size(rRange));
    
    i=1;                %index for word lengths
    for tPerWord=tRange

        if Istest & strcmp(assocRetrieval, 'on')
            if i <= 2
                Cos_Sim = load('long_matrix.mat').long_matrix;
            elseif i <= 4
                Cos_Sim = load('medium_matrix.mat').medium_matrix;
            else
                Cos_Sim = load('short_matrix.mat').short_matrix;
            end
        end
    
        for rep=1:nReps
            if Istest & strcmp(assocRetrieval, 'on')  % shuffle the cos_sim to simulate the random choice of words         
                idx = randperm(6,5);            
                cos_sim = Cos_Sim(idx, idx);  
            end

            actVals = initAct;
            dRate = decRate+randn*decSD;   %*\label{line:newdRate}*\%
    
            cT = 0;
            itemReh = 0; 
            clock = zeros(1,5);
            temp = -1;
            while cT < delay   
                intact = find(actVals>minAct);

                if isempty(intact)
                    break;
                end

                if strcmp(rehearseType, 'random') 
                    if length(intact) > 1
                        while 1
                            itemReh = intact(randi(length(intact)));
                            if itemReh ~= temp
                                temp = itemReh; % to ensure we won't immediately rehearse the last word
                                break;
                            end
                        end

                    elseif ~isempty(intact)
                        itemReh = intact(1);

                    end
                    
                else
                    itemReh = find(intact>itemReh, 1);
                end

                if isempty(itemReh)
                    itemReh=intact(1);
                end

                actVals(itemReh) = 1;

                if Istest & strcmp(assocRetrieval, 'on')
                    actVals(intact) = actVals(intact) + (assocStrength .* cos_sim(itemReh, intact));
                    actVals(actVals > 1) = 1;
                end
                
                clock(itemReh) = cT;
            
                % everything decays
                if strcmp(decayType, 'exponential')
                    initAct(itemReh) = 1;
                    actVals = initAct .* exp(-dRate * (cT-clock));
                else 
                    actVals = actVals - (dRate .* tPerWord);
                end

                cT=cT+tPerWord; 
            end
            pCor(i) = pCor(i) + (sum(actVals>minAct)./listLength); 
        end
        i=i+1;
    end 
    

    Y = [0.34, 0.48, 0.52, 0.70, 0.74, 0.82];

    if Ispicture == 1
        if Istest == 0
            subplot(1, 2, 1);
        elseif Istest == 1
            subplot(1, 2, 2);
        end

        scatter(rRange,pCor./nReps,'s','filled','MarkerFaceColor','k')
        hold on
        if Istest == 1
            scatter(rRange,Y,'x','MarkerEdgeColor','r', 'LineWidth', 1)
        end
        xlim([1 4.5])
        ylim([0 1])
        xlabel('Speech Rate')
        ylabel('Proportion Correct')
    end

    if Istest     
       RMSD = sqrt(sum((Y - pCor ./ nReps).^2) / length(rRange));
       disp(RMSD)
    end
    

    %the following code works on SL home machine running vista; the coordinates
    %are screen-specific
    %I = getframe(gcf,[-4,-4,569,504]);
    %imwrite(I.cdata, 'WLEsim2.jpg');

end