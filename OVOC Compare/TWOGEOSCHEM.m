%To test for bugs, you should show that mcm and geoschem look the same for mvk formation from c5h8
clear
close all

 MECHANISM = {'GEOSCHEM_old';'GEOSCHEM'}; % choices are MCMv331, MCMv32, CB05, CB6r2, RACM2, GEOSCHEM



%% OBSERVATIONS
%{
Constraints are taken from observations at the Centerville, AL site of the 2013 SOAS field campaign.
The file loaded below contains these observations averaged to a 24-hour cycle  in 1-hour increments. 
Note that constraints CANNOT contains NaNs or negative numbers (data in this file has already been filtered).
Thanks to J. Kaiser for compiling these observations and to all the hard-working researchers for collecting them.
%}

load Obs_SOAS_CampaignAvg_60min.mat %Since we simulate the yield during a day. Therefore we refer to the example_dielcaycle
for i = 1:2%2 mechanisms
   
%% METEOROLOGY
%{
P, T and RH were measured at the site and will be updated every step of the simulation.
SZA was not measured, so we can use a function to calculate it.
kdil is a physical loss constant for all species; 1 per day is a typical value.
%}

%Simulations are initiated at 09:00 LT with 1 ppbv iso- prene, 40 ppbv O3 , 
%and 100 ppbv CO. NOx concentrations are held at fixed values. 

switch MECHANISM{i}
    case {'GEOSCHEM_old'}
        nJNO2 = 'JNO2'; nJO3 = 'JO1D';
    case {'GEOSCHEM'}
        nJNO2 = 'JNO2'; nJO3 = 'JO3';
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
      'OH'              (0.4.*10^(-3)*8.314*SOAS.T(9)/(6.023*SOAS.P(9))) 1;%  [OH] = 4*10^6 molecules cm-3 to ppbv.R = 8.314e-5m3*bar*K-1*mol-1*1000mbar/bar
      'CO'                100                  0;
       'H2O'              (ConvertHumidity(SOAS.T(9:18),SOAS.P(9:18),SOAS.RH(9:18),'RH','NumberDensity').* 10.^(-10).*8.314.*SOAS.T(9:18)./6.023)./SOAS.P(9:18)       1;% (ConvertHumidity(SOAS.T(9:18),SOAS.P(9:18),SOAS.RH(9:18),'RH','NumberDensity').* 10.^(-10).*8.314.*SOAS.T(9:18)./6.023)./SOAS.P(9:18)
      

%     
%     %NOy
      'NO'               0                     0; %FixNOx flag set in options
      'NO2'              10                     0;

     
%     %VOCs
       'ISOP'              1                     0;
%     'APINENE'           1                     0;
%     'LIMONENE'          1                     0;
      'O'                0                     1;
      'H'                0                      1;
   
    };

%change names if needed
switch MECHANISM{i}
    case {'GEOSCHEM_old'} %default
    case 'GEOSCHEM'
        InitConc(7,1) = {'ISOP'};%{'ISOP'};%{'ISOP'};%{'API'};%%{'LIMO'};%{'ISOP'};
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
    case 'GEOSCHEM_old'
        ChemFiles = {...
            'GEOSCHEM_K(Met)';...
            'GEOSCHEM_J(Met,2)';...
            'GEOSCHEMv902_AllRxns'};
    case 'GEOSCHEM'
        ChemFiles = {...
            'GEOSCHEM_K(Met)';...
            'GEOSCHEM_J_new(Met,2)';...
            'GEOSCHEMTropChem1208'};%GeosChem_AllRxns_1208 GEOSCHEMTropChem1208
        
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
ModelOptions.EndPointsOnly  = 0;%so that we get the conc of each small time interval to calculate the tOH
ModelOptions.LinkSteps      = 1;
% ModelOptions.Repeat         = 1;
ModelOptions.IntTime        = 3600; %3600 seconds/hour 
ModelOptions.TimeStamp      = SOAS.Time(9:18);
ModelOptions.SavePath       = ['OVOCoutput_' MECHANISM{i} '_2'];
ModelOptions.FixNOx         = 1;

%% MODEL RUN
% Now we call the model. Note this may take several minutes to run, depending on your system.
% Output will be saved in the "SavePath" above and will also be written to the structure S.
% Let's also throw away the inputs (don't worry, they are saved in the output structure).

 S = F0AM_ModelCore(Met,InitConc,ChemFiles,BkgdConc,ModelOptions);

%% Get the Production Rate for the molar yield
switch MECHANISM{i}
  case {'GEOSCHEM_old'}
      


