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
