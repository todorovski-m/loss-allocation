function ds = dist_pf(input_file,epsilon,iter_max)
%DIST_PF  Solves the power flow using a backward-forward sweep method.
%
%  ds = radial_pf(input_file,epsilon,iter_max)
%
%  Inputs:
%    input_file : String containing the name of the file with the case data (default is 'case5')
%                 or a structure with the case data (ex. see 'case5')
%       epsilon : Termination tolerance on per unit voltage mismatch
%      iter_max : Maximum number of iterations
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
%
%  See also VCPF.

%% default arguments
if nargin < 3
    iter_max = 20;
    if nargin < 2
        epsilon = 1e-8;
        if nargin < 1
            input_file = 'case5';
        end
    end
end
%% data preparation
% read input data
if isstruct(input_file)
    ds = input_file;
else
    ds = feval(input_file);
end
% sort the branches in ascending order of receiving node
t = ds.branch(:,2);
[~, i] = sort(t);
ds.branch = ds.branch(i,:);
% fill data vectors
[NB, NL, f, t, Zbranch, Ybranch, Ysh, Sd] = data_sep(ds);
if isfield(ds,'gen')
    gen_bus = ds.gen(:,1);
    Sg = (ds.gen(:,2)+1j*ds.gen(:,3))/1000/ds.Sbase;
    Ug = ds.gen(:,4);
    gen_type = ds.gen(:,5);
else
    gen_bus = []; Sg = []; Ug = []; gen_type = [];
end
% make Yd which is bus shunt admittance equal to the sum of all branch shunt
% admittances and shunt devices admittances
Yd = sparse(f, f, Ybranch/2, NB, NB) + sparse(t, t, Ybranch/2, NB, NB);
Yd = Yd * ones(NB,1) + Ysh;
%% power flow
tic
[U, Sslack, Sg, Sf, St, iter] = vcpf(ds.Uslack,NB,NL,f,Zbranch,Ybranch,Yd,Sd,gen_bus,Sg,Ug,gen_type,epsilon,iter_max);
t = toc;
%% save the solution in the ds structure
ds.U = U;
ds.gen_bus = [1; gen_bus];
ds.Sg = [Sslack; Sg];
ds.Sf = Sf;
ds.St = St;
ds.iter = iter;
ds.time = t;
ds.Sd = Sd;
ds.Yd = Yd;
ds.Ybranch = Ybranch;
ds.input_file = input_file;
