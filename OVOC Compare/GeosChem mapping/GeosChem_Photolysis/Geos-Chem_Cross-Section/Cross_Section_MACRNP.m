% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_MACRNP(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	7.80E-20 ...
        7.21E-20	5.63E-20	6.79E-21	6.85E-21	5.36E-21	3.46E-20 ...
        3.24E-20	2.84E-20	2.57E-20	1.63E-20	1.73E-23	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
