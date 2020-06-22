 function      OHt = getOHExposureTime(Met,InitConc,ChemFiles,BkgdConc,ModelOptions,TimeInterval,TotalTime)

%S: structure of model outputs. Must contain the following fields:
%    Time, Cnames, Chem.Rnames, Chem.Rates, Chem.f,
%    Dil,ModelOptions,Mechanism
%    Initial concentration
%TimeInterval: The time interval you want to use to calculate each OH
%exposure time(hr)
%Total Time: The total time that your model run(hr)






%% Modify the S
%temp = ModelOptions.EndPointsOnly;%record the initial S
ModelOptions.EndPointsOnly = 0;
%% MODEL RUN
% Now we call the model. Note this may take several minutes to run, depending on your system.
% Output will be saved in the "SavePath" above and will also be written to the structure S.
% Let's also throw away the inputs (don't worry, they are saved in the output structure).


 Soh = F0AM_ModelCore(Met,InitConc,ChemFiles,BkgdConc,ModelOptions);


  OHt = zeros(TotalTime,1);
  % delete the same time;
  table = [Soh.Conc.OH,Soh.Time];
  table2 = zeros(size(table));
  c = unique(Soh.Time);
  for z =  1: size(c,1)
  [row,~] = find(Soh.Time == c(z),1);
  table2(z,:) = table(row,:);
  end
  
  
  Soh.Conc.OH = table2(:,1);
  Soh.Time = table2(:,2);
  Area = 0;%initialzie the area
  row_old = 1;
  for t = 1:TotalTime
      [row,~] = find(Soh.Time == 60*60*TimeInterval*t);%Find the concentration of OH at the ending of each hour.
      for r = row_old:(row(end)-1)% for each time interval
          Area = Area+(((Soh.Conc.OH(r)+Soh.Conc.OH(r+1)) .* (Soh.Time(r+1)-Soh.Time(r)))./2);
          
      end%end for r = row_old:(row(end)-1
      OHt(t) = (Area./3600)./((0.4.*10^(-3)*8.314*Met{2,2}(t)/(6.023*Met{1,2}(t))));%hour,you can replace the SOAS.T(t+8) and SOAS.P(t+8) with your T and P
      row_old = row(1);
  end% end for t = 1:TotalTime


 

 




       

  clear Met InitConc ChemFiles BkgdConc ModelOptions

 end%end of Function


      
       
       

