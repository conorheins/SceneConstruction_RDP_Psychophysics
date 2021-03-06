function [el,inf] = EyeLinkON(Scr,inf)
if ~inf.dummy
    if ~EyelinkInit(inf.dummy)
        Scr('\nEyelink Init aborted.\n');
        CleanUpExpt(inf); return;
    end
    
    %
    % run EyelinkInit(0) if you want to just mess with EyeLink stuff
    %
    
    el=EyelinkInitDefaults(Scr.w);          % provide screen info to eyelink
    el.callback = [];                       % Disable Pp information
    el.helptext         = '';               % Disable instruction on top lest side
    el.backgroundcolour = Scr.gray;         % background-color when calibrating

    el.foregroundcolour = 0;                % foreground color when calibrating
    el.cal_target_beep(2)=0;                % the intensity of beeps
    el.calibration_failed_beep(2)=0;
    el.calibration_success_beep(2)=0;       % the intensity of beeps: success
    el.drift_correction_target_beep(2)=0;
    % el.drift_correction_failed_beep(2)=0.2;
    % el.drift_correction_success_beep(2)=0.2;
    el.feedbackbeep=0;                      % sound a beep after calibration/drift correction
    
    % For lower resolutions, you might have to play around with these values
    % a little. If you would like to draw larger targets on lower res
    % settings, please edit PsychEyelinkDispatchCallback.m and see comments
    % in the EyelinkDrawCalibrationTarget function
    el.calibrationtargetsize= .8;       % size of calibration dot
    el.calibrationtargetwidth=.2;       % width of borders
    % el.displayCalResults = 1;         % calibration results (only for validation)
    % el.eyeimgsize=50;                 % adjust the size of eye in exp. computer
    
    
    % set pupil Tracking model in camera setup screen
    % no = centroid. yes = ellipse
    Eyelink('command', 'use_ellipse_fitter = yes');
    Eyelink('command', 'active_eye = RIGHT');                 % set eye to record
    Eyelink('command', 'binocular_enabled = NO');
    Eyelink('command', 'enable_automatic_calibration = YES'); % YES default
    
    % This command is crucial to map the gaze positions from the tracker to
    % screen pixel positions to determine fixation
    Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, Scr.width-1, Scr.height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, Scr.width-1, Scr.height-1);
    
    Eyelink('command', 'calibration_type = HV13'); % 13 calibration targets
    Eyelink('command', 'generate_default_targets = YES');
    Eyelink('command', 'calibration_area_proportion = 0.7 0.7'); % shrinking of the calibration area
    
    Eyelink('command', 'heuristic_filter = 1 1');   % corresponds to moderate filtering, 1 sample delay
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA'); %
    Eyelink('command', 'pupil_size_diameter = YES'); % For pupil diameter
    
    Eyelink('command', 'elcl_tt_power = %d',2);     % IR illumination
    Eyelink('command', 'sample_rate = %d',1000);    % Recording rate!!!
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%added by arezoo April 15, check
    % make sure that we get event data from the Eyelink
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON');
    
    %  Eyelink('command', 'saccade_velocity_threshold = 35');   %%%%% default values
    %  Eyelink('command', 'saccade_acceleration_threshold = 9500');  %%%%% default values
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%added by arezoo april 15,, check
    
    EyelinkUpdateDefaults(el);
    % comment this out to skip first calibration check and for debugging
%     EyelinkDoTrackerSetup(el);              % !!!!CALIBRATION!!!!
else
    el = 0;
end

end 
