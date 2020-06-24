% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_ETNO3 (T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>298)=298;
T(T<240)=240;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T240 = [1.67E-17	1.60E-17	1.51E-17	1.39E-17	9.46E-18	4.92E-18 ...
        4.00E-18	2.13E-18	3.47E-20	7.73E-20	1.13E-19	6.85E-21 ...
        3.03E-21	1.30E-21	5.17E-22	6.66E-23	0.00E+00	0.00E+00];%X-section for temperature 240

T298 = [1.67E-17	1.60E-17	1.51E-17	1.39E-17	9.46E-18	4.92E-18 ...
        4.00E-18	2.13E-18	4.07E-20	8.06E-20	1.16E-19	8.94E-21 ...
        4.16E-21	1.91E-21	8.24E-22	1.25E-22	0.00E+00	0.00E+00];

Cross = interp1([240;298],[T240;T298],T);
Cross = Cross';
wl_cs = wl_cs';
