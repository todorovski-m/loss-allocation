function [LAd, LAg] = la_split(LA)
%LA_SPLIT  Splits loss allocation to loads and generators.
%
%  [LAd, LAg] = la_split(LA)
%
%  Inputs:
%    LA : Matrix of allocated losses for each pair load-generator.
%         LA(i,j) is network loss allocated to load at bus "i" due to power supply from generator "j"
%
%  Outputs:
%   LAd : Vector of allocated losses to loads.
%   LAg : Vector of allocated losses to generators.
%
%  See also LOSS_ALLOCATION.

[NB, NG] = size(LA);
% loss allocation for loads
LAd = 0.5 * LA * ones(NG,1);
% loss allocation for generators
LAg = 0.5 * ones(NB,1)' * LA;
