% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_I2(T,P)

% Fixed Temperature to 295x


wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)


Cross = [1.76E-17	1.61E-17	1.44E-17	1.12E-17	6.55E-18	4.55E-18 ...
          4.03E-18	3.81E-18	9.65E-19	8.46E-19	6.43E-19	3.31E-19 ...
          2.46E-19	1.83E-19	1.43E-19	7.18E-20	2.14E-20	8.27E-19];
Cross = Cross';
wl_cs = wl_cs';
