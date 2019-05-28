function [vnew,vnewind]=CheckShuffle(v,perm_rep)
%
% NAME:
%	CheckShuffle
%
% USAGE:
%	[vnew,vnewind] = CheckShuffle(v,perm_rep)
%
% INPUT VARIABLE(S):
%	v		Vector of integers
%	perm_rep	Maximum permitted successive repetitions of the same number
%
% OUTPUT VARIABLE(S):
%	vnew		Vector of integers obtained from v whose blocks of numbers longer than perm_rep
%			are split into smaller blocks. The elements of v and vnew are identical, only the
%			order is changed to keep blocks of numbers with a maximum length of perm_rep.
%   vnewind     Vector of indices of vnew referred to the input vector v
%
% EXAMPLE:
%	[vnew,vnewind] = CheckShuffle([1 1 1 2 2 2],2)
%	with vnew = [1 1 2 1 2 2]
%        vnewind = [1 2 5 3 4 6]

vnew=v;
N=length(v);

% Determine levels in input vector
vtmp=v;
Ntmp=length(vtmp);
c=0;
while(Ntmp>0)
	c=c+1;
	vlev(c)=vtmp(1);
	i=find(vtmp==vlev(c));
	vtmp(i)=[];
	Ntmp=length(vtmp);
end

% Randomly permute order of elements in vlev, to increase randomisation
Nlev=length(vlev);
vlev=vlev(randperm(Nlev));

% Indices of elements in v
vind=1:N;
vnewind=vind;

% Get longest block length for each level
ok=0;
while(~ok)
Lmax=zeros(1,Nlev);	% Maximum lengh of each level
iL=zeros(1,Nlev);	% Last index of elements of each level
for j=1:Nlev
	c=0;
	L=0;
	for i=1:N
		if(vnew(i)==vlev(j))
			L=L+1;
		else
			c=c+1;
			if(c==1)
				Lmax(j)=L;
				iL(j)=i-1;
			elseif (Lmax(j)<=L)
				if(i-2>0)
					if(vnew(i-2)~=vnew(i))
						Lmax(j)=L;
						iL(j)=i-1;
					end
				else
					Lmax(j)=L;
					iL(j)=i-1;
				end
			end
			L=0;
		end
	end
	if(Lmax(j)<L);
		Lmax(j)=L;
		iL(j)=i;
	end
end

% Take the first two longest blocks
[Lmaxs ind]=sort(Lmax);
iLs=iL(ind);

L1=Lmaxs(end);
L2=Lmaxs(end-1);
iL1=iLs(end);
iL2=iLs(end-1);

% Split long blocks into smaller blocks when longer than perm_rep
iF1=iL1-L1+1;
iF2=iL2-L2+1;
iM1=floor((iF1+iL1)/2);
iM2=floor((iF2+iL2)/2);

if(L1>perm_rep)
	vtmp=vnew;
	vtmp(iM2)=[];
    vtmpind=vnewind;
    vtmpind(iM2)=[];
	if(iM1>iM2)
		vnew=[vtmp(1:iM1-1) vnew(iM2) vtmp(iM1:end)];
        vnewind=[vtmpind(1:iM1-1) vnewind(iM2) vtmpind(iM1:end)];
	else
		vnew=[vtmp(1:iM1) vnew(iM2) vtmp(iM1+1:end)];
        vnewind=[vtmpind(1:iM1) vnewind(iM2) vtmpind(iM1+1:end)];
	end
elseif(L2>perm_rep)
	vtmp=vnew;
	vtmp(iM1)=[];
    vtmpind=vnewind;
    vtmpind(iM1)=[];
	if(iM2>iM1)
		vnew=[vtmp(1:iM2-1) vnew(iM1) vtmp(iM2:end)];
        vnewind=[vtmpind(1:iM2-1) vnewind(iM1) vtmpind(iM2:end)];
	else
		vnew=[vtmp(1:iM2) vnew(iM1) vtmp(iM2+1:end)];
        vnewind=[vtmpind(1:iM2) vnewind(iM1) vtmpind(iM2+1:end)];
	end
else
	ok=1;
end
end
