function [sacc_array] = trialEyeData_analyze(Eye_struct,Mat_struct,quadrant_vertices)

eye_pos = Eye_struct.pos(Eye_struct.EXPLORE_START_t : Eye_struct.EXPLORE_END_t , 2:3 );
dotParams = Mat_struct.dotParams;

sacc_array = [];

for quad_i = 1:size(quadrant_vertices,3)
    
%     if quad_i == 2
%         break_flag = true;
%     end
    
    IN_idx = inpolygon(eye_pos(:,1),eye_pos(:,2),quadrant_vertices(1,:,quad_i),quadrant_vertices(2,:,quad_i));
    D = diff(IN_idx);
    if IN_idx(1)
        startIdx = find([true;D>0]);
    else
        startIdx = find([false;D>0]);
    end
    if IN_idx(end)
        endIdx = find([D<0;true])+1;
    else
        endIdx = find([D<0;false])+1;
    end
    durations = endIdx - startIdx;
    
    in_quad_flag = false;
    center_i = 1;
    direction = NaN;
    coherence = NaN;
    while ~in_quad_flag
        
        if center_i > length(dotParams)
            in_quad_flag = true;    
        else
            if inpolygon(dotParams(center_i).centers(1),dotParams(center_i).centers(2),quadrant_vertices(1,:,quad_i),quadrant_vertices(2,:,quad_i))
                direction = dotParams(center_i).directions;
                coherence = dotParams(center_i).cohers;
                in_quad_flag = true;
            end
        end
        
        center_i = center_i + 1;
        
    end
    
    if any(durations > 100)
        good_saccs = find(durations > 100);
        for s_ii = 1:length(good_saccs)
            sacc_array = [sacc_array; [quad_i, startIdx(good_saccs(s_ii)),endIdx(good_saccs(s_ii)), direction,coherence]];
        end
    end
    
end

sacc_array = sortrows(sacc_array,2);


end