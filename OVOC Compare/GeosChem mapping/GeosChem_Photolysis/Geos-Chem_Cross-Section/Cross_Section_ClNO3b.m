% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_ClNO3b(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>300)=300;
T(T<200)=200;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T200 = [2.15E-19	4.90E-19	6.46E-19	1.11E-18	1.08E-18	1.18E-18 ...
        1.28E-18	1.34E-18	1.30E-19	1.87E-19	1.36E-19	1.36E-20 ...
        7.26E-21	4.19E-21	2.37E-21	7.06E-22	2.64E-23	0.00E+00];%X-section for temperature 180
T300 = [2.35E-19	5.36E-19	7.03E-19	1.21E-18	1.14E-18	1.20E-18 ...
        1.29E-18	1.33E-18	1.55E-19	2.02E-19	1.43E-19	1.86E-20 ...
        1.04E-20	6.30E-21	3.68E-21	1.05E-21	3.33E-23	0.00E+00];

Cross = interp1([200;300],[T200;T300],T);
Cross = Cross';
wl_cs = wl_cs';
