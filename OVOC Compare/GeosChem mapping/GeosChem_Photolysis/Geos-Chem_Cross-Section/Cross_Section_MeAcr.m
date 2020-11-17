% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_MeAcr(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	9.45E-24	2.85E-23	5.25E-23	7.91E-23 ...
        1.18E-22	1.50E-22	1.78E-22	1.96E-22	3.98E-23	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
