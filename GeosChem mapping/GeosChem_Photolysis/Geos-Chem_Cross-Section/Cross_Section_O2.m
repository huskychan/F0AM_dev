% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_O2(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>300)=300;
T(T<180)=180;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T180 = [1.73E-21	1.99E-22	3.00E-23	9.83E-24	7.31E-24	6.83E-24 ...
        6.24E-24	5.75E-24	1.15E-25	5.03E-25	4.15E-25	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00];%X-section for temperature 180
T260 = [2.27E-21	3.07E-22	4.94E-23	1.41E-23	7.69E-24	6.83E-24 ...
        6.24E-24	5.89E-24	1.15E-25	5.03E-25	4.15E-25	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00];
T300 = [2.76E-21	4.27E-22	7.48E-23	2.10E-23	8.35E-24	6.83E-24 ...
        6.24E-24	5.99E-24	1.15E-25	5.03E-25	4.15E-25	0.00E+00 ...
        0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00];

Cross = interp1([180;260;300],[T180;T260;T300],T);
Cross = Cross';
wl_cs = wl_cs';
