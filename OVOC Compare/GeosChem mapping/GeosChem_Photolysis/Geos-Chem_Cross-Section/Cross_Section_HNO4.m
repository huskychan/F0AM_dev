% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_HNO4(T,P)

% Fixed Temperature to 298x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [4.63E-18	7.58E-18	8.41E-18	7.48E-18	4.74E-18	2.85E-18 ...
        2.22E-18	1.84E-18	2.80E-19	2.21E-19	1.54E-19	2.69E-20 ...
        1.17E-20	5.68E-21	3.10E-21	8.27E-22	1.31E-23	4.69E-23];
Cross = Cross';
wl_cs = wl_cs';