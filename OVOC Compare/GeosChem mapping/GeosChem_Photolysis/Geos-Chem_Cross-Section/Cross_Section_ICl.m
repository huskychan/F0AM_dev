% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_ICl(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
         8.15E-20	1.30E-19	3.26E-19	1.62E-19	8.16E-20	4.93E-20 ...
         2.18E-20	1.98E-21	0.00E+00	0.00E+00	1.19E-19	1.03E-19];
Cross = Cross';
wl_cs = wl_cs';
