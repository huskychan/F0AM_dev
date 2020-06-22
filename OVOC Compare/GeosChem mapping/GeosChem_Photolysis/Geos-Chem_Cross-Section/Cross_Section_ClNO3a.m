% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_ClNO3a(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>300)=300;
T(T<200)=200;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T200 = [3.22E-19	7.35E-19	9.69E-19	1.66E-18	1.61E-18	1.77E-18 ....
        1.92E-18	2.01E-18	1.95E-19	2.80E-19	2.05E-19	2.04E-20 ...
        1.09E-20	6.66E-21	4.56E-21	2.32E-21	9.21E-22	6.96E-24];%X-section for temperature 180
T300 = [3.53E-19	8.04E-19	1.06E-18	1.82E-18	1.71E-18	1.81E-18 ...
        1.93E-18	2.00E-18	2.32E-19	3.03E-19	2.14E-19	2.79E-20 ...
        1.56E-20	1.00E-20	7.09E-21	3.40E-21	1.18E-21	9.86E-24];

Cross = interp1([200;300],[T200;T300],T);
Cross = Cross';
wl_cs = wl_cs';
