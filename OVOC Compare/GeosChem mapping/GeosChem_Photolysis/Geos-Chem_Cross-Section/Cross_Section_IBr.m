% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_IBr(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
         0.00E+00	0.00E+00	2.02E-19	1.78E-19	1.58E-19	1.48E-19 ...
         1.10E-19	8.05E-20	6.29E-20	3.12E-20	8.04E-20	3.41E-19];
Cross = Cross';
wl_cs = wl_cs';
