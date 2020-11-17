% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_INO(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	2.44E-17	6.25E-18	2.00E-18	1.43E-18 ...
        7.63E-19	4.42E-19	4.15E-19	4.29E-19	7.39E-19	8.37E-20];
Cross = Cross';
wl_cs = wl_cs';
