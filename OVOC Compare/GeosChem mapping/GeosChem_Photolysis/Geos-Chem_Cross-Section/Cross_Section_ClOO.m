% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_ClOO(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [6.11E-18	6.11E-18	6.11E-18	6.11E-18	6.11E-18	6.11E-18 ...
        6.11E-18	6.11E-18	1.31E-17	3.65E-18	2.37E-18	2.00E-18 ...
        2.00E-18	2.00E-18	2.00E-18	2.00E-18	2.00E-18	2.00E-18];
Cross = Cross';
wl_cs = wl_cs';
