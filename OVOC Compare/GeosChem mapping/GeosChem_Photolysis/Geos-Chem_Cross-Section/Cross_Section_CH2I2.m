% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_CH2I2(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<273)=273;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T273 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	9.20E-19	4.05E-18 ...
        3.95E-18	3.67E-18	1.57E-18	3.14E-18	3.79E-18	3.77E-18 ...
        3.47E-18	3.12E-18	2.68E-18	1.36E-18	5.36E-20	0.00E+00];%X-section for temperature 273

T298 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	9.20E-19	4.05E-18
        3.95E-18	3.68E-18	1.59E-18	3.07E-18	3.70E-18	3.71E-18
        3.45E-18	3.12E-18	2.69E-18	1.38E-18	5.90E-20	0.00E+00];

Cross = interp1([273;298],[T273;T298],T);
Cross = Cross';
wl_cs = wl_cs';
