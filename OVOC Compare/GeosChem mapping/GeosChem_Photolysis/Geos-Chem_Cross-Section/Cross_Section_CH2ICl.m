% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_CH2ICl(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<223)=223;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T223 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	2.38E-19	5.87E-19 ...
        2.12E-19	1.15E-19	1.09E-18	8.45E-19	5.52E-19	3.73E-19 ...
        1.65E-19	8.69E-20	5.13E-20	1.21E-20	5.63E-22	0.00E+00];%X-section for temperature 273

T298 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	2.68E-19	7.47E-19 ...
        3.54E-19	1.67E-19	1.03E-18	8.25E-19	5.80E-19	4.20E-19 ...
        2.04E-19	1.11E-19	6.57E-20	1.93E-20	6.82E-22	0.00E+00];

Cross = interp1([223;298],[T223;T298],T);
Cross = Cross';
wl_cs = wl_cs';
