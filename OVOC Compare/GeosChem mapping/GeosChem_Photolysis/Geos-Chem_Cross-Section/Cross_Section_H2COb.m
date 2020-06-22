% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_H2COb(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<223)=223;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T223 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	3.64E-21	5.79E-21	5.32E-21	8.18E-21 ...
        7.92E-21	4.01E-21	1.08E-20	1.08E-20	2.09E-22	0.00E+00];%X-section for temperature 180

T298 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	3.65E-21	5.77E-21	5.31E-21	8.15E-21 ...
        7.91E-21	4.00E-21	1.09E-20	1.09E-20	2.08E-22	0.00E+00];

Cross = interp1([223;298],[T223;T298],T);
Cross = Cross';
wl_cs = wl_cs';
