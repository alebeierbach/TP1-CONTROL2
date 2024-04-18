clear all; close all; clc;
s=tf('s');

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

%ITEM 4

%El torque maximo sera imax*Ki, teniendo en cuenta que imax ocurre cuando
%el motor aun no ha comenzado a girar y el unico valor representativo es Ra
%(resistencia del bobinado)en funcion de la alimentacion de entrada:
imax=Va/Ra
Tlmax=imax*Ki

[Ntf,Dtf]=ss2tf(A,B,C,D,1);

t=0:1e-7:0.06;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=tf(Ntf(1,:),Dtf); %Elegi la fila 1 que contiene la salida corriente
w=tf(Ntf(2,:),Dtf); %fila 2 que contiene la salida velocidad
                   %fila 3 que contiene la salida angulo
                   
%[iar,tar]=step(i,t);
%[war,tar]=step(w,t);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ITEM 5

% Especifica la ruta y el nombre del archivo Excel
nombre_archivo = 'C:\Users\alebe\OneDrive\Escritorio\TP1CONTROL2\Curvas_Medidas_Motor_2024.xls';

% Especifica el nombre de la hoja que contiene los datos
nombre_hoja = 1;

% Lee los datos del archivo Excel
data = xlsread(nombre_archivo, nombre_hoja, 'A1:D2001');
t=data(:,1);    %Defino tiempo en la columna 1
w=data(:,2);    %Defino corriente en la columna 2
i=data(:,3);
vi=data(:,4);

 plot(t,i);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%La consigna pide wr/Va, yo usare ia/Va, dado que esta ultima me aporta mas
%informacion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ichen=i(702:741); %Armo un arreglo de corrientes
tchen=t(702:741)-0.0351; %Armo un arreglo de tiempo
plot(tchen,ichen)  %saco valores del grafico para aplicar CHEN. Estos valores estan equidistantes entre ellos

%Aplico chen para i
t1=t(703)-0.0351 %le resto el retardo para que la funcion arranque en cero 
y1=i(703)
y2=i(704)
y3=i(705)
yend=i(741) %valor final estable

%Aplico algoritmo de CHEN: para Ia
K=yend; %ganancia
k1=y1/K-1;
k2=y2/K-1;
k3=y3/K-1;
be=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(be))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(be))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);

T1=-t1/log(alfa1);
T2=-t1/log(alfa2);
T3=beta*(T1-T2)+T1;

K1=yend/vi(741)    %ganancia unitaria

%Gchen es ia
Gchen=K1*(T3*s+1)/((T1*s+1)*(T2*s+1)) %Defino la funcion de transferencia aproximada
                                      
               
%Grafico mi FdT y mis datos de corriente de excel
plot(tchen,ichen)
hold on;
[y2, t2] = step(12*Gchen,0.001); 
plot(t2, y2)
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculo de Wr/Va
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wr=w(702:741);
tchen1=t(702:741)-0.0351;

%Aplico Chen para wr/Va:
t1=t(703)-0.0351 %le resto el retardo para que la funcion arranque en cero y aplicar chen 
y1=w(703)
y2=w(704)
y3=w(705)
k=w(741) %valor final estable

%Aplico algoritmo de CHEN: para Ia
K=k; %ganancia
k1=y1/K-1;
k2=y2/K-1;
k3=y3/K-1;
be=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(be))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(be))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);

T1=-t1/log(alfa1);
T2=-t1/log(alfa2);
T3=beta*(T1-T2)+T1;

K2=k/vi(741)    %ganancia unitaria

%Gchen es ia
Wchen=K2*(T3*s+1)/((T1*s+1)*(T2*s+1)) %Defino la funcion de transferencia aproximada

%Grafico mi FdT y mis datos
plot(tchen1,wr)
hold on;
[y1,t1]=step(12*Wchen,0.002)
plot(t1,y1)
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Constantes:
coefG=Gchen.den;
Km1=1/w(741)
Ki1=Km1
B1=i(741)*Ki1*Km1
J1=T3*B1
La1=coefG{1}(1)*Km1*Ki1/J1
Ra1=(coefG{1}(2)*Km1*Ki1-La1*B1)/J1
