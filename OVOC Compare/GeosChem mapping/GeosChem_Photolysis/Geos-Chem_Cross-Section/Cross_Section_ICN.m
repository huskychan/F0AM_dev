% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_ICN(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	1.73E-21	5.23E-21	9.63E-21	1.55E-20 ...
        2.62E-20	2.95E-20	3.34E-20	3.63E-20	7.30E-21	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
