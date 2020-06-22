% Small Yield of OVOC.m
% Compare mechanisms small OVOC yeilds
clear
close all
VOC_M = {'C5H8','APINENE','LIMONENE'};%the name for precursos in MCM
VOC_G = {'ISOP','MTPA','LIMO'};%the name for precursos in Geos-Chem


for v = 1:size(VOC_M,2)%for loop for 3 precursors

 MECHANISM = {'MCMv331';'GEOSCHEM'}; % choices are MCMv331, MCMv32, CB05, CB6r2, RACM2, GEOSCHEM



%% OBSERVATIONS
%{
Constraints are taken from observations at the Centerville, AL site of the 2013 SOAS field campaign.
The file loaded below contains these observations averaged to a 24-hour cycle  in 1-hour increments. 
Note that constraints CANNOT contains NaNs or negative numbers (data in this file has already been filtered).
Thanks to J. Kaiser for compiling these observations and to all the hard-working researchers for collecting them.
%}

load Obs_SOAS_CampaignAvg_60min.mat %Since we simulate the yield during a day. Therefore we refer to the example_dielcaycle

NO2conc = [0.01,0.5,1];
Yield_M =zeros(10,4,size(NO2conc,2));%store the Yield for MCM,each dim3 represent a Nox concentration(with endpointonly=0,)
%The size of Yield_M will change later, it will have 1728 rows finally 
Yield_G = zeros(10,4,size(NO2conc,2));%store the Yield for Geos_Chem
actual_time_M = zeros(10,size(NO2conc,2));%actual time corresponding to OH time of 1-10hr
actual_time_G = zeros(10,size(NO2conc,2));%actual time corresponding to OH time of 1-10hr
for i = 1:2%2 mechanisms
    for j = 1:size(NO2conc,2)%3 different NOx concentration
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
      'OH'              (0.4.*10^(-3)*8.314*SOAS.T(9)/(6.023*SOAS.P(9))) 0;%  [OH] = 4*10^6 molecules cm-3 to ppbv.R = 8.314e-5m3*bar*K-1*mol-1*1000mbar/bar
      'CO'                100                  1;

%     
%     %NOy
      'NO'               0                     0; %FixNOx flag set in options
      'NO2'              NO2conc(j)            0;
     
%     %VOCs
       VOC_M{v}              1                     0;
%     'APINENE'           1                     0;
%     'LIMONENE'          1                     0;

    };

%change names if needed
switch MECHANISM{i}
    case {'MCMv331'} %default
    case 'GEOSCHEM'
        InitConc(6,1) = VOC_G(v);%{'ISOP'};%{'ISOP'};%{'API'};%%{'LIMO'};%{'ISOP'};
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
           'MCMv331_AllRxns'}; %'MCMv331_DielExampleChemistry'};%%'MCMv331_DielExampleChemistry'};%
        

        
    case 'GEOSCHEM'
        ChemFiles = {...
            'GEOSCHEM_K(Met)';...
            'GEOSCHEM_J(Met,2)';...
            'GeosChem1207AllRxns'};
        
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
%% Get the OH exposure Time

switch MECHANISM{i}
  case {'MCMv331'}
  storage = [S.Conc.OH,S.Time];%store the original S.Conc.OH
  % delete the same time and corresponding S.Conc.OH
  table = [S.Conc.OH,S.Time];
  table2 = zeros(size(table));
  c = unique(S.Time);
  for z =  1: size(c,1)
  [row,~] = find(S.Time == c(z),1);
  table2(z,:) = table(row,:);
  end
  
  S.Conc.OH = table2(:,1);
  Time = table2(:,2);

  Area = 0;%initialzie the area
  row_old = 1;


