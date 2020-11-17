SpeciesToAdd = {...
'O3';'OH';};

AddSpecies


%% PHOTOLYSIS
% ------ INORGANICS ------
[fO1D_H2O,fO1D_H2] = O1DReactionFraction(T,M,H2O); %GC assumes O1D steady-state

i=i+1;
Rnames{i}='O3 + hv = OH + OH';
k(:,i) = JO1D.*fO1D_H2O;
Gstr{i,1} = 'O3'; 
fO3(i)=fO3(i)-1;  fOH(i)=fOH(i)+1; fOH(i)=fOH(i)+1; 