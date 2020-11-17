% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_MeVK(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>999)=999;
T(T<177)=177;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T177 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	1.80E-22	4.76E-21	5.47E-21	5.83E-21 ...
        5.24E-21	4.48E-21	3.67E-21	1.71E-21	9.06E-23	0.00E+00];%X-section for temperature 177;

T566 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	1.01E-22	2.67E-21	3.07E-21	3.28E-21 ...
        2.94E-21	2.52E-21	2.06E-21	9.60E-22	5.08E-23	0.00E+00];

T999 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	6.93E-23	1.83E-21	2.11E-21	2.25E-21 ...
        2.02E-21	1.73E-21	1.41E-21	6.59E-22	3.48E-23	0.00E+00];

Cross = interp1([177;566;999],[T177;T566;T999],T);
Cross = Cross';
wl_cs = wl_cs';
