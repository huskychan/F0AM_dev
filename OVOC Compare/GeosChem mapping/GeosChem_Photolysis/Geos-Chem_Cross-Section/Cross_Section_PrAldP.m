% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_PrAldP(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	1.80E-23	0.00E+00	3.43E-22	3.13E-19 ...
        2.89E-19	2.26E-19	5.70E-20	7.26E-20	7.27E-20	6.11E-20 ...
        4.98E-20	3.82E-20	2.64E-20	6.56E-21	8.22E-23	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
