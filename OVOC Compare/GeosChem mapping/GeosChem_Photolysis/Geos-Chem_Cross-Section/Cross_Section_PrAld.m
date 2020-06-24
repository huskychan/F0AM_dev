% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_PrAld(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	1.80E-23	0.00E+00	3.43E-22	5.34E-22 ...
         6.04E-22	6.84E-22	2.99E-20	4.52E-20	5.12E-20	5.55E-20 ...
         4.63E-20	3.58E-20	2.44E-20	5.84E-21	1.25E-23	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
