% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_NPRNO3(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [1.77E-17	1.70E-17	1.62E-17	1.50E-17	1.06E-17	5.89E-18 ...
        4.89E-18	2.62E-18	4.40E-20	8.94E-20	1.37E-19	9.85E-21 ...
        4.30E-21	1.92E-21	8.31E-22	2.14E-22	0.00E+00	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