%       MVKrates_M = PlotRates('MVK',S,3,'unit','ppb_s','sumEq',0);%get hte loss and production rate of MVK.There are only 
%       MVKprodRate_M = sum(MVKrates_M.Prod,2);% get the producation rate of MVK for each time interval(s)
%       C5H8rates_M = PlotRates('ISOP',S,3,'unit','ppb_s','sumEq',0);%get hte loss and production rate of C5H8.There are only 
%       C5H8LossRate_M = sum(C5H8rates_M.Loss,2);% get the loss rate of C5H8 for each time interval(s)
%         OHrates_M = PlotRates('OH',S,3);%get hte loss and production rate of OH.There are only 
%       OHLossRate_M = sum(OHrates_M.Loss,2);% get the loss rate of OH for each time interval(s)
%         O2rates_M = PlotRates('O2',S,5,'ptype','fill');%get hte loss and production rate of OH.There are only 
%       O2LossRate_M = sum(O2rates_M.Loss,2);% get the loss rate of OH for each time interval(s)
%         PlotRates('CH4',S,3);
%          PlotRates('PRPE',S,3);
%         PlotRates('RCO3',S,3);
%         PlotRates('MOH',S,3);
%         PlotRates('RCHO',S,3);
%         PlotRates('ALD2',S,3);
%         PlotRates('ACET',S,3);
%         GLYCrate_M=PlotRates('GLYC',S,3);
%           PYACrate_M = PlotRates('PYAC',S,3);
%         PlotRates('ETHLN',S,3);
%           PROPNNrate_M=PlotRates('PROPNN',S,3);
%         PlotRates('MEK',S,3);
          PlotRates('CH2O',S,3);

  case 'GEOSCHEM'
  
      
%       MVKrates_G = PlotRates('MVK',3,1,'unit','ppb_s','sumEq',0);%get hte loss and production rate of MVK
%       MVKprodRate_G = sum(MVKrates_G.Prod ,2);% get the producation rate of MVK for each time interval(s)
%       C5H8rates_G = PlotRates('ISOP',S,3,'unit','ppb_s','sumEq',0);%get hte loss and production rate of C5H8
%       C5H8LossRate_G = sum(C5H8rates_G.Loss ,2);% get the producation rate of C5H8 for each time interval(s)
%         OHrates_G = PlotRates('OH',S,3);%get hte loss and production rate of OH.There are only 
%       OHLossRate_G = sum(OHrates_G.Loss,2);% get the loss rate of OH for each time interval(s)
%        O2rates_G = PlotRates('O2',S,5);%get hte loss and production rate of OH.There are only 
%        O2LossRate_G = sum(O2rates_G.Loss,2);% get the loss rate of OH for each time interval(s)
%         PlotRates('CH4',S,3);
%          PlotRates('PRPE',S,3);
%         PlotRates('RCO3',S,3);
%         PlotRates('MOH',S,3);
%         PlotRates('RCHO',S,3);
%         PlotRates('ALD2',S,3);
%         PlotRates('ACET',S,3);
%          GLYCrate_G=PlotRates('GLYC',S,3);
%         PYACrate_M = PlotRates('PYAC',S,3);
%         PlotRates('ETHLN',S,3);
%          PROPNNrate_G=PlotRates('PROPNN',S,3);
%         PlotRates('MEK',S,3);
% PlotRates('CH2O',S,3);
      %close all
end%end switch mechanism


%% Get the Concentration for each Mechanisms
switch MECHANISM{i}
  case {'GEOSCHEM_old'}
      MVK_Conc_old = S.Conc.MVK;
       ISOP_Conc_old = S.Conc.ISOP;
       HO2_Conc_old = S.Conc.HO2;
      OH_Conc_old = S.Conc.OH;
      
%       %Inorganic
%       NO_Conc_old = S.Conc.NO;
%       NO2_Conc_old = S.Conc.NO2;
%       NO3_Conc_old = S.Conc.NO3;
%       CO_Conc_old = S.Conc.CO;
%       O2_Conc_old = S.Conc.O2;
%       Br_Conc_old = S.Conc.Br;
%       SO2_Conc_old = S.Conc.SO2;
%       O1D_Conc_old = S.Conc.O1D;
%       
%       %organic
%       CH4_Conc_old = S.Conc.CH4;
%       PRPE_Conc_old = S.Conc.PRPE;
%       MCO3_Conc_old = S.Conc.MCO3;
       CH2O_Conc_old = S.Conc.CH2O;
