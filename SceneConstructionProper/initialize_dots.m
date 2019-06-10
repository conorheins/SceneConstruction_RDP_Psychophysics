function [ dotData ] = initialize_dots(dotParams,patt_id,ifi,ppd)
% function dotData = initialize_dots(dotParams)
%INITIALIZE_DOTS Initializes data (positions, directions, coherent indices,
%etc.) for a single RDP with pattern index patt_id, and returns this data in a dotData structure

x = (rand(1,dotParams(patt_id).nDots)-.5) * dotParams(patt_id).apSizes(1) + dotParams(patt_id).centers(1);

y = (rand(1,dotParams(patt_id).nDots)-.5) * dotParams(patt_id).apSizes(2) + dotParams(patt_id).centers(2);

dotData.dotPos = [x;y];

% get indices of dots that will be moving coherently
coh_idx = rand(1,dotParams(patt_id).nDots) < dotParams(patt_id).cohers/100;

% initialize motion vectors of all dots to four orthogonal random directions 
rand_directions = 90.*randi(4,1,dotParams(patt_id).nDots) .* pi/180;

% have to convert speed parameter into orthogonal updates in x and y directions
% and also have to convert from visual degrees to pixels  
% and have to multiply by interframe interval to get it into flip-wise update
speed_dxy = ifi * ppd * sqrt( (dotParams(patt_id).speeds.^2)./2 ); 
dx = speed_dxy*sin(rand_directions);
dy = speed_dxy*cos(rand_directions);

dx(coh_idx) = speed_dxy*sin(dotParams(patt_id).directions * pi/180);
dy(coh_idx) = speed_dxy*cos(dotParams(patt_id).directions * pi/180);

dotData.dxdy = [dx;dy];

dotData.l = dotParams(patt_id).centers(1)-dotParams(patt_id).apSizes(1)/2 * ones(1,dotParams(patt_id).nDots);
dotData.r = dotParams(patt_id).centers(1)+dotParams(patt_id).apSizes(1)/2 * ones(1,dotParams(patt_id).nDots);
dotData.b = dotParams(patt_id).centers(2)-dotParams(patt_id).apSizes(2)/2 * ones(1,dotParams(patt_id).nDots);
dotData.t = dotParams(patt_id).centers(2)+dotParams(patt_id).apSizes(2)/2 * ones(1,dotParams(patt_id).nDots);

dotData.apSizes = repmat(dotParams(patt_id).apSizes,dotParams(patt_id).nDots,1);

dotData.lifetimes = dotParams(patt_id).lifetimes*ones(1,dotParams(patt_id).nDots);

dotData.centers = repmat(dotParams(patt_id).centers,dotParams(patt_id).nDots,1);

dotData.size = dotParams(patt_id).dotSizes;

dotData.lives = ceil(rand(1,length(dotData.lifetimes)).*dotData.lifetimes);

dotData.dotType = dotParams(patt_id).dotTypes;

end

