% Implementation of the phonological loop for 
% Lewandowsky and Farrell's
% "Computational Modeling in Cognition: Principles and Practice"

% Revised by Tao, Gary, Wenshuo
% for COGSCI001, Berkeley, 2025

clear all
model_gui();

function model_gui()
    % Create figure
    fig = figure('Name','Cognitive Model Settings','Position',[500 300 500 300]);

    % Decay function dropdown
    % Decay Function radio buttons
    uicontrol(fig,'Style','text','Position',[30 250 120 10],'String','Decay Function:');
    decayGroup = uibuttongroup(fig,'Position',[0.4 0.78 0.4 0.1]);
    uicontrol(decayGroup,'Style','radiobutton','String','exponential','Position',[10 5 100 20]);
    uicontrol(decayGroup,'Style','radiobutton','String','linear','Position',[120 5 80 20]);
    
    % Rehearse Order radio buttons
    uicontrol(fig,'Style','text','Position',[30 210 120 10],'String','Rehearse Order:');
    rehearseGroup = uibuttongroup(fig,'Position',[0.4 0.64 0.4 0.1]);
    uicontrol(rehearseGroup,'Style','radiobutton','String','head to tail','Position',[10 5 100 20]);
    uicontrol(rehearseGroup,'Style','radiobutton','String','random','Position',[120 5 80 20]);

    % Activation difference radio buttons
    uicontrol(fig,'Style','text','Position',[30 170 150 10],'String','Activation Difference:');
    actGroup = uibuttongroup(fig,'Position',[0.4 0.52 0.4 0.1]);
    uicontrol(actGroup,'Style','radiobutton','String','on','Position',[10 5 50 20]);
    uicontrol(actGroup,'Style','radiobutton','String','off','Position',[70 5 50 20]);

    % Associative retrieval radio buttons
    uicontrol(fig,'Style','text','Position',[30 130 150 10],'String','Associative Retrieval:');
    assocGroup = uibuttongroup(fig,'Position',[0.4 0.37 0.4 0.1]);
    uicontrol(assocGroup,'Style','radiobutton','String','on','Position',[10 5 50 20]);
    uicontrol(assocGroup,'Style','radiobutton','String','off','Position',[70 5 50 20]);

    % Run button
    uicontrol(fig,'Style','pushbutton','Position',[150 50 100 30],'String','Run Model',...
        'Callback',@runCallback);

    % Callback function for the button
    function runCallback(~,~)

        decayType = decayGroup.SelectedObject.String;
        rehearseType = rehearseGroup.SelectedObject.String;
        actDiff = actGroup.SelectedObject.String;
        assocRetrieval = assocGroup.SelectedObject.String;

        

        [decRate, minAct, actDec, assocStrength] = parameter_estimate(decayType, rehearseType, actDiff, assocRetrieval);

        % Run the model (call to your run_model function)
        figure;
        run_model(decayType, rehearseType, actDiff, assocRetrieval, decRate, minAct, actDec, assocStrength, 0, 1);
        run_model(decayType, rehearseType, actDiff, assocRetrieval, decRate, minAct, actDec, assocStrength, 1, 1);
        close(fig);
    end
end
