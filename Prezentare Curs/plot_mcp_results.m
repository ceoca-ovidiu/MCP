% Helper function to plot MCP results
function plot_mcp_results(t, y, roaddist, title_text)
    % Define axis labels
    chassis_movement = 'Chassis Movement (m)';
    disturbance = 'Disturbance';
    time = 'Time (s)';
    chassis_acceleration = 'Chassis Acceleration (m/s^2)';
    suspension_movement = 'Suspension movement (m)';

    % Create figure
    figure('Position', [550, 550, 800, 500]);

    % Chassis Movement
    subplot(311);
    plot(t, y(:, 1), 'Color', "#0072BD", 'LineWidth', 1.5); grid; hold on;
    plot(t, roaddist, 'Color', '#77AC30', 'LineWidth', 1.5);
    title([title_text ': Chassis Movement']); xlabel(time); ylabel(chassis_movement);
    legend(chassis_movement, disturbance);

    % Chassis Acceleration
    subplot(312);
    plot(t, y(:, 3), 'Color', "#0072BD", 'LineWidth', 1.5); grid; hold on;
    plot(t, roaddist, 'Color', '#77AC30', 'LineWidth', 1.5);
    title([title_text ': Chassis Acceleration']); xlabel(time); ylabel(chassis_acceleration);
    legend(chassis_acceleration, disturbance);

    % Suspension Movement
    subplot(313);
    plot(t, y(:, 2), 'Color', "#0072BD", 'LineWidth', 1.5); grid; hold on;
    plot(t, roaddist, 'Color', '#77AC30', 'LineWidth', 1.5);
    title([title_text ': Suspension Movement']); xlabel(time); ylabel(suspension_movement);
    legend(suspension_movement, disturbance);
end
