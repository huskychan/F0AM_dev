
[Cross,wavelength] = Cross_Section_O3_Geo(295,750);
QYin = zeros(size(wavelength,1),2);
QYin(:,2) = 1;
QYin(:,1) = wavelength;
LFin = zeros(size(QYin));
LFin(:,1) = wavelength;
Cross = [wavelength,Cross];
LFin(:,2) = [1.39E+12	1.63E+12	1.66E+12	9.28E+11	7.84E+12	...
    4.68E+12 9.92E+12	1.22E+13	6.36E+14	4.05E+14	3.15E+14	...
    5.89E+14 7.68E+14	5.05E+14	8.90E+14	3.85E+15	1.55E+16	2.13E+17];
J = J_BottomUp_New(LFin,298,50);