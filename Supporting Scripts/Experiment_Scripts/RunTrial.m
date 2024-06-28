% Function called by: Experiment.m
% Role of function is to run a trial of the experiment
% color_list.grey: 
%   - Parameters    (Things to be used for the experiment)
%   - Cpu           (The opponent that will be used for this trial)
%   - Duration      (How long the player has to react to the events on screen)
%   - Score_Row     (A list with the scores shuffled order for this Trial
%   - Instance_Idx  (Where in the trial we are)
%   - Layout        (Which layout to use)
%   - Trial_Total   (How much the player has scored so far in the trial)
% Return Values: 
%   - player_data   (Data on the player's performance)
%   - Trial_Total   (The updated total of all the trials)

function [player_data, cpu_data, Totals] = RunTrial(Parameters, Disbtn, Button_Scores, Cpu, Totals)
    %% PRE STAGE - Before the timer of the activity starts
    % Initialize some of the variables we need for storing
    [pl_score, cpu_score] = deal(0);
    [pl_choice, cpu_choice] = deal('Void');
    pl_time = -1;

    %% PRESENTATION STAGE - The trial begins    
    % Flip a coin on who starts first
    disp("NEW TRIAL")
    if rand() < 0.5
        [pl_score, pl_time, pl_choice, Totals.player] = player_turn(Parameters.screen.window, Parameters.target,...
                                                         Parameters.trial.duration_s, Disbtn.player,...
                                                         Button_Scores, Totals.player, Parameters.screen.window_width,...
                                                         Parameters.text.size.score_count);
        [cpu_score, cpu_choice, Totals.cpu] = cpu_turn(Parameters.screen.window, Parameters.target, Parameters.trial,...
                                                       Disbtn.cpu, Button_Scores, Cpu, Totals.cpu,...
                                                       Parameters.text.size.score_count);
    else
        [cpu_score, cpu_choice, Totals.cpu] = cpu_turn(Parameters.screen.window, Parameters.target, Parameters.trial,...
                                                       Disbtn.cpu, Button_Scores, Cpu, Totals.cpu,...
                                                       Parameters.text.size.score_count);
        [pl_score, pl_time, pl_choice, Totals.player] = player_turn(Parameters.screen.window, Parameters.target,...
                                                         Parameters.trial.duration_s, Disbtn.player,...
                                                         Button_Scores, Totals.player, Parameters.screen.window_width,...
                                                         Parameters.text.size.score_count);
    end


    
    %% POST STAGE - compile the data for export
    player_data = struct('score', pl_score, 'choice', pl_choice, 'time', pl_time);
    cpu_data = struct('score', cpu_score, 'choice', cpu_choice);
end


%% HELPER FUNCTIONS
function [pl_score, pl_time, pl_choice, Total] = player_turn(Win, Targ_Pars, Dur_S, Disbtn, Button_Scores, Total, Win_Width, Text_Size)
    load("colors.mat", "color_list");
    disp("Player turn ")

    % Create the text for the score
    score_text_total = sprintf('Your Turn\nTotal Score: %d', Total);
    score_text_cur = 'Current Score: ';
    
    % Variables for loop control
    break_loop = false;
    [pause_offset, score] = deal(0);
    start = GetSecs();
    elapsed_time = GetSecs() - start;
   
    while elapsed_time <= Dur_S && ~break_loop
        pc_input = GetXBox();
        
        % Draw the time that the player has left
        time_percent = max(0.002, 1 - elapsed_time/Dur_S);
        timebar_color = [0.8*(min(255*2*(1-time_percent),255)),...
                         0.8*(min(round(255*2*time_percent),255)), 0, 255];
        timeRect = [(1-time_percent)*Win_Width/2 , 0, Win_Width/2 + Win_Width/2 * time_percent, 10];
        Screen('FillRect', Win, color_list.black, [0,0,Win_Width,10]);
        Screen('FillRect', Win, timebar_color, timeRect);

        for button_idx = 1:length(Targ_Pars.button_names)
            color = Targ_Pars.colors(button_idx,:);
            if pc_input.(Targ_Pars.button_names(button_idx)) && ~break_loop
                color = color/0.8; 
                if ~strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                    choice = Targ_Pars.button_names(button_idx);
                    score = Button_Scores(button_idx);
                    score_text_total = sprintf('Your Turn\nTotal Score: %d', Total+score);
                    score_text_cur = sprintf('%s %d', score_text_cur, score);
                    break_loop = true;
                end
            end

            Screen('FillOval',Win, color, Targ_Pars.rects(button_idx,:));

            DrawIcon(Win, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                     Targ_Pars.rects(button_idx,:));

            if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                Screen('FillOval',Win, [50, 50, 50, 128], Targ_Pars.rects(button_idx,:));
            end
        end
        % Draw the text for the player to know
        Screen('TextSize', Win, Text_Size);
        DrawFormattedText(Win, score_text_total, 0, Text_Size+15, color_list.white);
        Screen('TextSize', Win, Text_Size + 15);
        DrawFormattedText(Win, score_text_cur, 0, 3*Text_Size+30, color_list.white);

        Screen('Flip', Win);

        elapsed_time = GetSecs()-pause_offset-start;
        if break_loop; break; end
    end

    % Get the data for the player to be returned
    pl_time = elapsed_time;
    pl_score = score;
    pl_choice = choice;
    Total = Total + score;
    WaitSecs(2);

end


function [cpu_score, cpu_choice, Total] = cpu_turn(Win, Targ_Pars, Trial_Pars, Disbtn, Button_Scores, Cpu, Total, Text_Size)
    load("colors.mat", "color_list");
    cpu_time = rand()* Trial_Pars.cpu_wait_dur + Trial_Pars.cpu_wait_s(1);

    % Create the text for the score
    score_text_total = sprintf('Player 2 Turn\nTotal Score: %d', Total);
    score_text_cur = 'Current Score: ';
    
    disp("Cpu - prechoice")
    for button_idx = 1:length(Targ_Pars.button_names)
        color = Targ_Pars.colors(button_idx,:);
        
        Screen('FillOval',Win, color, Targ_Pars.rects(button_idx,:));

        DrawIcon(Win, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                 Targ_Pars.rects(button_idx,:));

        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval',Win, [50, 50, 50, 128], Targ_Pars.rects(button_idx,:));
        end
    end
    Screen('TextSize', Win, Text_Size);
    DrawFormattedText(Win, score_text_total, 0, Text_Size+15, color_list.white);
    Screen('TextSize', Win, Text_Size + 15);
    DrawFormattedText(Win, score_text_cur, 0, 3*Text_Size+30, color_list.white);
    
    Screen('Flip', Win);
    
    cpu_choice = Cpu.getResponse();
    score_idx = Targ_Pars.button_names == cpu_choice;
    cpu_score = Button_Scores(score_idx);
    Cpu.changeBehavior();
    
    WaitSecs(cpu_time);
    
    disp("Cpu - postchoice")
    score_text_total = sprintf('Player 2 Turn\nTotal Score: %d', Total+cpu_score);
    score_text_cur = sprintf('%s %d', score_text_cur, cpu_score);

    for button_idx = 1:length(Targ_Pars.button_names)
        color = Targ_Pars.colors(button_idx,:);

        if strcmpi(Targ_Pars.button_names(button_idx), cpu_choice)
            if ~strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
                color = color / 0.8;
            end
        end

        Screen('FillOval',Win, color, Targ_Pars.rects(button_idx,:));

        DrawIcon(Win, ['Letter_', Targ_Pars.button_names(button_idx), '.png'],...
                 Targ_Pars.rects(button_idx,:));

        if strcmpi(Targ_Pars.button_names(button_idx), Disbtn)
            Screen('FillOval', Win, [50, 50, 50, 128], Targ_Pars.rects(button_idx,:));
        end
    end
    Screen('TextSize', Win, Text_Size);
    DrawFormattedText(Win, score_text_total, 0, Text_Size+15, color_list.white);
    Screen('TextSize', Win, Text_Size + 15);
    DrawFormattedText(Win, score_text_cur, 0, 3*Text_Size+30, color_list.white);

    Screen('Flip', Win);
    Total = Total + cpu_score;
    WaitSecs(2);
end