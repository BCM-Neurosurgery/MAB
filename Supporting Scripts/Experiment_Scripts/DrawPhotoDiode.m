% Called by Experiment, Introduction, RunTrial and subscripts within those.
% Function that draws the photodiode and stores the time of the drawing for an event.        
% Input: 
%   - Pars   Parameters for the experiment
% Output: 
%   - time   When this happened
function time = DrawPhotoDiode(Pars)
%     photodiode_rect = [0, Pars.screen.window_height*(5/6), ...
%                         Pars.screen.window_width/11, Pars.screen.window_height];
    photodiode_rect = [0, Pars.screen.window_height-Pars.photodiode.sizePx, ...
                        Pars.photodiode.sizePx, Pars.screen.window_height];
    Screen('FillRect', Pars.screen.window, repmat(255, 1, 4), photodiode_rect);
    time = GetSecs();
end

% The function was initially meant to be larger, but I already
% incorporated it in the code, so I won't remove it to not break anything
% right now

% JA 2024/15/08 - Made modifications within the code and here to adjust the
% size of the displayed square. Inputs in the 'InsertParams' function have
% been added to specify the size of the photodiode square, and additions to
% the 'SetUpScreen' function allow proper calculation of square size
% relative to size of display screen.