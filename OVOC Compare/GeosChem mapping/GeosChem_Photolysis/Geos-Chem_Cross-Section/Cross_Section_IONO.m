% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_IONO(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        1.97E-18	1.94E-18	1.69E-18	1.30E-18	9.28E-19	6.27E-19 ...
        3.37E-19	2.55E-19	2.60E-19	3.39E-19	8.96E-20	0.00E+00];
Cross = Cross';
wl_cs = wl_cs';
