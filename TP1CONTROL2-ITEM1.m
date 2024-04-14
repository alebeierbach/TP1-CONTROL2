clear all; close all; clc;
s=tf('s');

%1)
R=47;
L=1e-6 ;     %Definimos los valores
C=100e-9;

A=[-R/L -1/L; 1/C 0]; %Definimos las matrices
B=[1/L; 0];
C=[R 0];
D1=[0]

[N,D]=ss2tf(A,B,C,D1)


t=0:0.000001:0.005;

Vr=tf(N,D)
iR=Vr/R; %Aproximadamente igual a Vr (no se grafica)
Vi=12*square(2*pi*(1/0.002)*t); %vector del mismo tamano de t



C1=[0 1] %Elijo la tension del capacitor
[N1,D1]=ss2tf(A,B,C1,D1) %Salida/Entrada
Vc=tf(N1,D1)

%Grafica Vr, Vc en funcion de Vi(entrada) y t (tiempo)
figure;
subplot(3,1,1)
plot(t,Vi)
title('Voltaje de entrada')
subplot(3,1,2)
lsim(Vr,Vi,t)
title('Voltaje en resistencia')
subplot(3,1,3)
lsim(Vc,Vi,t)
title('Voltaje en capacitor')




