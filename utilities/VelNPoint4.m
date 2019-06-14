function [Vx,Vy,Ax,Ay,Vtheta,Vrho,Atheta,Arho,V,A,rho] = VelNPoint4(X,Y,T,X0,Y0,NPoint)

% Calculation of velocity based on NPoint linear fit using
% Least-Square method
% The idea is to fit the equations of a piecewise uniformly
% accelerated motion to the raw eye position data (x,y) in the range [t0,tN],
% t0 being the initial time, tN the last time:
% x(t) = ax (t-tm)^2/2 + vx (t-tm) + x0
% y(t) = ay (t-tm)^2/2 + vy (t-tm) + y0
% where tm is the time at a certain point in the the interval [t0,tN]. This
% can be the initial time, final time or time at the mid-interval. The end
% time is chosen by default here.
% If one has NPoint data points, we have
% for x
% x(t0) = ax (t0-tm)^2/2 + vx (t0-tm) + x0
% x(t1) = ax (t1-tm)^2/2 + vx (t1-tm) + x0
% x(t2) = ax (t2-tm)^2/2 + vx t2 + x0
% ...
% and for y
% y(t0) = ay (t0-tm)^2/2 + vy (t0-tm) + y0
% y(t1) = ay (t1-tm)^2/2 + vy (t1-tm) + y0
% y(t2) = ay (t2-tm)^2/2 + vy (t2-tm) + y0
% ...
% One can put these in a matrix form
%   [(t0-tm)^2 (t0-tm) 1]  [ax]   [x(t0)]
%   [(t1-tm)^2 (t1-tm) 1]  [vx] = [x(t1)]
%   [(t2-tm)^2 (t2-tm) 1]  [x0]   [x(t2)]
%   [(t3-tm)^2 (t3-tm) 1]         [x(t3)]
%             ...                   ...
% and same for y.
% The matrix is called MT, unknown variables are Solx (or
% Soly), right-hand side is eyeXX (or eyeYY).

% Initialize vector of velocities
sz=size(X);
V = zeros(sz(1),sz(2));
A = zeros(sz(1),sz(2));
Vx = zeros(sz(1),sz(2));
Vy = zeros(sz(1),sz(2));
Ax = zeros(sz(1),sz(2));
Ay = zeros(sz(1),sz(2));
Vrho = zeros(sz(1),sz(2));
Vtheta = zeros(sz(1),sz(2));

eyeTT=zeros(NPoint,1);
eyeXX=zeros(NPoint,1);
eyeYY=zeros(NPoint,1);

% Point where V and A are calculated in the interval [1,Npoint]
% m=1: first point of the interval
% m=NPoint: last point of the interval
% m=floor(NPoint/2): mid-point of the interval
m=floor(NPoint/2);

for i=m:length(X)-NPoint+m
        eyeTT(:,1)=T(i-m+1:i+NPoint-m);  % NPoint time data points from present time backward
        eyeXX(:,1)=X(i-m+1:i+NPoint-m);  % NPoint X data points from present time backward
        eyeYY(:,1)=Y(i-m+1:i+NPoint-m);  % NPoint Y data points from present time backward

        % Define time at the middle of the interval
        tm=eyeTT(m);

        %%%%%%%%%%%%%%%II. The second methods after acceleration was added
        % Solve matrix equations to get Ax, Ay, Vx, Vy
         MT=[(eyeTT-tm).^2/2,(eyeTT-tm),ones(NPoint,1)];
         ML=MT'*MT;
         MRx=MT'*eyeXX;
         MRy=MT'*eyeYY;
         Solx=ML\MRx;
         Soly=ML\MRy;
         Ax(i)=Solx(1);
         Vx(i)=Solx(2);
         Ay(i)=Soly(1);
         Vy(i)=Soly(2);
         V(i)=sqrt(Vx(i)^2+Vy(i)^2);
         A(i)=sqrt(Ax(i)^2+Ay(i)^2);
         
         % Calculate radial and angular velocities in a polar coordinate
         % system (rho, theta)
         
         [theta,rho] = cart2pol(X(i)-X0,Y(i)-Y0); % X(1) and Y(1) are considered as reference point
         Vrho(i) = Vx(i)*cos(theta) + Vy(i)*sin(theta);
         Vtheta(i) = -sin(theta)*Vx(i)/rho + cos(theta)*Vy(i)/rho;
         Arho(i) = Ax(i)*cos(theta) - Vx(i)*sin(theta)*Vtheta(i) + ...
                Ay(i)*sin(theta) + Vy(i)*cos(theta)*Vtheta(i);
         Atheta(i) = -cos(theta)*Vtheta(i)*Vx(i)/rho - sin(theta)*Ax(i)/rho + sin(theta)*Vx(i)/rho^2*Vrho(i)...
             - sin(theta)*Vtheta(i)*Vy(i)/rho + cos(theta)*Ay(i)/rho - cos(theta)*Vy(i)/rho^2*Vrho(i);
end

end