% this script is to estimate the parameters
% to best fit the raw data

function [decRate, minAct, actDec, assocStrength] = parameter_estimate(decayType, rehearseType, actDiff, assocRetrieval)
    
    % parameters:
    % 1 decayType: linear, exponential
    % 2 rehearseType: head to tail, random 
    % 3 actDiff: off, on
    % 4 assocRetrieval: off, on

    if strcmp(decayType, 'linear')
        DecRate = linspace(0, 1, 101);
        MinAct = 0;
    else
        if strcmp(actDiff, 'off') & strcmp(assocRetrieval, 'off')
            DecRate = linspace(0, 1.5, 151);
            MinAct = linspace(0, 1, 101);

        else
            
            DecRate = linspace(0.1, 0.9, 81);
            MinAct = linspace(0.1, 0.9, 81);

        end

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
    RMSD = zeros(length(DecRate), length(MinAct), length(ActDec), length(AssocStrength));

    for idx = 1:numComb

        currDecRate = DR(idx);
        currMinAct = MA(idx);
        currActDec = AD(idx);
        currAssocStrength = AS(idx);

        [pos1, pos2, pos3, pos4] = ind2sub(size(DR), idx);

        RMSD(pos1, pos2, pos3, pos4) = run_model(decayType, rehearseType, actDiff, assocRetrieval, ...
            currDecRate, currMinAct, currActDec, currAssocStrength, 1, 0);

        if RMSD(pos1, pos2, pos3, pos4) < minRMSD
            decRate = currDecRate;
            minAct = currMinAct;
            actDec = currActDec;
            assocStrength = currAssocStrength;
            minRMSD = RMSD(pos1, pos2, pos3, pos4);
        end

    end
    
    fprintf('final defined parameters:\n');
    fprintf('decRate: %.3f, minAct: %.3f, actDec: %.3f, assocStrength: %.3f\n', ...
            decRate, minAct, actDec, assocStrength);
    fprintf('minRMSD: %.4f\n', minRMSD);

    %% visualization
    if strcmp(decayType, 'exponential') & strcmp(actDiff, 'on') & strcmp(assocRetrieval, 'off')
        % 3 parameters estimation: DecRate, MinAct, ActDec

        RMSD = permute(RMSD, [2, 1, 3]);

        % 1. Heat-Map with multiple slices（ActDec-fixed）
        figure('Position', [100, 100, 1000, 300]);
        sliceIndices = round(linspace(2,18,10)); % choose some slices
        for i = 1:length(sliceIndices)
            subplot(2,5,i);
            sliceIndex = sliceIndices(i);
            imagesc(DecRate, MinAct, RMSD(:,:,sliceIndex)');
            axis xy;
            caxis([0.02 0.42]); % Color scale uniform
            axis equal;
            xlim([0.1 0.9]);
            ylim([0.1 0.9]);
            colorbar;
            title(sprintf('Error at ActDec=%.2f', ActDec(sliceIndex)));
            xlabel('DecRate');
            ylabel('MinAct');
            set(gca, 'FontSize', 8);


        end
        
        % 2. 3D isosurface
        figure;
        isoVal = 0.1;
        % isoVal = 0.05;
        [DR, MA, AD] = meshgrid(DecRate, MinAct, ActDec);
        p = patch(isosurface(DR,MA,AD,RMSD,isoVal));
        isonormals(DR,MA,AD,RMSD,p);
        p.FaceColor = 'red';
        p.EdgeColor = 'none';
        alpha(0.5);
        daspect([1 1 1]);
        view(3); 
        camlight; lighting gouraud;
        xlabel('DecRate'); ylabel('MinAct'); zlabel('ActDec');
        title(sprintf('Isosurface at error = %.3f', isoVal));
        grid on;

    elseif strcmp(decayType, 'exponential') & strcmp(actDiff, 'off') & strcmp(assocRetrieval, 'on')
        % 3 parameters estimation: DecRate, MinAct, AssocStrength

        RMSD = squeeze(RMSD(:,:,1,:));
        RMSD = permute(RMSD, [2, 1, 3]);
        
        % 1. Heat-Map with multiple slices（ActDec-fixed）
        figure('Position', [100, 100, 1000, 300]);
        sliceIndices = round(linspace(2,18,10)); % choose some slices
        for i = 1:length(sliceIndices)
            subplot(2,5,i);
            sliceIndex = sliceIndices(i);
            imagesc(DecRate, MinAct, RMSD(:,:,sliceIndex)');
            axis xy;
            caxis([0.02 0.42]); % Color scale uniform
            axis equal;
            xlim([0.1 0.9]);
            ylim([0.1 0.9]);
            colorbar;
            title(sprintf('Error at AssocStrength=%.2f', AssocStrength(sliceIndex)));
            xlabel('DecRate');
            ylabel('MinAct');
            set(gca, 'FontSize', 8);

        end
        
        % 2. 3D isosurface
        figure;
        isoVal = 0.2;
        % isoVal = 0.1;
        [DR, MA, AS] = meshgrid(DecRate, MinAct, AssocStrength);
        p = patch(isosurface(DR,MA,AS,RMSD,isoVal));
        isonormals(DR,MA,AS,RMSD,p);
        p.FaceColor = 'red';
        p.EdgeColor = 'none';
        alpha(0.5);
        daspect([1 1 1]);
        view(3); 
        camlight; lighting gouraud;
        xlabel('DecRate'); ylabel('MinAct'); zlabel('AssocStrength');
        title(sprintf('Isosurface at error = %.3f', isoVal));
        grid on;

    elseif strcmp(decayType, 'exponential') & strcmp(actDiff, 'off') & strcmp(assocRetrieval, 'off')
        % 2 parameters estimation: DecRate, MinAct
        
        % Heat-Map
        figure;
        imagesc(DecRate, MinAct, RMSD');
        set(gca, 'YDir', 'normal');
        xlabel('DecRate');
        ylabel('MinAct');
        title('Model Error Heatmap');
        colorbar;
        blueToYellow = [linspace(0,1,256)', linspace(0,1,256)', linspace(0.8,0,256)'];
        colormap(blueToYellow);

        caxis([0.02 0.42]); % Color scale uniform
        axis equal;
        xlim([0 1.5]);
        ylim([0 1]);

        [~, ix] = min(abs(DecRate - decRate));
        [~, iy] = min(abs(MinAct - minAct));
        
        w = DecRate(2) - DecRate(1);
        h = MinAct(2) - MinAct(1);
       
        rectangle('Position', [DecRate(ix)-w/2, MinAct(iy)-h/2, w, h], ...
                  'EdgeColor', 'r', 'LineWidth', 2);
    end
end