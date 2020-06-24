% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_NITP(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	3.12E-19 ...
        2.88E-19	2.25E-19	2.72E-20	2.74E-20	2.14E-20	1.66E-20 ...
        8.05E-21	4.35E-21	2.45E-21	1.05E-21	6.97E-23	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
