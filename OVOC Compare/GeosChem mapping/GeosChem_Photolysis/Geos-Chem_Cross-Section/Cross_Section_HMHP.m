% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_HMHP(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	2.18E-19 ...
        2.02E-19	1.58E-19	1.90E-20	1.92E-20	1.50E-20	3.94E-21 ...
        2.46E-21	1.68E-21	1.19E-21	5.06E-22	4.88E-23	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
