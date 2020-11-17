% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_IONO2(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	1.65E-18	1.26E-18	1.23E-18	1.22E-18 ...
        1.06E-18	9.73E-19	9.01E-19	7.89E-19	3.60E-19	4.79E-22];
Cross = Cross';
wl_cs = wl_cs';
