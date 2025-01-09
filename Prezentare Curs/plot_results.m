% Helper function to plot results
function plot_results(t, p1, roaddist, y1, y2, y3)
    chassis_movement = 'Chassis Movement (m)';
    disturbance = 'Disturbance';
    time = 'Time (s)';
    chassis_acceleration = 'Chassis Acceleration (m/s^2)';
    suspension_movement = 'Suspension movement (m)';
    % Open Loop
    figure('Position', [550, 550, 800, 500]);
    subplot(311)
    plot(t,p1(:,1),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Open Loop: Chassis Movement'); xlabel(time); ylabel(chassis_movement);
    legend(chassis_movement,disturbance);
    subplot(312)
    plot(t,p1(:,3),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Open Loop: Chassis Acceleration'); xlabel(time); ylabel(chassis_acceleration);
    legend(chassis_acceleration,disturbance);
    subplot(313)
    plot(t,p1(:,2),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Open Loop: Suspension movement'); xlabel(time); ylabel(suspension_movement);
    legend(suspension_movement,disturbance);
    
    % Comfort
    figure('Position', [550, 550, 800, 500]);
    subplot(311)
    plot(t,y1(:,1),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Comfort Mode: Chassis Movement'); xlabel(time); ylabel(chassis_movement);
    legend(chassis_movement,disturbance);
    subplot(312)
    plot(t,y1(:,3),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Comfort Mode: Chassis Acceleration'); xlabel(time); ylabel(chassis_acceleration);
    legend(chassis_acceleration,disturbance);
    subplot(313)
    plot(t,y1(:,2),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Comfort Mode: Suspension movement'); xlabel(time); ylabel(suspension_movement);
    legend(suspension_movement,disturbance);
    
    % Standard Mode
    figure('Position', [550, 550, 800, 500]);
    subplot(311)
    plot(t,y2(:,1),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Standard Mode: Chassis Movement'); xlabel(time); ylabel(chassis_movement);
    legend(chassis_movement,disturbance);
    subplot(312)
    plot(t,y2(:,3),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Standard Mode: Chassis Acceleration'); xlabel(time); ylabel(chassis_acceleration);
    legend(chassis_acceleration,disturbance);
    subplot(313)
    plot(t,y2(:,2),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Standard Mode: Suspension movement'); xlabel(time); ylabel(suspension_movement);
    legend(suspension_movement,disturbance);
    
    % Sport Mode
    figure('Position', [550, 550, 800, 500]);
    subplot(311)
    plot(t,y3(:,1),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Sport Mode: Chassis Movement'); xlabel(time); ylabel(chassis_movement);
    legend(chassis_movement,disturbance);
    subplot(312)
    plot(t,y3(:,3),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Sport Mode: Chassis Acceleration'); xlabel(time); ylabel(chassis_acceleration);
    legend(chassis_acceleration,disturbance);
    subplot(313)
    plot(t,y3(:,2),'Color',"#0072BD",'LineWidth',1.5); grid; hold on;
    plot(t,roaddist,'Color','#77AC30','LineWidth',1.5)
    title('Sport Mode: Suspension movement'); xlabel(time); ylabel(suspension_movement);
    legend(suspension_movement,disturbance);
end
