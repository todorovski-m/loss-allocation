function print_pf(ds,LA)
%PRINT_PF  Writes solution to loss_allocation.txt.
%
%  print_pf(ds,LA)
%
%  Inputs:
%    ds : Structure with the results obtained with DIST_PF
%    LA : Matrix of allocated losses obtained with LOSS_ALLOCATION
%
%  See also DIST_PF, LOSS_ALLOCATION.

[U, Sg, gen_bus, Sf, St, Sd, Yd, Sbase, f, t] = ...
    deal(ds.U,ds.Sg,ds.gen_bus,ds.Sf,ds.St,ds.Sd,ds.Yd,ds.Sbase,ds.branch(:,1),ds.branch(:,2));
fid = fopen('loss_allocation.txt','w');
fprintf(fid,'Case file: %s\n\n',ds.input_file);

[Umin, imin] = min(abs(U));
[Umax, imax] = max(abs(U));
fprintf(fid,'Umin = %10.6f pu @ %i\n',Umin,imin);
fprintf(fid,'Umax = %10.6f pu @ %i\n',Umax,imax);
[Tmin, imin] = min(angle(U)/pi*180);
[Tmax, imax] = max(angle(U)/pi*180);
fprintf(fid,'Angle min = %7.3f deg @ %i\n',Tmin,imin);
fprintf(fid,'Angle max = %7.3f deg @ %i\n\n',Tmax,imax);


fprintf(fid,' Bus     Pd(kW)    Qd(kvar)    Qc(kvar)      Pg(kW)    Qg(kvar)      U(pu)  teta(deg)\n');
NB = size(U,1);
Sd = Sd*Sbase*1000;
Sg = sparse(gen_bus,ones(size(Sg)),Sg,NB,1)*Sbase*1000;
Sg = full(Sg);
Qc = imag(U.*conj(Yd.*U)) * Sbase * 1000;
for i = 1:NB
    fprintf(fid,'%3i %11.3f %11.3f %11.3f %11.3f %11.3f %10.6f %10.3f\n',i,real(Sd(i)),imag(Sd(i)),Qc(i),real(Sg(i)),imag(Sg(i)),abs(U(i)),angle(U(i))/pi*180);
end
fprintf(fid,'Total %9.3f %11.3f %11.3f %11.3f %11.3f\n',real(sum(Sd)),imag(sum(Sd)),sum(Qc),real(sum(Sg)),imag(sum(Sg)));
DS = sum(Sg) - sum(Sd + 1j*Qc);
fprintf(fid,'\nDP = %8.5f kW\n',real(DS));
fprintf(fid,'DQ = %8.5f kvar\n\n',imag(DS));

fprintf(fid,'\nFrom  To     Pf(kW)   Qf(kvar)     Pt(kW)   Qt(kvar)     DP(kW)   DQ(kvar)\n');
DSb = (Sf - St)*Sbase*1000;
for i = 1:size(Sf,1)
    Sfi = Sf(i)*Sbase*1000;
    Sti = St(i)*Sbase*1000;
    fprintf(fid,'%4i %3i %10.3f %10.3f %10.3f %10.3f %10.5f %10.5f\n',f(i),t(i),real(Sfi),imag(Sfi),real(Sti),imag(Sti),real(DSb(i)),imag(DSb(i)));
end
fprintf(fid,'%52s %10.5f %10.5f\n','Total',real(sum(DSb)),sum(imag(DSb)));

fprintf(fid,'\nFrom  To    Re{If}(A)    Im{If}(A)    Re{It}(A)    Im{It}(A)\n');
If = ds.If;
It = ds.It;
for i = 1:size(If,1)
    fprintf(fid,'%4i %3i %12.4f %12.4f %12.4f %12.4f\n',f(i),t(i),real(If(i)),imag(If(i)),real(It(i)),imag(It(i)));
end

fprintf(fid,'\n Bus    Re{Id}(A)    Im{Id}(A)\n');
print_id(fid,1:NB,ds.Id);
fprintf(fid,'\n Bus    Re{Ig}(A)    Im{Ig}(A)\n');
print_id(fid,gen_bus,ds.Ig);

% components of load currents
J = ds.J;
fprintf(fid,'\nRe{J}(A)\n');
print_j(fid,gen_bus,real(J(:,gen_bus)));
fprintf(fid,'\nIm{J}(A)\n');
print_j(fid,gen_bus,imag(J(:,gen_bus)));

fprintf(fid,'\nActive Loss Allocation (kW)\n');
print_la(fid,gen_bus,real(LA));
fprintf(fid,'\nReactive Loss Allocation (kvar)\n');
print_la(fid,gen_bus,imag(LA));

LAsum = sum(sum(LA));
fprintf(fid,'\nTotal Allocated Losses\n');
fprintf(fid,'DP = %8.5f kW\n',real(LAsum));
fprintf(fid,'DQ = %8.5f kvar\n\n',imag(LAsum));
fprintf(fid,'DPdiff = %8.5f kW (%.2f %%)\n',real(LAsum)-real(DS),(real(LAsum)/real(DS)-1)*100);
fprintf(fid,'DQdiff = %8.5f kvar (%.2f %%)\n\n',imag(LAsum)-imag(DS),(imag(LAsum)/imag(DS)-1)*100);

fclose(fid);

function print_id(fid,bus,Id)
for i = 1:length(Id)
    fprintf(fid,'%4i %12.4f %12.4f\n',bus(i),real(Id(i)),imag(Id(i)));
end

function print_j(fid,gen_bus,J)
[m, n] = size(J);
fprintf(fid,'    ');
for i = 1:n
    fprintf(fid,'%12i',gen_bus(i));
end
fprintf(fid,'\n');
for i = 2:m
    fprintf(fid,'%4i',i);
    for j = 1:n
        fprintf(fid,'%12.4f',J(i,j));
    end
    fprintf(fid,'\n');
end

function print_la(fid,gen_bus,LA)
fprintf(fid,'Bus/Gen      1');
for i = 2:length(gen_bus)
    fprintf(fid,'%11i',gen_bus(i));
end
fprintf(fid,'\n');
for i = 2:length(LA)
    fprintf(fid,'%3i',i);
    for j = 1:length(gen_bus)
        fprintf(fid,'%11.4f',LA(i,j));
    end
    fprintf(fid,'\n');
end
