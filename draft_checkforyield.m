% Small Yield of OVOC.m
% Compare mechanisms small OVOC yeilds
clear
close all



 MECHANISM = {'MCMv331';'GEOSCHEM'}; % choices are MCMv331, MCMv32, CB05, CB6r2, RACM2, GEOSCHEM

%% OBSERVATIONS
%{
Constraints are taken from observations at the Centerville, AL site of the 2013 SOAS field campaign.
The file loaded below contains these observations averaged to a 24-hour cycle  in 1-hour increments. 
Note that constraints CANNOT contains NaNs or negative numbers (data in this file has already been filtered).
Thanks to J. Kaiser for compiling these observations and to all the hard-working researchers for collecting them.
%}

load Obs_SOAS_CampaignAvg_60min.mat %Since we simulate the yield during a day. Therefore we refer to the example_dielcaycle

NO2conc = [0.01,0.1,1];
Yield_M = zeros(11,4,size(NO2conc,2));%store the Yield for MCM,each dim3 represent a Nox concentration
Yield_G = zeros(11,4,size(NO2conc,2));%store the Yield for Geos_Chem
for i = 1:2
    for j = 1:size(NO2conc,2)
%% METEOROLOGY
%{
P, T and RH were measured at the site and will be updated every step of the simulation.
SZA was not measured, so we can use a function to calculate it.
kdil is a physical loss constant for all species; 1 per day is a typical value.
%}

%Simulations are initiated at 09:00 LT with 1 ppbv iso- prene, 40 ppbv O3 , 
%and 100 ppbv CO. NOx concentrations are held at fixed values. 

switch MECHANISM{i}
    case {'MCMv331'}
        nJNO2 = 'J4'; nJO3 = 'J1';
    case {'GEOSCHEM'}
        nJNO2 = 'JNO2'; nJO3 = 'JO1D';
    otherwise
        error(['Invalid mechanism "' mechanism '".'])
end




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
      'H2O2'              (400*8.314*SOAS.T(9)/(6.023*SOAS.P(9))) 1;% For a fixed [OH] = 4 ? 10^6 molecules cm?3 to ppbv.R = 8.314e-5m3*bar*K-1*mol-1*1000mbar/bar
      'CO'                100                  1;

%     
%     %NOy
      'NO'               0                     0; %FixNOx flag set in options
      'NO2'              NO2conc(j)            0;
     
%     %VOCs
      'C5H8'              1                     0;
%     'APINENE'           1                     0;
%     'LIMONENE'          1                     0;

    };

%change names if needed
switch MECHANISM{i}
    case {'MCMv331'} %default
    case 'GEOSCHEM'
        InitConc(6,1) = {'ISOP'};%{'API'}{'LIMO'}
    otherwise
        error(['Invalid mechanism "' mechanism '".'])
end

%% CHEMISTRY
%{
ChemFiles is a cell array of strings specifying functions and scripts for the chemical mechanism.
THE FIRST CELL is always a function for generic K-values.
THE SECOND CELL is always a function for J-values (photolysis frequencies).
All other inputs are scripts for mechanisms and sub-mechanisms.
Here we give example using MCMv3.3.1. Note that this mechanism was extracted from the MCM website for
the specific set of initial species included above.
%}
switch MECHANISM{i}
    case 'MCMv331'
        ChemFiles = {...
            'MCMv331_K(Met)';...
            'MCMv331_J(Met,2)';...
            'MCMv331_Inorg_Isoprene'};
        

        
    case 'GEOSCHEM'
        ChemFiles = {...
            'GEOSCHEM_K(Met)';...
            'GEOSCHEM_J(Met,2)';...
            'GEOSCHEM_AllRxns'};
        
end

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
"Repeat" is set to 10 to loop through the full set of constraints 3 times.
"IntTime" is the integration time for each step, equal to the spacing of the data (60 minutes).
"TimeStamp" is set to the hour-of-day for observations.
"SavePath" give the filename only (in this example); the default save directory is the UWCMv3\Runs folder.
"FixNOx" forces total NOx to be reset to constrained values at the beginning of every step.
%}

ModelOptions.Verbose        = 1;
ModelOptions.EndPointsOnly  = 1;
ModelOptions.LinkSteps      = 1;
ModelOptions.Repeat         = 1;
ModelOptions.IntTime        = 3600; %3600 seconds/hour
ModelOptions.TimeStamp      = SOAS.Time(9:18);
ModelOptions.SavePath       = ['OVOCoutput_' MECHANISM{i} '_2'];
ModelOptions.FixNOx         = 1;

%% MODEL RUN
% Now we call the model. Note this may take several minutes to run, depending on your system.
% Output will be saved in the "SavePath" above and will also be written to the structure S.
% Let's also throw away the inputs (don't worry, they are saved in the output structure).

S = F0AM_ModelCore(Met,InitConc,ChemFiles,BkgdConc,ModelOptions);

