% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_HOI(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	9.70E-22	4.85E-21	1.42E-20 ...
        4.81E-20	1.00E-19	1.73E-19	3.48E-19	2.60E-19	1.38E-20];
Cross = Cross';
wl_cs = wl_cs';
