clc; close all; clear all;

% Physical parameters
mb = 300;    % Car body mass [kg]
mw = 60;     % Wheel mass [kg]
bs = 1000;   % Suspension damping [N/m/s]
ks = 16000;  % Suspension stiffness [N/m]
kt = 190000; % Tire stiffness [N/m]

% State matrices
A = [ 0 1 0 0; [-ks -bs ks bs]/mb ; ...
    0 0 0 1; [ks bs -ks-kt -bs]/mw];
B = [ 0 0; 0 1e3/mb ; 0 0 ; [kt -1e3]/mw];
C = [1 0 0 0; 1 0 -1 0; A(2,:)];
% D = [0 0; 0 0; B(2,:)];
D = [0 0; 0 0; 0 0];

qcar = ss(A,B,C,D);
qcar.StateName = {'body travel (m)';'body vel (m/s)';...
    'wheel travel (m)';'wheel vel (m/s)'};
qcar.InputName = {'r';'fs'};
qcar.OutputName = {'xb';'sd';'ab'};

ActNom = tf(1,[1/60 1]);
ActNom.InputName = 'u';
ActNom.OutputName = 'fs';

Wroad = ss(0.07);  Wroad.u = 'd1';   Wroad.y = 'r';
Wact = 0.8*tf([1 50],[1 500]);  Wact.u = 'u';  Wact.y = 'e1';

HandlingTarget = 0.04 * tf([1/8 1],[1/80 1]);
ComfortTarget = 0.4 * tf([1/0.45 1],[1/150 1]);

beta = reshape([0.01 0.5 0.99],[1 1 3]);
Wsd = beta / HandlingTarget;
Wsd.u = 'sd';  Wsd.y = 'e3';
Wab = (1-beta) / ComfortTarget;
Wab.u = 'ab';  Wab.y = 'e2';

sdmeas  = sumblk('y1 = sd');
abmeas = sumblk('y2 = ab');
ICinputs = {'d1';'u'};
ICoutputs = {'e1';'e2';'e3';'y1';'y2'};
qcaric = connect(qcar(2:3,:),ActNom,Wroad,Wact,Wab,Wsd,sdmeas,abmeas,ICinputs,ICoutputs);

ncont = 1; % one control signal, u
nmeas = 2; % two measurement signals, sd and ab
K = ss(zeros(ncont,nmeas,3));
gamma = zeros(3,1);
for i = 1:3
    [K(:,:,i),~,gamma(i)] = hinfsyn(qcaric(:,:,i),nmeas,ncont);
end

K.u = {'sd','ab'};  K.y = 'u';
CL = connect(qcar,ActNom,K,'r',{'xb';'sd';'ab'});

% Road disturbance
t = 0:0.0025:4;
roaddist = zeros(size(t));
roaddist(1:101) = 0.025*(1-cos(8*pi*t(1:101)));
figure('Position', [550, 550, 800, 500]);
plot(t, roaddist,'LineWidth',1.5); grid; title('Disturbance'); xlabel('Time'), ylabel('Height (m)');
% Simulate
p1 = lsim(qcar(:,1),roaddist,t);
y1 = lsim(CL(1:3,1,1),roaddist,t);
y2 = lsim(CL(1:3,1,2),roaddist,t);
y3 = lsim(CL(1:3,1,3),roaddist,t);

% Plot results (open loop and modes)
plot_results(t, p1, roaddist, y1, y2, y3);

% Robust Mu-Synthesis (mu-synthesis)
Wunc = makeweight(0.80,15,3);
unc = ultidyn('unc',[1 1],'SampleStateDim',5);
ActUnc = ActNom*(1 + Wunc*unc);
ActUnc.InputName = 'u';
ActUnc.OutputName = 'fs';

qcaric_unc = connect(qcar(2:3,:),ActUnc,Wroad,Wact,Wab,Wsd,sdmeas,abmeas,ICinputs,ICoutputs);

rng('default'); nsamp = 50;

% Standard mode
% Nominal
figure('Position', [550, 550, 800, 500]);
CLU = connect(qcar,ActUnc,K(:,:,2),'r',{'xb','sd','ab'});
lsim(usample(CLU,nsamp), roaddist, t); grid;
title(["Standard Mode: Nominal controller for " + nsamp + " iterations."])

[Krob,rpMU] = musyn(qcaric_unc(:,:,2),nmeas,ncont);

% Robust
figure('Position', [550, 550, 800, 500]);
Krob.u = {'sd','ab'};
Krob.y = 'u';
CLUR = connect(qcar,ActUnc,Krob,'r',{'xb','sd','ab'});
lsim(usample(CLUR,nsamp), roaddist, t); grid;
title('Robust Standard Mode (Mu-Synthesis)')

% Comparison robust and nominal
figure('Position', [550, 550, 800, 500]);
lsim(usample(CLU,nsamp), roaddist, t); grid; hold on;
lsim(usample(CLUR,nsamp), roaddist, t); grid;
title('Comparison Robust vs Nominal (Standard Mode)')

% Comfort mode
figure('Position', [550, 550, 800, 500]);
CLU = connect(qcar,ActUnc,K(:,:,1),'r',{'xb','sd','ab'});
lsim(usample(CLU,nsamp), roaddist, t); grid;
title(["Comfort Mode: Nominal controller for " + nsamp + " iterations."])

