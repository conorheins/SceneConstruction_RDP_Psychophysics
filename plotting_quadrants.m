
close all;
figure; hold on;
for quad_i = 1:4
    text(mean(quadrant_vertices(1,:,quad_i),2)-38,mean(quadrant_vertices(2,:,quad_i),2)+18,sprintf('Quadrant %d\n',quad_i));
    plot([quadrant_vertices(1,:,quad_i),quadrant_vertices(1,1,quad_i)],[quadrant_vertices(2,:,quad_i),quadrant_vertices(2,1,quad_i)],...
        'r-','LineWidth',2);
%     pause; 
end
ax = gca;
ax.YDir = 'reverse';

scatter(eye_pos(:,1),eye_pos(:,2),50,cool(size(eye_pos,1)))
