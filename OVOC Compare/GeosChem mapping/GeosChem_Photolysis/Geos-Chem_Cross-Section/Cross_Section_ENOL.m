
% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_ENOL(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	1.38E-20	1.09E-20	1.31E-20	1.60E-20 ...
        2.13E-20	2.61E-20	3.05E-20	3.30E-20	8.25E-21	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
