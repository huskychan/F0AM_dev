% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_CH2IBr(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<273)=273;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T273 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	1.16E-18	2.01E-18	1.85E-18	1.49E-18	8.44E-19 ...
        4.85E-19	3.06E-19	2.06E-19	6.62E-20	2.14E-21	0.00E+00];%X-section for temperature 273

T298 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	2.68E-19	7.47E-19 ...
        3.54E-19	1.67E-19	1.03E-18	8.25E-19	5.80E-19	4.20E-19 ...
        2.04E-19	1.11E-19	6.57E-20	1.93E-20	6.82E-22	0.00E+00];

Cross = interp1([273;298],[T273;T298],T);
Cross = Cross';
wl_cs = wl_cs';