%       RCO3_Conc_old = S.Conc.RCO3;
%       MOH_Conc_old = S.Conc.MOH;
%       MO2_Conc_old = S.Conc.MO2;     
%       MACR_Conc_old = S.Conc.MACR;
%       RCHO_Conc_old = S.Conc.RCHO;
%       ALD2_Conc_old = S.Conc.ALD2;
%       ACET_Conc_old = S.Conc.ACET;
%       MGLY_Conc_old = S.Conc.MGLY;
%       GLYX_Conc_old = S.Conc.GLYX;     
%       PYAC_Conc_old = S.Conc.PYAC;
%       GLYC_Conc_old = S.Conc.GLYC;
%       ETHLN_Conc_old = S.Conc.ETHLN;
%       PROPNN_Conc_old = S.Conc.PROPNN;
%       MEK_Conc_old = S.Conc.MEK;
%       PRPN_Conc_old=S.Conc.PRPN;

      

  case 'GEOSCHEM'
      MVK_Conc_new = S.Conc.MVK;
      ISOP_Conc_new = S.Conc.ISOP;
      HO2_Conc_new = S.Conc.HO2;
      OH_Conc_new = S.Conc.OH;

      
      
%       %Inorganic
%       NO_Conc_new = S.Conc.NO;
%       NO2_Conc_new = S.Conc.NO2;
%       NO3_Conc_new = S.Conc.NO3;
%       CO_Conc_new = S.Conc.CO;
%       O2_Conc_new = S.Conc.O2;
%       Br_Conc_new = S.Conc.Br;
%       SO2_Conc_new = S.Conc.SO2;
%       O1D_Conc_new = S.Conc.O1D;
%       
%             %organic
%       CH4_Conc_new = S.Conc.CH4;
%       PRPE_Conc_new = S.Conc.PRPE;
%       MCO3_Conc_new = S.Conc.MCO3;
       CH2O_Conc_new = S.Conc.CH2O;
%       RCO3_Conc_new = S.Conc.RCO3;
%       MOH_Conc_new = S.Conc.MOH;
%       MO2_Conc_new = S.Conc.MO2;     
%       MACR_Conc_new = S.Conc.MACR;
%       RCHO_Conc_new = S.Conc.RCHO;
%       ALD2_Conc_new = S.Conc.ALD2;
%       ACET_Conc_new = S.Conc.ACET;
%       MGLY_Conc_new = S.Conc.MGLY;
%       GLYX_Conc_new = S.Conc.GLYX;     
%       PYAC_Conc_new = S.Conc.PYAC;
%       GLYC_Conc_new = S.Conc.GLYC;
%       ETHLN_Conc_new = S.Conc.ETHLN;
%       PROPNN_Conc_new = S.Conc.PROPNN;
%       MEK_Conc_new = S.Conc.MEK;
%       PRPN_Conc_new=S.Conc.PRPN;

end%end switch mechanism

end %end for to mechnisms
%% Plot


