% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_O3_Geo(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<218)=218;

wl_cs = [187	191	193	196	202	208
         211	214	261	267	277	295
         303	310	316	333	380	574]'; % First column is wavelengths (in nm)
T218 = [5.99E-19	4.86E-19	4.31E-19	3.65E-19	3.41E-19	4.85E-19
6.53E-19	9.32E-19	8.76E-18	3.51E-18	1.51E-18	7.93E-19
2.46E-19	8.90E-20	3.66E-20	4.54E-21	6.17E-23	1.67E-21];
T258 = [5.99E-19	4.86E-19	4.31E-19	3.67E-19	3.42E-19	4.85E-19
6.52E-19	9.30E-19	8.83E-18	3.57E-18	1.55E-18	8.26E-19
2.62E-19	9.74E-20	4.14E-20	5.52E-21	6.17E-23	1.67E-21];
T298 = [];
T218(isnan(T218))= T295(isnan(T218));

Cross = interp1([218;295],[T218'; T295'],T);
Cross = Cross';