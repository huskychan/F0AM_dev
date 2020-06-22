% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_H2COa(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<223)=223;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T223 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	3.14E-21	1.02E-20	1.27E-20	2.32E-20 ...
        2.50E-20	1.13E-20	2.18E-20	4.75E-21	0.00E+00	0.00E+00];%X-section for temperature 180

T298 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	3.15E-21	1.02E-20	1.27E-20	2.32E-20 ...
        2.50E-20	1.13E-20	2.19E-20	4.75E-21	0.00E+00	0.00E+00];

Cross = interp1([223;298],[T223;T298],T);
Cross = Cross';
wl_cs = wl_cs';
