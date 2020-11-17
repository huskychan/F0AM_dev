% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_Acet_b(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<235)=223;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T235 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	3.68E-22	2.46E-22	1.16E-22 ...
        2.65E-23	6.01E-24	1.50E-24	4.21E-26	0.00E+00	0.00E+00];%X-section for temperature 235;

T260 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	1.25E-21	1.02E-21	5.66E-22 ...
        1.68E-22	4.92E-23	1.48E-23	5.60E-25	0.00E+00	0.00E+00];

T298 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	4.21E-21	4.23E-21	2.80E-21 ...
        1.09E-21	4.08E-22	1.50E-22	7.71E-24	0.00E+00	0.00E+00];

Cross = interp1([235;260;298],[T235;T260;T298],T);
Cross = Cross';
wl_cs = wl_cs';
