
% Parámetros del motor
La = 366e-6;  % inductancia de armadura (H)
J = 5e-9;      % momento de inercia (kg*m^2)
Ra = 55.6;    % resistencia de armadura (ohm)
B = 0;         % coeficiente de fricción (N*m/(rad/s))
Ki = 6.49e-3; % constante de voltaje del motor (V/rad/s)
Km = 6.53e-3; % constante de torque del motor (N*m/A)
Va=12;

A=[-Ra/La -Km/La 0; Ki/J -B/J 0; 0 1 0];
B=[1/La 0; 0 -1/J; 0 0]
C=[1 0 0; 0 1 0; 0 0 1]
D=[0 0;0 0;0 0]


% Item 5:
clear all; close all; clc;
filename='C:\Users\Ale\Desktop\CONTROL 2\TP1 CONTROL2\Curvas_Medidas_Motor_2024.xls';
sheet=1;
total=xlsread(filename,sheet,'A1:E32370');
tdata=total(:,1);
wdata=total(:,2);
idata=total(:,3);
vdata=total(:,4);
tldata=total(:,5);
plot(tdata,wdata)

% Aplicamos el método de Chen:
ichen=idata(702:741);
tchen=tdata(702:741)-0.0351;

yend=ichen(40);
k1=ichen(2)/yend-1;          % Se calcula la constante 1
k2=ichen(3)/yend-1;          % Se calcula la constante 2
k3=ichen(4)/yend-1;          % Se calcula la constante 3
t1=tchen(2);           % Se resta el retardo mecionado
K=yend/vdata(741);
% Ahora se definen el resto de constantes en función de las primeras:
be=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(be))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(be))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);
% Finalmente se obtienen las constantes de tiempo referidas al cero y los
% polos:
T1=-t1/log(alfa1);          % Referido al polo 1
T2=-t1/log(alfa2);          % Referido al polo 2
T3=beta*(T1-T2)+T1;         % Referido al cero
% Sin embargo el cero no será considerado ya que no corresponde al modelo
% físico de la tensión en el capacitor.
% De esta manera el sistema resulta ser el siguiente:
s=tf('s');
I=K*(T3*s+1)/((T1*s+1)*(T2*s+1));

plot(tchen,ichen)
hold on;
step(12*I)
hold off;
coefD=I.den;
% Determinamos las constantes:
Km=12/wdata(741)
Ki=Km
Bm=idata(741)*Ki*Km/12
J=T3*Bm
La=coefD{1}(1)*Ki*Km/J
Ra=(coefD{1}(2)*Ki*Km-La*Bm)/J

% Se escribe la función de transferencia de la velocidad angular
% conociendo su forma y utilizando los coeficientes calculados
% anteriormente:
wrk=Ki/(Ra*Bm+Km*Ki)
Wr=tf(wrk,I.den)
plot(tdata(702:741)-0.0351,wdata(702:741),'r')
hold on;
step(12*Wr)
hold off;

% Se simula el sistema aplicándole un torque y se verifica que sea igual
% que el mostrado en la consigna:
A=[-Ra/La -Km/La 0;
    Ki/J -Bm/J 0;
    0 1 0];
B=[1/La 0 ;
    0 -1/J;
    0 0];
C=[1 0 0 ;
    0 1 0;
    0 0 1];
D=[0 0;
    0 0;
    0 0];
X=[0; 0; 0];
dX=[0; 0; 0];
U=[12; 0];
Y=[0; 0; 0];
Dt=1e-7;
t=0:Dt:1;
Tt=size(t);
% Arreglo de perturbación
tl=zeros(1,5000001);
for g=0:1:499
    tl=[tl,tldata(16684:26683)'];
end
tlc=tl*100*Ki;  % Se modifica el valor de los torques ya que utilizando los
                % de la planilla el sistema no se comporta como es
                % esperado. Los valores de las constantes se verificaron de
                % varias formas alternativas, así que se puede suponer que
                % ellas no son el problema de la discrepancia. Asimismo se
                % verificó utilizando los valores de corriente de la
                % planilla que el torque debía ser el utilizado aquí.
% Resto de arreglos
i=zeros(Tt);
w=zeros(Tt);
ang=zeros(Tt);
k=1;

for j=0:Dt:1
    U(2,1)=tlc(k);
    dX=A*X+B*U;
    Y=C*X+D*U;
    X=X+Dt*dX;
    i(k)=Y(1,1);
    w(k)=Y(2,1);
    ang(k)=Y(3,1);
    k=k+1;
end

figure;
subplot(3,1,1)
plot(t,i)
subplot(3,1,2)
plot(t,w)
subplot(3,1,3)
plot(t,tlc)

% Item 6:
% Diseñamos un controlador PID discreto para mantener el ángulo del motor
% en 1 radián sometido a diferentes torques. Se propone utilizar las
% constantes KP=0.1, KI=0.01, KD=5.
% Primero se reinician las variables de estado:
X=[0; 0; 0];
dX=[0; 0; 0];
U=[1; 0];               % Se da referencia de 1 radián.
Y=[0; 0; 0];
Dt=1e-7;
% Resto de arreglos (se reinician los utilizados anteriormente)
i=zeros(Tt);
w=zeros(Tt);
ang=zeros(Tt);
E=zeros(2,(Tt(2)+2));
e=zeros(Tt);
Ue=[0; 0];
k=1;
% Se diseña el controlador.
% Primero se definen las contantes del controlador PID:
KP=12;                  % Se limita según corriente máxima del sistema sin 
                        % controlar. Imáx: 0.4281A.
KI=156;                 % Se limita según evitar un sobrepasamiento mayor 
                        % al 5% del valor de régimen.
KD=0;                   % No se considera necesario en este caso ya que el 
                        % sistema no presenta oscilaciones que deban
                        % compensarse. Además introduce un pico de
                        % corriente muy alto, siendo este el principal
                        % motivo para descartarlo.
% Luego se definen las variables de control en tiempo discreto:
Ac=(2*KP*Dt+KI*Dt^2+2*KD)/(2*Dt);
Bc=(-2*KP*Dt+KI*Dt^2-4*KD)/(2*Dt);
Cc=KD/Dt;

for j=0:Dt:1             %el sistema inicia desde 0. Dx=0 X=0 Y=0
    Ue(2,1)=tl(k);       % Pongo el torque en mi matriz de entrada (para que afecte el sistema)
    dX=A*X+B*Ue;
    Y=C*X+D*Ue;
    X=X+Dt*dX;
    i(k)=Y(1,1);
    w(k)=Y(2,1);
    ang(k)=Y(3,1);      %paso el valor de mi angulo a la matriz de salida
    % Acción de control:
    E(:,k+2)=U-[Y(3,1); 0]; %resto mi angRef-ang(k)=error y ese error se guarda en el vector de error
    Ue=Ue+Ac*E(:,k+2)+Bc*E(:,k+1)+Cc*E(:,k);    %en cada iteracion leo el error corespondiente a A,B,C Y APLICO PID
    e(k)=E(1,k+2); %Creo un arreglo donde guardo mi error..
    k=k+1;
end

figure;
subplot(2,2,1)
plot(t,i)
subplot(2,2,2)
plot(t,ang)
subplot(2,2,3)
plot(t,w)
subplot(2,2,4)
plot(t,tl)

p1=sprintf('Sobrepasamiento máximo: %.2f%%',(max(ang)-1)*100);
p2=sprintf('Corriente máxima: %.4f',max(i));
disp(p1);
disp(p2);