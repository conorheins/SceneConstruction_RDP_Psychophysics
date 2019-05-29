function [ dotData_new ] = update_dots( dotData )
%UPDATE_DOTS Function that takes current dot positions/velocities/lifetimes
%and outputs data relevant for the next frame to be drawn
%   Detailed explanation goes here


dotData_new = dotData;

dotData_new.dotPos = dotData_new.dotPos + dotData_new.dxdy;

x = dotData_new.dotPos(1,:);
y = dotData_new.dotPos(2,:);

x(x<dotData_new.l) = x(x<dotData_new.l) + dotData_new.apSizes(x<dotData_new.l,1)';
x(x>dotData_new.r) = x(x>dotData_new.r) - dotData_new.apSizes(x>dotData_new.r,1)';
y(y<dotData_new.b) = y(y<dotData_new.b) + dotData_new.apSizes(y<dotData_new.b,2)';
y(y>dotData_new.t) = y(y>dotData_new.t) - dotData_new.apSizes(y>dotData_new.t,2)';


% increment the lives of the dots
dotData_new.lives = dotData_new.lives + 1;

%find the 'dead' dots
deadDots = mod(dotData_new.lives,dotData_new.lifetimes)==0;
     
%replace the positions of the dead dots to a random location
x(deadDots) = (rand(1,sum(deadDots))-.5).*dotData_new.apSizes(deadDots,1)' + dotData_new.centers(deadDots,1)';
y(deadDots) = (rand(1,sum(deadDots))-.5).*dotData_new.apSizes(deadDots,2)' + dotData_new.centers(deadDots,2)';

dotData_new.dotPos = [x;y];


end