OHtime = 1;
  for t = 1:10
      [row,~] = find(Time == 60*60*t);%Find the concentration of OH at the ending of each hour.
      for r = row_old:(row(end)-1)% for each time interval
          Area = Area+(((S.Conc.OH(r)+S.Conc.OH(r+1)) .* (Time(r+1)-Time(r)))./2);%trapezoid
          OHt = (Area./3600)./((0.4.*10^(-3)*8.314*SOAS.T(t+8)/(6.023*SOAS.P(t+8))));%Calculate the OHt(supposed that the T and P are unchanged in 1 hour)
          if round(OHt)== OHtime%find the actual time of OHt = 1:10
              actual_time_M(OHtime,j) = Time(r);
              OHtime=OHtime+1;
          end%if
      end%for r = row_old:(row(end)-1)%

      
      row_old = row(1);
  end %t=1:10

  case 'GEOSCHEM'

  % delete the same time;
  table = [S.Conc.OH,S.Time];
  table2 = zeros(size(table));
  c = unique(S.Time);
  for z =  1: size(c,1)
  [row,~] = find(S.Time == c(z),1);
  table2(z,:) = table(row,:);
  end
  
  S.Conc.OH = table2(:,1);
  Time = table2(:,2);
  Area = 0;%initialzie the area
  row_old = 1;

OHtime = 1;
  for t = 1:10
      [row,~] = find(Time == 60*60*t);%Find the concentration of OH at the ending of each hour.
      for r = row_old:(row(end)-1)% for each time interval
          Area = Area+(((S.Conc.OH(r)+S.Conc.OH(r+1)) .* (Time(r+1)-Time(r)))./2);%trapezoid
          OHt = (Area./3600)./((0.4.*10^(-3)*8.314*SOAS.T(t+8)/(6.023*SOAS.P(t+8))));%Calculate the OHt(supposed that the T and P are unchanged in 1 hour)
          if round(OHt)== OHtime%find the actual time of OHt = 1:10
              actual_time_G(OHtime,j) = Time(r);
              OHtime=OHtime+1;
          end%if
      end%for r = row_old:(row(end)-1)%

      
      row_old = row(1);
  end %t=1:10
end%end switch mechanism





