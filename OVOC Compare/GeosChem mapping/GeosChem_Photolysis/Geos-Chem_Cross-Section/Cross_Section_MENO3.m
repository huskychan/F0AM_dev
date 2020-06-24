% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_MENO3(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<240)=240;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T240 = [1.37E-17	1.63E-17	1.56E-17	1.41E-17	9.41E-18	4.53E-18 ...
        3.60E-18	1.64E-18	2.69E-20	5.75E-20	8.57E-20	4.68E-21 ...
        2.00E-21	8.50E-22	3.48E-22	3.74E-23	0.00E+00	0.00E+00];%X-section for temperature 240

T298 = [1.37E-17	1.63E-17	1.56E-17	1.41E-17	9.41E-18	4.53E-18 ...
        3.60E-18	1.64E-18	3.18E-20	5.98E-20	8.75E-20	6.04E-21 ...
        2.71E-21	1.22E-21	5.39E-22	6.58E-23	0.00E+00	0.00E+00];

Cross = interp1([240;298],[T240;T298],T);
Cross = Cross';
wl_cs = wl_cs';