switch MECHANISM{i}
  case {'MCMv331'}
      HCHOrates_M = PlotRates('HCHO',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of HCHO.There are only 
      HCHOprodRate_M = sum(HCHOrates_M.Prod,2);% get the producation rate of HCHO for each hour
      close all%we don't need the plot rate picture
      HCOOHrates_M = PlotRates('HCOOH',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of HCOOH
      HCOOHprodRate_M = sum(HCOOHrates_M.Prod,2);% get the producation rate of HCOOH for each hour
      close all%we don't need the plot rate picture
      GLYOXrates_M = PlotRates('GLYOX',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of GLYOX
      GLYOXprodRate_M = sum(GLYOXrates_M.Prod ,2);% gget the producation rate of GLYOX for each hour   
      close all%we don't need the plot rate picture
      CH3COCH3rates_M = PlotRates('CH3COCH3',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of CH3COCH3
      CH3COCH3prodRate_M = sum(CH3COCH3rates_M.Prod,2);% get the producation rate of CH3COCH3 for each hour 
      close all%we don't need the plot rate picture
% tableF(:,i,j) = S.Conc.HCHO;%store each concentration
% tablefa(:,i,j) = S.Conc.HCOOH;
% tablegly(:,i,j) = S.Conc.GLYOX;
% tableace(:,i,j) = S.Conc.CH3COCH3;
  case 'GEOSCHEM'
      HCHOrates_G = PlotRates('CH2O',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of HCHO
      HCHOprodRate_G = sum(HCHOrates_G.Prod ,2);% get the producation rate of HCHO for each hour
      close all%we don't need the plot rate picture
      HCOOHrates_G = PlotRates('HCOOH',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of HCOOH
      HCOOHprodRate_G = sum(HCOOHrates_G.Prod,2);% get the producation rate of HCOOH for each hour
      close all%we don't need the plot rate picture
      GLYOXrates_G = PlotRates('GLYX',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of GLYOX
      GLYOXprodRate_G =sum(GLYOXrates_G.Prod ,2);% get the producation rate of GLYOX for each hour   
      close all%we don't need the plot rate picture
      CH3COCH3rates_G = PlotRates('ACET',S,5,'unit','ppb_h','sumEq',1);%get hte loss and production rate of CH3COCH3
      CH3COCH3prodRate_G = sum(CH3COCH3rates_G.Prod ,2);% get the producation rate CH3COCH3 for each hour        
      close all%we don't need the plot rate picture
      
end

%% Calculate the Accumulative Molar yield 
 switch MECHANISM{i}
  case {'MCMv331'}
      ProdRate_M = [HCHOprodRate_M,HCOOHprodRate_M,GLYOXprodRate_M,CH3COCH3prodRate_M];
  for y = 2:11%for each end point of step
      Yield_M(y,:,j) = Yield_M(y-1,:,j) + ProdRate_M(y-1,:).*1;%Cnext = Cprevious +ProdRate/hr*1hr
  end
   case 'GEOSCHEM'
       ProdRate_G = [HCHOprodRate_G,HCOOHprodRate_G,GLYOXprodRate_G,CH3COCH3prodRate_G];
  for y = 2:11%for each end point of step
       Yield_G(y,:,j) = Yield_G(y-1,:,j) + ProdRate_G(y-1,:).*1;%Cnext = Cprevious +ProdRate/hr*1hr
  end
 end

       

clear Met InitConc ChemFiles BkgdConc ModelOptions

    end
end

%% Plot

% for HCHO:
figure
HCHO_Yield_M = Yield_M(:,1,:);
HCHO_Yield_M=[HCHO_Yield_M(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,HCHO_Yield_M(2:end,:)','r','ShowText','on');
hold on
HCHO_Yield_G = Yield_G(:,1,:);
HCHO_Yield_G=[HCHO_Yield_G(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,HCHO_Yield_G(2:end,:)','b','ShowText','on');
legend('MCMv331','GeosChem');
xlabel('OH exposure time (h)')
ylabel('NOx(ppbv)');
title('HCHO Yield(with C5H8)');
saveas(gcf,'HCHO.png');
% for HCOOH

figure
HCOOH_Yield_M = Yield_M(:,2,:);
HCOOH_Yield_M=[HCOOH_Yield_M(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,HCOOH_Yield_M(2:end,:)','r','ShowText','on');
hold on
HCOOH_Yield_G = Yield_G(:,2,:);
HCOOH_Yield_G=[HCOOH_Yield_G(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,HCOOH_Yield_G(2:end,:)','b','ShowText','on');
legend('MCMv331','GeosChem');
xlabel('OH exposure time (h)')
ylabel('NOx(ppbv)');
title('HCOOH Yield(with C5H8)');
saveas(gcf,'HCOOH.png');

% for GLYOX

figure
GLYOX_Yield_M = Yield_M(:,3,:);
GLYOX_Yield_M=[GLYOX_Yield_M(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,GLYOX_Yield_M(2:end,:)','r','ShowText','on');
hold on
GLYOX_Yield_G = Yield_G(:,3,:);
GLYOX_Yield_G=[GLYOX_Yield_G(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,GLYOX_Yield_G(2:end,:)','b','ShowText','on');
legend('MCMv331','GeosChem');
xlabel('OH exposure time (h)')
ylabel('NOx(ppbv)');
title('GLYOX Yield(with C5H8)');
saveas(gcf,'CHOCHO.png');


% for CH3COCH3
figure
CH3COCH3_Yield_M = Yield_M(:,4,:);
CH3COCH3_Yield_M=[CH3COCH3_Yield_M(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,CH3COCH3_Yield_M(2:end,:)','r','ShowText','on');
hold on
CH3COCH3_Yield_G = Yield_G(:,4,:);
CH3COCH3_Yield_G=[CH3COCH3_Yield_G(:,:)];%each column represent a different NOx concentration
Time = [1:1:10]';
contour(Time,NO2conc,CH3COCH3_Yield_G(2:end,:)','b','ShowText','on');
legend('MCMv331','GeosChem');
xlabel('OH exposure time (h)')
ylabel('NOx(ppbv)');
title('CH3COCH3 Yield(with C5H8)');
saveas(gcf,'C3H6O.png');