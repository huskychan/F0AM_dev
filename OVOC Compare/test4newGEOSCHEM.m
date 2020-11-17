% ExampleSetup_DielCycle.m
% This example shows a model setup for simulation of an "average" diurnal cycle at a ground location.
% In particular, we will try to simulate ozone production.
% Read comments in each section for a guided tour.
%
% 20151126 GMW

clear

%% OBSERVATIONS
%{
Constraints are taken from observations at the Centerville, AL site of the 2013 SOAS field campaign.
The file loaded below contains these observations averaged to a 24-hour cycle  in 1-hour increments. 
Note that constraints CANNOT contains NaNs or negative numbers (data in this file has already been filtered).
Thanks to J. Kaiser for compiling these observations and to all the hard-working researchers for collecting them.
%}

load Obs_SOAS_CampaignAvg_60min.mat %structure "SOAS"

%% METEOROLOGY
%{
P, T and RH were measured at the site and will be updated every step of the simulation.
SZA was not measured, so we can use a function to calculate it.
kdil is a physical loss constant for all species; 1 per day is a typical value.
%}

%calculate solar zenith angles for day in middle of campaign
o = ones(size(SOAS.T(9:18)));
time.year           = 2013*o;
time.month          = 6*o;
time.day            = 12*o;
time.hour           = [9:18]';%use 10 hours according to the paper.
time.min            = 0*o;
time.sec            = 0*o;
time.UTC            = -5;
location.latitude   = 32.903;
location.longitude  = -87.250;
location.altitude   = 126;
sun = sun_position(time,location); %fields zenith and azimuth

Met = {...
%   names       %values
    'P'          SOAS.P(9:18); %Pressure, mbar
    'T'          SOAS.T(9:18); %Temperature, K
    'RH'         SOAS.RH(9:18); %Relative Humidity, %
    'SZA'        sun.zenith; %solar zenith angle, degrees
    'kdil'       1/(24*60*60); %dilution constant, /s
    'jcorr'      1;
    };

%% CHEMICAL CONCENTRATIONS
%{
Concentrations are initialized using observations or fixed values.
Species with HoldMe = 1 will be held constant throughout each step.
Species with HoldMe = 0 are only initialized at the start of the run, because
 ModelOptions.LinkSteps=1 (see below). For this particular case, NO2 and O3 are
 unconstrained because we are investigating ozone production.
When many species are used, it helps to organize alphabetically or by functional group.
%}

InitConc = {...
    % names           conc(ppb)           HoldMe
    
%     %Inorganics
      'O3'                40                   1;
      'OH'              (0.4.*10^(-3)*8.314*SOAS.T(9)/(6.023*SOAS.P(9))) 0;%  [OH] = 4*10^6 molecules cm-3 to ppbv.R = 8.314e-5m3*bar*K-1*mol-1*1000mbar/bar
      'CO'                100                  1;

%     
%     %NOy
      'NO'               0                     0; %FixNOx flag set in options
      'NO2'              1            0;
     
%     %VOCs
       'ISOP'              1                     0;
%     'APINENE'           1                     0;
%     'LIMONENE'          1                     0;

    };

%% CHEMISTRY
%{
ChemFiles is a cell array of strings specifying functions and scripts for the chemical mechanism.
THE FIRST CELL is always a function for generic K-values.
THE SECOND CELL is always a function for J-values (photolysis frequencies).
All other inputs are scripts for mechanisms and sub-mechanisms.
Here we give example using MCMv3.3.1. Note that this mechanism was extracted from the MCM website for
the specific set of initial species included above.
%}
ChemFiles = {...
   'GEOSCHEM_K(Met)';
            'GEOSCHEM_J_new(Met,2)';
            'GeosChem_AllRxns_1208_pre';
%     'MCMv331_Inorg_Isoprene'; %alternate mechanism with less VOC
   };

%% DILUTION CONCENTRATIONS
%{
Background concentrations, along with the value of kdil in Met, determine the dilution rate for chemical species.
Here we stick with the default value of 0 for all species, which effectively makes dilution a first-order loss.
%}
BkgdConc = {'DEFAULT'       0};

%% OPTIONS
%{
"Verbose" can be set from 0-3; this just affects the level of detail printed to the command
  window regarding model progress.
"EndPointsOnly" is set to 1 because we only want the last point of each step.
"LinkSteps" is set to 1 so that non-constrained species are carried over between steps.
"IntTime" is the integration time for each step, equal to the spacing of the data (60 minutes).
"TimeStamp" is set to the hour-of-day for observations.
"SavePath" give the filename only (in this example); the default save directory is the UWCMv3\Runs folder.
"FixNOx" forces total NOx to be reset to constrained values at the beginning of every step.
%}

ModelOptions.Verbose        = 2;
ModelOptions.EndPointsOnly  = 1;
ModelOptions.LinkSteps      = 1;
ModelOptions.IntTime        = 3600; %3600 seconds/hour
ModelOptions.TimeStamp      = SOAS.Time;
ModelOptions.SavePath       = 'DielExampleOutput';
% ModelOptions.FixNOx         = 1; %if you use this, disable family conservation above.


%% INPUT REPLICATION AND INTERPOLATION
% For this particular scenario, it might be desirable to modify the inputs in a few ways.
% This sections demonstrates how to do so.

% INTERPOLATION
% Inputs currently have a time resolution of 60 minutes, but this is pretty coarse (the sun can move
% a lot in 60 minutes). The InputInterp function allows you to interpolate all inputs to a finer
% time resolution. NOTES:
%   - If your native data is fast (e.g., 1 Hz), it is generally better practice to bin-average that 
%       data to your desired resolution rather than average down to 60 minutes and then interpolate as done here.
%   - Make sure you adjust ModelOptions.IntTime too!
% To turn this on, set the "0" to "1" below.
if 0
    dt = 1800; %time spacing, seconds
    
    Time_interp = (0:dt:(86400-dt))'/3600; %interpolation timebase, fractional hours (to match SOAS.Time)
    circularFlag = 1; % time wraps around at midnight
    [Met,InitConc,BkgdConc] = ...
        InputInterp(Met,InitConc,BkgdConc,SOAS.Time,Time_interp,circularFlag);
    ModelOptions.TimeStamp = Time_interp;
    ModelOptions.IntTime = dt;
end

% REPLICATION
% Sometimes you may want to run the same inputs for multiple times. Typically, this scenario would
% be ground-site observations over one or more days, and you need a "spin-up" for non-measured
% species. The InputReplicate function lets you do this. Note, this only makes sense to use if
% ModelOptions.LinkSteps = 1. This replaces the "ModelOptions.Repeat" functionality in model
% versions prior to F0AMv4.
% Here, we run the same contraints for 3 days.
% The output "repIndex" is used to separate the days with SplitRun later.
nRep = 3; %number of days to repeat
[Met,InitConc,BkgdConc,repIndex] = InputReplicate(Met,InitConc,BkgdConc,nRep);
ModelOptions.TimeStamp = repmat(ModelOptions.TimeStamp,nRep,1);

%% MODEL RUN
% Now we call the model. Note this may take several minutes to run, depending on your system.
% Output will be saved in the "SavePath" above and will also be written to the structure S.

S = F0AM_ModelCore(Met,InitConc,ChemFiles,BkgdConc,ModelOptions);
% clear Met InitConc ChemFiles BkgdConc ModelOptions
SpRates = PlotRates('OH',S,3);
