% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_IO(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	2.62E-19	5.09E-18	5.19E-19];
Cross = Cross';
wl_cs = wl_cs';
