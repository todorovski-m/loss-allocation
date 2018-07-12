function ds = case36()
% Network data for 33-bus network from
% M. E. Baran and F. F. Wu, "Network reconfiguration in distribution systems
% for loss reduction and load balancing," in IEEE Transactions on Power
% Delivery, vol. 4, no. 2, pp. 1401-1407, Apr 1989.
% doi: 10.1109/61.25627
%
% Three generator added via transformers 8-34, 18-35 and 33-36 as in
% E. Carpaneto, G. Chicco and J. S. Akilimali, "Branch current decomposition
% method for loss allocation in radial distribution systems with distributed
% generation," in IEEE Transactions on Power Systems, vol. 21, no. 3,
% pp. 1170-1179, Aug. 2006.
% doi: 10.1109/TPWRS.2006.876684

ds.Uslack = 1;
ds.Ubase = 12.66; % Base voltage, line-to-line (kV)
ds.Sbase = 1; % Base power (MVA)
Zb = 12.66^2; % R and X in the second paper are given in pu, multiply by Zb to get Ohms
ds.branch = [
%  From  To   R(Ohms)   X(Ohms)  B(uS)   P(kW) Q(kvar) Qc(kvar)
     1    2    0.0922    0.0470      0     100      60        0
     2    3    0.4930    0.2511      0      90      40        0
     3    4    0.3660    0.1864      0     120      80        0
     4    5    0.3811    0.1941      0      60      30        0
     5    6    0.8190    0.7070      0      60      20        0
     6    7    0.1872    0.6188      0     200     100        0
     7    8    0.7114    0.2351      0     200     100        0
     8    9    1.0300    0.7400      0      60      20        0
     9   10    1.0440    0.7400      0      60      20        0
    10   11    0.1966    0.0650      0      45      30        0
    11   12    0.3744    0.1238      0      60      35        0
    12   13    1.4680    1.1550      0      60      35        0
    13   14    0.5416    0.7129      0     120      80        0
    14   15    0.5910    0.5260      0      60      10        0
    15   16    0.7463    0.5450      0      60      20        0
    16   17    1.2890    1.7210      0      60      20        0
    17   18    0.7320    0.5740      0      90      40        0
     2   19    0.1640    0.1565      0      90      40        0
    19   20    1.5042    1.3554      0      90      40        0
    20   21    0.4095    0.4784      0      90      40        0
    21   22    0.7089    0.9373      0      90      40        0
     3   23    0.4512    0.3083      0      90      50        0
    23   24    0.8980    0.7091      0     420     200        0
    24   25    0.8960    0.7011      0     420     200        0
     6   26    0.2030    0.1034      0      60      25        0
    26   27    0.2842    0.1447      0      60      25        0
    27   28    1.0590    0.9337      0      60      20        0
    28   29    0.8042    0.7006      0     120      70        0
    29   30    0.5075    0.2585      0     200     600        0
    30   31    0.9744    0.9630      0     150      70        0
    31   32    0.3105    0.3619      0     210     100        0
    32   33    0.3410    0.5302      0      60      40        0
     8   34    0.0010*Zb 0.0490*Zb   0       0       0        0
    18   35    0.0240*Zb 0.1176*Zb   0       0       0        0
    33   36    0.0240*Zb 0.1176*Zb   0       0       0        0
];
ds.gen = [
%   Bus  P(kW)  Q(kvar) U(pu) Type (1-PQ, 2-PU)
    34    240   240*0.4  1.00    1
    35    400   400*0.4  1.00    1
    36    400       100  1.00    2
     ];
