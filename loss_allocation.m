function [ds,LA,gen_bus] = loss_allocation(input_file,epsilon,iter_max,save_out)
%LOSS_ALLOCATION  Calculates loss allocation for each pair load-generator.
%
%  [ds,LA,gen_bus] = loss_allocation(input_file,epsilon,iter_max,save_out)
%  [ds,LA,gen_bus] = loss_allocation(input_file)
%
%  Inputs:
%    input_file : String containing the name of the file with the case data (default is 'case5')
%       epsilon : Termination tolerance on per unit voltage mismatch (default is 1e-8)
%      iter_max : Maximum number of iterations
%      save_out : Logical variable which indicates whether output file should be written
%
%  Outputs:
%    ds : Structure with the results with the followind fields:
%       Uslack, Ubase, Sbase, branch, gen : data from the input case
%       U : Bus voltages
%       Sg, gen_bus : Generator bus indicies and power outputs 
%       Sf, St : Branch flows at "from" and "to" ends
%       iter, time : Number of iterations and calculation time
%       Sd, Yd : Apparent load demand and shunt admittances at buses (includes capacitors
%                and branch shunt admittances)
%       Ybranch : Branch shunt admittances
%       input_file : Input file name
%    LA : Matrix of allocated losses for each pair load-generator.
%         LA(i,j) is network loss allocated to load at bus "i" due to power supply from generator "j"
%    gen_bus : Vector with generator buses
%
%  See also DIST_PF, TRACE_FLOW.

%% default arguments
if nargin < 4
    save_out = true;
    if nargin < 3
        iter_max = 20;
        if nargin < 2
            epsilon = 1e-8;
            if nargin < 1
                input_file = 'case5';
            end
        end
    end
end
%% power flow
ds = dist_pf(input_file,epsilon,iter_max);
Ibase = ds.Sbase*1000/ds.Ubase;
[U, Sg, gen_bus, Sf, St, Sd, Yd] = deal(ds.U,ds.Sg,ds.gen_bus,ds.Sf,ds.St,ds.Sd,ds.Yd);
[f, t] = deal(ds.branch(:,1),ds.branch(:,2));
If = conj(Sf./U(f)) - ds.Ybranch/2.*U(f); % substract branch charge currents so that If = It
It = conj(St./U(t)) + ds.Ybranch/2.*U(2:end);
NB = length(U);
NG = length(gen_bus);
%% loss allocation
Id = conj(Sd./U); % load currents
Ic = Yd.*U; % branch charge currents
Id = Id + Ic;
Ig = conj(Sg./U(gen_bus)); % generator currents
% calculate components of load currents by matrix method
Jr = trace_flow(real(Id),f,t,real(If),gen_bus,real(Ig)); % real parts
Ji = trace_flow(-imag(Id),f,t,-imag(If),gen_bus,-imag(Ig)); % imaginary parts (we take negative since the imaginary parts are lagging and are negative at loads, therefore we make them positive)
J = Jr - 1j*Ji;
ds.If = If*Ibase;
ds.It = It*Ibase;
ds.Id = Id*Ibase;
ds.Ig = Ig*Ibase;
ds.J  = J*Ibase;
% calculate voltage difference between each bus and each generator bus
DU = ones(NB,1)*U(gen_bus).' - repmat(U,1,NG);
% calculate loss allocation for supplying load by each generator
LA = DU .* conj(J(:,gen_bus)) * ds.Sbase * 1000;
%% solution print
if save_out
    print_pf(ds,LA);
end