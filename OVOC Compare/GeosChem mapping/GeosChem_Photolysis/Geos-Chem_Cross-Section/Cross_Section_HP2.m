% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_HP2(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	6.24E-19 ...
        5.76E-19	4.50E-19	5.43E-20	5.48E-20	4.29E-20	1.13E-20 ...
        7.04E-21	4.81E-21	3.39E-21	1.45E-21	1.40E-22	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
