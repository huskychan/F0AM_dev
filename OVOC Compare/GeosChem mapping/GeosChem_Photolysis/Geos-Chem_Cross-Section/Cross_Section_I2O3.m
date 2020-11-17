% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_I2O3(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	9.36E-19 ...
        3.99E-18	3.37E-18	3.10E-18	2.36E-18	9.87E-19	4.86E-20];
Cross = Cross';
wl_cs = wl_cs';
