clc; close all; clear all;

T = readtable('CAP_S1_E2_2_E1.csv','PreserveVariableNames',true);

t = T.("S3-H-1/AO1/PV.CV");
var6 = T.Var6; 
var8 = T.Var8;
var8(2,1) = 0;
var10 = T.Var10;
var12 = T.Var12;
var14 = T.Var14;

figure;
subplot(231)
plot(t,var6,'LineWidth',1.5); grid; legend('S3-H-1/AO1-Pump Speed [RPM]');
subplot(232);
plot(t,var8,'LineWidth',1.5); grid; legend('S3-FIC-201/PID1-FV1 Setpoint');
subplot(233);
plot(t,var10,'LineWidth',1.5); grid; legend('S3-FIC-201/AI1-Flow Transducer Measurement');
subplot(234);
plot(t,var12,'LineWidth',1.5); grid; legend('S3-LT-31/AI1-Level Transducer Tank E1');
subplot(235);
plot(t,var14,'LineWidth',1.5); grid; legend('S3-FT-23/AI1-Coriolis Flow Transducer');
subplot(236);
plot(t,var6,t,var8,t,var10,t,var12,t,var14,'LineWidth',1.5); grid;
legend('S3-H-1/AO1-Pump Speed [RPM]', 'S3-FIC-201/PID1-FV1 Setpoint', 'S3-FIC-201/AI1-Flow Transducer Measurement', 'S3-LT-31/AI1-Level Transducer Tank E1', 'S3-FT-23/AI1-Coriolis Flow Transducer');

%% Identificare Hf1 (integrator)
clc; close all;
figure; plot(t,var10,t,var12,'LineWidth',1.5); grid; title('Hf1'); legend('var10','var12');

Kf = 1;
u_sat = 1070-365;
t_int = 88; % [sec] 20:07:00 -> 20:08:28
y_sat = 204;
y_1 = 86.3;

Ti = (Kf*u_sat*t_int)/(y_sat-y_1)

Hf1 = tf(1,[Ti 0])

% Define the duration array
timeDurations = duration(20, 5, 0):seconds(2):duration(20, 11, 0);

% Convert the duration array to a numeric vector in seconds
numericVector = seconds(timeDurations - timeDurations(1));

var10(2,1)=0;
y1 = lsim(Hf1, var10, numericVector);

figure;
plot(t,var10,t,var12,t,y1,'LineWidth',1.5); grid; legend('Setpoint','Raw','Identified');

%% Identificare Hf2 (ordin I fara timp mort)
clc; close all;
figure; plot(t,var8,t,var10,'LineWidth',1.5); grid; title('Hf2'); hold on;

yst = 1070;
y0 = 365;
ust = 50;
u0 = 0;

Kf2 = (yst-y0)/(ust-u0);

y63 = y0 + 0.632*(yst-y0);

plot(t,y63*ones(size(t))); hold on;

Tf2 = 8; % 20:06:32 - 20:07:04 [sec]

Hf2 = tf(Kf2,[Tf2 1])

% Define the duration array
timeDurations = duration(20, 5, 0):seconds(2):duration(20, 11, 0);

% Convert the duration array to a numeric vector in seconds
numericVector = seconds(timeDurations - timeDurations(1));

% Display the result
disp(numericVector);

y2 = lsim(Hf2,var8,numericVector);

figure;
plot(t,var8,t,var10,t,y2,'LineWidth',1.5); grid; legend('Setpoint','Raw','Identified');

%% Regulator Hf2 (fdt de ordin I fara timp mort)
clc; close all;

Hc2 = tf(15,1);

Hd2 = series(Hc2, Hf2);
H02 = feedback(Hd2,1);
step(H02); grid; hold on;

%%
clc; close all;

Hd = tf(1,[2*Tsum^2 2*Tsum 0]);



%% Regulator Hf1 (integrator) (G-T) (Merge mai ok modulul)
clc; close all;

H_extern = series(H02,Hf1)

Estp = 0;
Tr = 30;
Sigma = 0.15;
CvDat = 0.2;
Kf = H_extern.Numerator{1,1}(3);
Tf = H_extern.Denominator{1,1};
DWbStelat = 2;

Zeta = abs(log(Sigma))/sqrt(log(Sigma)^2+pi^2)
Wn = 4/(Tr*Zeta)
Cv = Wn/(2*Zeta)
if Cv < CvDat
    fprintf('Este problema pentru ca Cv calculat este %2.2f si CvDat este %2.2f', Cv, CvDat);
end
Estv = 1/Cv
DWb = Wn*sqrt(1-2*Zeta^2+sqrt(2-4*Zeta^2+4*Zeta^4))
if DWb > DWbStelat
     fprintf('Este problema pentru ca DWb calculat este %2.2f si DWbStelat este %2.2f', DWb, DWbStelat);
end

% regulator
num = [(Wn*Tf)/(2*Zeta), Wn/(2*Zeta)]; 
den = [Kf/(2*Zeta*Wn), Kf];
Hc1 = tf(num, den)
HrMinimal = minreal(Hc1)

% H0
Hd = series(Hc1,H_extern);
H0 = minreal(feedback(Hd, 1))

% simulare
step(H0); grid;

%% Regulator Hf1 (integrator) (Modul)
clc; close all;

H_extern = series(H02,Hf1)

Tsum= 1;
Hd = tf(1,[2*Tsum^2 2*Tsum 0]);
Hc1 = minreal(Hd/H_extern)
H0 = feedback(Hd,1);
figure;
step(H0); grid; title('Stabilitate sistemului cu regulator prin MODUL la referinta TREAPTA');
wn = 1/(sqrt(2)*Tsum)
zeta = 1/sqrt(2)
ts = 8*Tsum
cv = 1/(2*Tsum)
estv = 1/cv
