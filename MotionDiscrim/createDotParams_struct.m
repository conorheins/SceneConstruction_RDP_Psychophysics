function [ dotParams ] = createDotParams_struct(screenRect,numPatterns,varargin)
% CREATE_DOTPARAMSSTRUCT 
% This function creates a structure containing the
% parameters for numPatterns x RDPs to be displayed in a Psychtoolbox window screenRect, using
% name-value pair arguments as described below:
% INPUTS: screenRect      -- dimensions of the window on which the RDPs will be drawn (in pixels, a 1 x 4 vector) 
%         numPatterns     -- number of different random dot patterns (RDPs) to create
%                            parameters for
%         centers         -- centers in [x y] coordinates (relative to the
%                            upper-left corner of a display screen, in pixels)
%                            of each pattern. One row per RDP
%         apSizes         -- aperture sizes of each RDP (basically how each
%                            RDP horizontally & vertically extends)
%         edge_spillovers -- how much the quadrant should respectively extend beyond the
%                            width and height of the aperture, in pixels
%         nDots           -- number of dots
%         speeds          -- speed of motion, either a single number of vector,
%                            as with centers/apSizes above^
%         directions      -- direction of motion, single number or vector as
%                            above
%         cohers          -- coherence of motion, either a single number
%                            (assumed to extend to all patterns) or a vector
%                            with length == numPatterns
%         lifetimes       -- lifetimes of dots in RDP(i)
%         dotSizes        -- size of dots in pattern, either single number or
%                            vector as above
%         dotTypes        -- type of dots (0 through 4), a parameter to be passed to
%                            Screen('DrawDots')
% OUTPUTS: dotParams: structure array containing the relevant
% parameters/fields
% for each RDP (i-th row of the structure array stores the parameters for
% the i-th RDP)

if ~exist('screenRect','var') || isempty(screenRect)
    error('First argument must be the dimensions of the drawing window in pixels (a 1 x 4 vector)')
end

if ~exist('numPatterns','var') || isempty(numPatterns)
    numPatterns = 1;
end

default_centers = [screenRect(3)/2, screenRect(4)/2];
default_apSizes = [screenRect(3)/4, screenRect(4)/4];
default_edgeSpillovers = [5 5];
default_nDots = 25;
default_speeds = 1;
default_directions = 0;
default_cohers = 100;
default_lifetimes = 20;
default_dotSizes = 5;
% default_dotTypes = 1;
default_dotTypes = 2;


p = inputParser;
addRequired(p,'screenRect',@(x) isnumeric(x) && numel(x) == 4)
numPatterns_condition = @(x) isnumeric(x) && (x >= 1) && (x <= 4); 
addRequired(p, 'numPatterns', numPatterns_condition);

% make sure that the centers, apSizes, and edge_spillovers variables have two points for each RDP
% and as many rows as there are numPatterns
addOptional(p, 'centers', default_centers, @(x) isnumeric(x) && (size(x,1) == numPatterns) && (size(x,2) == 2));
addOptional(p, 'apSizes', default_apSizes, @(x) isnumeric(x) && (size(x,1) == numPatterns) && (size(x,2) == 2));
addOptional(p, 'edge_spillovers', default_edgeSpillovers, @(x) isnumeric(x) && (size(x,1) == numPatterns) && (size(x,2) == 2));

% make sure that there are as many parameters as there are RDPs and that
% they're numeric, etc.
addOptional(p, 'nDots', default_nDots, @(x) isnumeric(x) && (length(x) == numPatterns) && ~any(floor(x)~=x));
addOptional(p, 'speeds', default_speeds, @(x) isnumeric(x) && (length(x) == numPatterns) && ~any(x <= 0));
addOptional(p, 'directions', default_directions, @(x) isnumeric(x) && (length(x) == numPatterns) && ~any(x < 0));
addOptional(p, 'cohers', default_cohers, @(x) isnumeric(x) && (length(x) == numPatterns) && ~any(x < 0));
addOptional(p, 'lifetimes', default_lifetimes, @(x) isnumeric(x) && (length(x) == numPatterns) && ~any(x <= 0));
addOptional(p, 'dotSizes', default_dotSizes, @(x) isnumeric(x) && (length(x) == numPatterns) && ~any(x <= 0));
addOptional(p, 'dotTypes', default_dotTypes, @(x) isnumeric(x) && (length(x) == numPatterns) && ~any(or(x<0, x>4)));

parse(p,screenRect,numPatterns,varargin{:})

dotParams = struct;
for patt_i = 1:numPatterns
    dotParams(patt_i).screenRect = screenRect; % basically just to make sure dotParams is a structure array
                                               % with numPatterns rows
end

remaining_params = p.Parameters;
defaulted_params = p.UsingDefaults;
remaining_params(strcmp('screenRect',remaining_params)) = [];
remaining_params(strcmp('numPatterns',remaining_params)) = [];

for param_i = 1:length(remaining_params)
    
    paramNam = remaining_params{param_i};

    if ~any(strcmp(paramNam,defaulted_params))
        if any(strcmp(paramNam,{'centers','apSizes','edge_spillovers'}))
            for patt_i = 1:p.Results.numPatterns
                dotParams(patt_i).(paramNam) = p.Results.(paramNam)(patt_i,:);
            end
        else
            for patt_i = 1:p.Results.numPatterns
                dotParams(patt_i).(paramNam) = p.Results.(paramNam)(patt_i);
            end
        end
    else
        dotParams = arrayfun(@(x)(setfield(x,paramNam,p.Results.(paramNam))),dotParams);
    end
    
end



end