%% Get the Production Rate for the molar yield
switch MECHANISM{i}
  case {'MCMv331'}
      


      HCHOrates_M = PlotRates('HCHO',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of HCHO.There are only 
      HCHOprodRate_M = sum(HCHOrates_M.Prod,2);% get the producation rate of HCHO for each time interval(s)
      close all%we don't need the plot rate picture
      HCOOHrates_M = PlotRates('HCOOH',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of HCOOH
      HCOOHprodRate_M = sum(HCOOHrates_M.Prod,2);% get the producation rate of HCOOH for each time interval(s)
      close all%we don't need the plot rate picture
      GLYOXrates_M = PlotRates('GLYOX',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of GLYOX
      GLYOXprodRate_M = sum(GLYOXrates_M.Prod ,2);% gget the producation rate of GLYOX for each time interval(s)
      close all%we don't need the plot rate picture
      CH3COCH3rates_M = PlotRates('CH3COCH3',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of CH3COCH3
      CH3COCH3prodRate_M = sum(CH3COCH3rates_M.Prod,2);% get the producation rate of CH3COCH3 for each time interval(s)
      close all%we don't need the plot rate picture

  case 'GEOSCHEM'
  
      
      HCHOrates_G = PlotRates('CH2O',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of HCHO
      HCHOprodRate_G = sum(HCHOrates_G.Prod ,2);% get the producation rate of HCHO for each time interval(s)
      close all%we don't need the plot rate picture
      HCOOHrates_G = PlotRates('HCOOH',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of HCOOH
      HCOOHprodRate_G = sum(HCOOHrates_G.Prod,2);% get the producation rate of HCOOH each time interval(s)
      close all%we don't need the plot rate picture
      GLYOXrates_G = PlotRates('GLYX',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of GLYOX
      GLYOXprodRate_G =sum(GLYOXrates_G.Prod ,2);% get the producation rate of GLYOX each time interval(s)
      close all%we don't need the plot rate picture
      CH3COCH3rates_G = PlotRates('ACET',S,1,'unit','ppb_s','sumEq',1);%get hte loss and production rate of CH3COCH3
      CH3COCH3prodRate_G = sum(CH3COCH3rates_G.Prod ,2);% get the producation rate CH3COCH3 each time interval(s)     
      close all%we don't need the plot rate picture
      
end%end switch mechanism



%% Calculate the Accumulative Molar yield
 switch MECHANISM{i}
  case {'MCMv331'}
      ProdRate_M = [HCHOprodRate_M,HCOOHprodRate_M,GLYOXprodRate_M,CH3COCH3prodRate_M];
  for y = 2:size(S.Time,1)%for each end point of step
      Yield_M(y,:,j) = Yield_M(y-1,:,j) + ProdRate_M(y-1,:).*(S.Time(y)-S.Time(y-1));%Cnext = Cprevious +ProdRate/s*time(s)
  end
  
  % Find the OHt Only Yield

 % delete the same time;
  table = [Yield_M(:,:,j),S.Time];
  table2 = zeros(size(table));
  c = unique(S.Time);
  for z =  1: size(c,1)
  [row,~] = find(S.Time == c(z),1);
  table2(z,:) = table(row,:);
  end
  Yield_M(:,:,j) = table2(:,1:4);
  Time = table2(:,end);
 actual_time_M = actual_time_M(1:10,:);%we only use the OH exposure time of 1:10hr
 temp  = zeros(size(time.hour,1),4);%temporately store the molar yield at the end of each OHtime hour
for t = 1:size(actual_time_M,1)%Find the molar yield of OH at the ending of each OH exposure time.
      [row,~] = find(Time == actual_time_M(t,j));
      temp(t,:) = Yield_M(row,:,j);
end%end for t = 1:size(time.houre,1)

Yield_M(1:10,:,j) = temp;
Yield_M(11:end,:,:) = [];%get the Molar Yield for each hour

  

   case 'GEOSCHEM'
       ProdRate_G = [HCHOprodRate_G,HCOOHprodRate_G,GLYOXprodRate_G,CH3COCH3prodRate_G];
  for y = 2:size(S.Time,1)%for each end point of step
       Yield_G(y,:,j) = Yield_G(y-1,:,j) + ProdRate_G(y-1,:).*(S.Time(y)-S.Time(y-1));%Cnext = Cprevious +ProdRate/time interval*time interval
  end
  
   % Find the EndPoint Only Yield

 % delete the same time;
  table = [Yield_G(:,:,j),S.Time];
  table2 = zeros(size(table));
  c = unique(S.Time);
  for z =  1: size(c,1)
  [row,~] = find(S.Time == c(z),1);
  table2(z,:) = table(row,:);
  end
  Yield_G(:,:,j) = table2(:,1:4);
  Time = table2(:,end);
 
  actual_time_G = actual_time_G(1:10,:);%we only use the OH exposure time of 1:10hr
 temp  = zeros(size(time.hour,1),4);%temporately store the molar yield at the end of each hour
for t = 1:size(actual_time_G,1)%Find the molar yield of OH at the ending of each OH exposure time.
      [row,~] = find(Time == actual_time_G(t,j));
      temp(t,:) = Yield_G(row,:,j);
end%end for t = 1:size(time.houre,1)
Yield_G(1:10,:,j) = temp;
Yield_G(11:end,:,:) = [];
 end %end switch mechanism

     

  clear Met InitConc ChemFiles BkgdConc ModelOptions
  

    end%end for nox cocentration
end%end for swithing mechanism
  
%% Seperate Each Species
for i = 1:2%switch mechanisms
    switch MECHANISM{i}
    case {'MCMv331'}
    HCHO_Yield_M = Yield_M(:,1,:);%HCHO
    HCHO_Yield_M=[HCHO_Yield_M(:,:)];
    HCOOH_Yield_M = Yield_M(:,2,:);%HCOOH
    HCOOH_Yield_M=[HCOOH_Yield_M(:,:)];
    GLYOX_Yield_M = Yield_M(:,3,:);%GLYOX
    GLYOX_Yield_M=[GLYOX_Yield_M(:,:)];
    CH3COCH3_Yield_M = Yield_M(:,4,:);%CH3COCH3
    CH3COCH3_Yield_M=[CH3COCH3_Yield_M(:,:)];
    
    case {'GEOSCHEM'}
    HCHO_Yield_G = Yield_G(:,1,:);%HCHO
    HCHO_Yield_G=[HCHO_Yield_G(:,:)];
    HCOOH_Yield_G = Yield_G(:,2,:);%HCOOH
    HCOOH_Yield_G=[HCOOH_Yield_G(:,:)];
    GLYOX_Yield_G = Yield_G(:,3,:);%GLYOX
    GLYOX_Yield_G=[GLYOX_Yield_G(:,:)];
    CH3COCH3_Yield_G = Yield_G(:,4,:);%CH3COCH3
    CH3COCH3_Yield_G=[CH3COCH3_Yield_G(:,:)];
    end%switch MECHANISM{i}
end %for i = 1:2%2 mechanisms 

%% Plot


figure
contour([1:1:10],NO2conc,HCHO_Yield_M','r','ShowText','on');
hold on
contour([1:1:10],NO2conc,HCHO_Yield_G','b','ShowText','on');
set(gca, 'YScale', 'log')
legend('MCMv331','GeosChem');
xlabel('OH Exposure Time (h)')
ylabel('NOx(ppbv)');
head = ['HCHO Yield(with' VOC_M{v} ')']; 
title(head);
text = ['HCHO Yield(with' VOC_M{v} ').png'];
set(gca, 'YScale', 'log');
yticks([0.1,0.5,1]);
yticklabels({'0.1','0.5','1'});
saveas(gcf,text);

figure
contour([1:1:10],NO2conc,HCOOH_Yield_M','r','ShowText','on');
hold on
contour([1:1:10],NO2conc,HCOOH_Yield_G','b','ShowText','on');
set(gca, 'YScale', 'log');
yticks([0.1,0.5,1]);
yticklabels({'0.1','0.5','1'});
legend('MCMv331','GeosChem');
xlabel('OH Exposure Time (h)')
ylabel('NOx(ppbv)');
head = ['HCOOH Yield(with' VOC_M{v} ')'];
title(head);
text = ['HCOOH Yield(with' VOC_M{v} ').png'];
saveas(gcf,text);

figure
contour([1:1:10],NO2conc,GLYOX_Yield_M','r','ShowText','on');
hold on
contour([1:1:10],NO2conc,GLYOX_Yield_G','b','ShowText','on');
set(gca, 'YScale', 'log')
yticks([0.1,0.5,1]);
yticklabels({'0.1','0.5','1'});
legend('MCMv331','GeosChem');
xlabel('OH Exposure Time (h)')
ylabel('NOx(ppbv)');
head = ['GLYOX Yield(with' VOC_M{v} ')'];
title(head);
text = ['GLYOX Yield(with' VOC_M{v} ').png'];
saveas(gcf,text);

figure
contour([1:1:10],NO2conc,CH3COCH3_Yield_M','r','ShowText','on');
hold on
contour([1:1:10],NO2conc,CH3COCH3_Yield_G','b','ShowText','on');
set(gca, 'YScale', 'log')
yticks([0.1,0.5,1]);
yticklabels({'0.1','0.5','1'});
legend('MCMv331','GeosChem');
xlabel('OH Exposure Time (h)')
ylabel('NOx(ppbv)');
head = ['CH3COCH3 Yield(with' VOC_M{v} ')'];
title(head);
text = ['CH3COCH3 Yield(with' VOC_M{v} ').png'];
saveas(gcf,text);


end%End for VOC precursors