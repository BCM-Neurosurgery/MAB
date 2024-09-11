% Function called by: StartUp.m
% Role of function is to initialize PsychToolBox and the Screen for the experiment  
% Parameters: 
%   - Pars (A handle to the parameters)
% Return Values: None

function SetUpScreen(Pars)
    % Startup PsychToolBox 
    PsychDefaultSetup(2);

    % Set some settings to make sure PTB works fine.
    % Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference', 'SuppressAllWarnings', 1);     % Gets rid of all Warnings
    Screen('Preference', 'Verbosity', 0);               % Gets rid of all PTB-related messages
    Screen('Preference', 'SkipSyncTests', 2);           % Synchronization is nice, but not skipping the tests can randomly crash the program 
    
    % Create the window in which we will operate
    [Pars.screen.window, ~] = Screen('OpenWindow', Pars.screen.screen, Pars.screen.color);

    % Get Physical Size of Display Screen (in inches)  JA 2024/15/08
    [dispWidth,dispHeight] = Screen('DisplaySize',Pars.screen.screen);
    Pars.screen.dispWidth = round(dispWidth/25.4);
    Pars.screen.dispHeight = round(dispHeight/25.4);

    % Set Size of Photodiode Square (in pixels)
    Pars.photodiode.sizePx = round(Pars.screen.window_width/Pars.screen.dispWidth*Pars.photodiode.size);

    %Set up text Preferences
    Screen('TextFont', Pars.screen.window, Pars.text.font.default);
end

