SpeciesToAdd = {...
'O1D';'H2O';'O3'; 'OH';};

AddSpecies


i=i+1;
Rnames{i} = 'O1D + H2O = 2.000OH';
k(:,i) = 1.63E-10.*exp(60./T);
Gstr{i,1} = 'O1D'; Gstr{i,2} = 'H2O'; 
fO1D(i)=fO1D(i)-1; fH2O(i)=fH2O(i)-1; fOH(i)=fOH(i)+2.000; 

i=i+1;
Rnames{i} = 'O3 + hv = O + O2';
k(:,i) = JO3P;
Gstr{i,1} = 'O3'; 
fO3(i)=fO3(i)-1; fO(i)=fO(i)+1; 