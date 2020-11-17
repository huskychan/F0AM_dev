% Written by Hongyu Chen 06/20/2020


function [Cross,wl_cs] = Cross_Section_MGlyxl(T,P)

% We do not wish to extrapolate beyond JPL recommendations
T(T>999)=999;
T(T<177)=177;

wl_cs = [187	191	193	196	202	208 211	214	261	267	277	295 303	310	316	333	380	574]; % First column is wavelengths (in nm)
T177 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	2.09E-20	3.96E-20	4.40E-20	4.41E-20 ...
        3.50E-20	2.36E-20	1.81E-20	6.01E-21	1.26E-20	7.31E-22];%X-section for temperature 177

T566 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	2.09E-20	3.96E-20	4.40E-20	4.41E-20 ...
        3.50E-20	2.36E-20	1.81E-20	6.01E-21	7.05E-21	3.43E-22];
    
T999 = [0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00	0.00E+00 ...
        0.00E+00	0.00E+00	2.09E-20	3.96E-20	4.40E-20	4.41E-20 ...
        3.50E-20	2.36E-20	1.81E-20	6.01E-21	5.23E-21	2.15E-22];

Cross = interp1([177;566;999],[T177;T566;T999],T);
Cross = Cross';
wl_cs = wl_cs';