[Krob,rpMU] = musyn(qcaric_unc(:,:,1),nmeas,ncont);

figure('Position', [550, 550, 800, 500]);
Krob.u = {'sd','ab'};
Krob.y = 'u';
CLUR = connect(qcar,ActUnc,Krob,'r',{'xb','sd','ab'});
lsim(usample(CLUR,nsamp), roaddist, t); grid;
title('Robust Comfort Mode (Mu-Synthesis)')

% Comparison robust and nominal
figure('Position', [550, 550, 800, 500]);
lsim(usample(CLU,nsamp), roaddist, t); grid; hold on;
lsim(usample(CLUR,nsamp), roaddist, t); grid;
title('Comparison Robust vs Nominal (Comfort Mode)')

% Sport mode
figure('Position', [550, 550, 800, 500]);
CLU = connect(qcar,ActUnc,K(:,:,3),'r',{'xb','sd','ab'});
lsim(usample(CLU,nsamp), roaddist, t); grid;
ylim([-10 10]);
title(["Sport Mode: Nominal controller for " + nsamp + " iterations."])

[Krob,rpMU] = musyn(qcaric_unc(:,:,3),nmeas,ncont);

figure('Position', [550, 550, 800, 500]);
Krob.u = {'sd','ab'};
Krob.y = 'u';
CLUR = connect(qcar,ActUnc,Krob,'r',{'xb','sd','ab'});
lsim(usample(CLUR,nsamp), roaddist, t); grid;
title('Robust Sport Mode (Mu-Synthesis)')

% Comparison robust and nominal
figure('Position', [550, 550, 800, 500]);
lsim(usample(CLU,nsamp), roaddist, t); grid; hold on;
lsim(usample(CLUR,nsamp), roaddist, t); grid;
ylim([-10 10]);
title('Sport Mode: Comparison Robust vs Nominal')

%% PRED CONTROL
clc; close all;
Ts = 0.01; % Sampling time

% Discretize the system for MPC
qcar_discret = c2d(qcar, Ts);

% Create an MPC controller
Np = 20; % Prediction horizon
Nc = 10; % Control horizon
mpcobj = mpc(qcar_discret, Ts, Np, Nc);

% Define constraints
mpcobj.MV = struct('Min', -500, 'Max', 500); % Input constraints
mpcobj.Weights.ManipulatedVariablesRate = [0.1, 0.1]; % Rate of change for inputs
mpcobj.Weights.OutputVariables = [10, 1, 0]; % Weights for 3 outputs (last one is unimportant)

% Define simulation time
t_mcp = 0:Ts:15; % Time vector

% Define reference signal (matching the number of outputs)
r = zeros(length(t_mcp), 3); % Initialize reference signal
r(:, 1) = 0.01;             % Reference for first output (e.g., chassis movement)
r(:, 2) = 0.01;
% Road disturbance (unmeasured)
roaddist_mcp = zeros(size(t_mcp));
roaddist_mcp(1:101) = 0.025 * (1 - cos(8 * pi * t_mcp(1:101)));

figure('Position', [550, 550, 800, 500]);
plot(t_mcp, r); grid;

% Configure simulation options
options = mpcsimopt(mpcobj);
options.PlantInitialState = [0; 0; 0; 0]; % Set initial state
options.OutputNoise = []; % No output noise

% Simulate the closed-loop response
[y, t_out, u] = sim(mpcobj, length(t_mcp), r, [], options);

% Plot results
plot_mcp_results(t_mcp, y, roaddist_mcp, 'MPC Simulation');

figure('Position', [550, 550, 800, 500]);
plot(t_out, u);
title('Control Inputs Over Time');
xlabel('Time (s)');
ylabel('Control Input (N)');
legend('Input 1', 'Input 2');
grid on;

% figure;
% plot(t_out, r(:, 1) - y(:, 1));
% title('Reference Tracking Error (Chassis Movement)');
% xlabel('Time (s)');
% ylabel('Tracking Error (m)');
% grid on;

figure('Position', [550, 550, 800, 500]);
plot(t_out, y(:,1),t_out, y2(1:length(y(:,1)),1), 'LineWidth',1.5);
title('Chassis Movement Comparison');
xlabel('Time (s)');
ylabel('[m]');
legend('Chassis Movement (MPC)', 'Chassis Movement (Robust)');
grid on;
figure('Position', [550, 550, 800, 500]);
plot(t_out, y(:,2),t_out,y2(1:length(y(:,2)),2),'LineWidth',1.5);
title('Suspension Movement Comparison');
xlabel('Time (s)');
ylabel('[m]');
legend('Suspension Movement (MPC)', 'Suspension Movement (Robust)');
grid on;
figure('Position', [550, 550, 800, 500]);
plot(t_out, y(:,3),t_out, y2(1:length(y(:,3)),3), 'LineWidth',1.5);
title('Chassis Acceleration Comparison');
xlabel('Time (s)');
ylabel('[m/s^2]');
legend('Chassis Acceleration (MPC)', 'Chassis Acceleration (Robust)');
grid on;