figure
subplot(2,2,1);
plot([1:1:size(MVK_Conc_old,1)],MVK_Conc_old','r');
hold on
plot([1:1:size(MVK_Conc_new,1)],MVK_Conc_new','b');
legend('oldGEOSCHEM','newGEOSCHEM');
xlabel('Time (s)')
ylabel('Concentration(ppb)');
head = ['MVK Concentration(with C5H8)']; 
title(head);

subplot(2,2,2);
plot([1:1:size(MVK_Conc_old,1)],ISOP_Conc_old','r');
hold on
plot([1:1:size(MVK_Conc_new,1)],ISOP_Conc_new','b');
legend('oldGEOSCHEM','newGEOSCHEM');
xlabel('Time (s)')
ylabel('Concentration(ppb)');
head = ['C5H8 Concentration(with C5H8)']; 
title(head);

subplot(2,2,3);
plot([1:1:size(MVK_Conc_old,1)],OH_Conc_old','r');
hold on
plot([1:1:size(MVK_Conc_new,1)],OH_Conc_new','b');
legend('oldGEOSCHEM','newGEOSCHEM');
xlabel('Time (s)')
ylabel('Concentration(ppb)');
head = ['OH Concentration(with C5H8)']; 
title(head);

subplot(2,2,4);
plot([1:1:size(MVK_Conc_old,1)],HO2_Conc_old','r');
hold on
plot([1:1:size(MVK_Conc_new,1)],HO2_Conc_new','b');
legend('oldGEOSCHEM','newGEOSCHEM');
xlabel('Time (s)')
ylabel('Concentration(ppb)');
head = ['HO2 Concentration(with C5H8)']; 
title(head);
text = ['Two GEOCHEM Concentration.png'];
saveas(gcf,text);

figure
plot([1:1:size(MVK_Conc_old,1)],CH2O_Conc_old','r');
hold on
plot([1:1:size(MVK_Conc_new,1)],CH2O_Conc_new','b');
legend('oldGEOSCHEM','newGEOSCHEM');
xlabel('Time (s)')
ylabel('Concentration(ppb)');
head = ['CH2O Concentration(with C5H8)']; 
title(head);
text = ['Two GEOCHEM Concentration.png'];
% saveas(gcf,text);

% %       %Inorganic
% 
% figure
% subplot(2,2,1);
% plot([1:1:size(MVK_Conc_old,1)],NO_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], NO_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['NO Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,2);
% plot([1:1:size(MVK_Conc_old,1)],NO2_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], NO2_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['NO2 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,3);
% plot([1:1:size(MVK_Conc_old,1)],NO3_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], NO3_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['NO3 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,4);
% plot([1:1:size(MVK_Conc_old,1)],CO_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], CO_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['CO Concentration(with MVK)']; 
% title(head);
% 
% 
% 
% figure
% subplot(2,2,1);
% plot([1:1:size(MVK_Conc_old,1)],O2_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], O2_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['O2 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,2);
% plot([1:1:size(MVK_Conc_old,1)],Br_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], Br_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['Br Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,3);
% plot([1:1:size(MVK_Conc_old,1)],SO2_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], SO2_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['SO2 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,4);
% plot([1:1:size(MVK_Conc_old,1)],O1D_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], O1D_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['O1D Concentration(with MVK)']; 
% title(head);
% 
% % organic
% 
% figure
% subplot(2,2,1);
% plot([1:1:size(MVK_Conc_old,1)],CH4_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], CH4_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['CH4 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,2);
% plot([1:1:size(MVK_Conc_old,1)],PRPE_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], PRPE_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['PRPE Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,3);
% plot([1:1:size(MVK_Conc_old,1)],MCO3_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], MCO3_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['MCO3 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,4);
% plot([1:1:size(MVK_Conc_old,1)],CH2O_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], CH2O_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['CH2O Concentration(with MVK)']; 
% title(head);
% 
% figure
% subplot(2,2,1);
% plot([1:1:size(MVK_Conc_old,1)],RCO3_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], RCO3_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['RCO3 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,2);
% plot([1:1:size(MVK_Conc_old,1)],MOH_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], MOH_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['MOH Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,3);
% plot([1:1:size(MVK_Conc_old,1)],MO2_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], MO2_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['MO2 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,4);
% plot([1:1:size(MVK_Conc_old,1)],MACR_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], MACR_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['MACR Concentration(with MVK)']; 
% title(head);
% 
% figure
% subplot(2,2,1);
% plot([1:1:size(MVK_Conc_old,1)],RCHO_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], RCHO_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['RCHO Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,2);
% plot([1:1:size(MVK_Conc_old,1)],ALD2_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], ALD2_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['ALD2 Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,3);
% plot([1:1:size(MVK_Conc_old,1)],ACET_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], ACET_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['ACET Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,4);
% plot([1:1:size(MVK_Conc_old,1)],MGLY_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], MGLY_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['MGLY Concentration(with MVK)']; 
% title(head);
% 
% figure
% subplot(2,2,1);
% plot([1:1:size(MVK_Conc_old,1)],GLYC_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], GLYC_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['GLYC Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,2);
% plot([1:1:size(MVK_Conc_old,1)],PYAC_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], PYAC_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['PYAC Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,3);
% plot([1:1:size(MVK_Conc_old,1)],GLYX_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)], GLYX_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['GLYX Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,4);
% plot([1:1:size(MVK_Conc_old,1)],ETHLN_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)],ETHLN_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['ETHLN Concentration(with MVK)']; 
% title(head);
% 
% figure
% subplot(2,2,1);
% plot([1:1:size(MVK_Conc_old,1)],PROPNN_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)],PROPNN_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['PROPNN Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,2);
% plot([1:1:size(MVK_Conc_old,1)],MEK_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)],MEK_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['MEK Concentration(with MVK)']; 
% title(head);
% 
% subplot(2,2,3);
% plot([1:1:size(MVK_Conc_old,1)],PRPN_Conc_old','r');
% hold on
% plot([1:1:size(MVK_Conc_new,1)],PRPN_Conc_new','b');
% legend('oldGEOSCHEM','newGEOSCHEM');
% xlabel('Time (s)')
% ylabel('Concentration(ppb)');
% head = ['PRPN Concentration(with MVK)']; 
% title(head);
% 
% 
% 
% 
% 
% 
% 
figure
plot([1:1:size(lowNOx_old,1)],lowNOx_old','r');
hold on
plot([1:1:size(lowNOx_new,1)],lowNOx_new','b');
hold on
plot([1:1:size(highNOx_old,1)],highNOx_old','r:');
hold on
plot([1:1:size(highNOx_new,1)],highNOx_new','b:');
legend('oldGEOSCHEM_{lowNox}','newGEOSCHEM_{lowNox}','oldGEOSCHEM_{highNox}','newGEOSCHEM_{highNox}');