% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_IPRNO3(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [1.61E-17	1.70E-17	1.62E-17	1.51E-17	1.07E-17	5.99E-18 ...
        4.98E-18	2.65E-18	4.55E-20	1.06E-19	1.50E-19	9.44E-21 ...
        4.36E-21	1.96E-21	8.57E-22	1.18E-22	1.21E-24	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
