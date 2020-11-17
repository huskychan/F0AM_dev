% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_CH3I(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<210)=210;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T210 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        3.28E-20	4.50E-20	8.68E-19	2.11E-19	6.60E-20	2.84E-20 ...
        8.99E-21	4.08E-21	2.12E-21	3.56E-22	2.79E-24	0.00E+000];%X-section for temperature 210

T298 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        3.54E-20	4.77E-20	8.38E-19	2.43E-19	9.28E-20	4.62E-20 ...
        1.51E-20	6.44E-21	3.28E-21	6.68E-22	9.71E-24	0.00E+00];

Cross = interp1([210;298],[T210;T298],T);
Cross = Cross';
wl_cs = wl_cs';
