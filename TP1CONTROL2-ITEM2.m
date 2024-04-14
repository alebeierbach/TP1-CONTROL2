clear all; close all; clc;
s=tf('s');

% Especifica la ruta y el nombre del archivo Excel
nombre_archivo = 'C:\Users\Ale\Desktop\TP1 CONTROL2\Curvas_Medidas_RLC_2024.xls';

% Especifica el nombre de la hoja que contiene los datos
nombre_hoja = 1;

% Lee los datos del archivo Excel
data = xlsread(nombre_archivo, nombre_hoja, 'A1:D2001');
t=data(:,1);    %Defino tiempo en la columna 1
i=data(:,2);    %Defino corriente en la columna 2
vc=data(:,3);
vi=data(:,4);

figure;
%plot(t,data);

%Extraigo los valores del excel
t1=t(134)-0.01  %le resto el retardo para que la funcion arranque en cero 
y1=vc(134)
y2=vc(167)
y3=vc(200)
yend=vc(501)

K=yend;
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

for k = 101:1:501     %Genero un arreglo de valores que no tienen retraso y arrancan en cero
    vcnew(k-100)=vc(k); %vcnew(1)=vcnew(101) (elimino los valores que no aportan datos)
end
tnew=0:0.0001:0.04 %Tiempo nuevo sin retraso (0.05-0.01=0.04)
vi1=12*square(2*pi*10*tnew); %T=0,1

%Gchen es mi Vc
Gchen=1/((T1*s+1)*(T2*s+1)) %Defino la funcion de transferencia aproximada ; elimino el cero porque el RLC no tiene cero (mirar cuadernillo)
                            %Seria mi Vc en fdT

%step(12*Gchen)
lsim(Gchen,vi1,tnew); %Podemos ver la diferencia entre la curva de excel y la fdt obtenida de Chen (muy iguales)
hold on;
%plot(t,vcnew); %estan desplazadas (una tiene retraso)
plot(tnew,vcnew); %ahora puedo ver que arranca en cero mi fdt
hold off;


%Suponiendo Cnew para realizar el calculo
Cnew=0.0001;

C=1e-5 %Valor del capacitor original 
%LC*s^2 --> LC/C=L, entonces:
Lnew= 9.867e-07/C
%RC*s --> RC/C=R, entonces:
Rnew=0.00269/C
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ITEM 3%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Creo un vector de 2000 datos de tiempo
tnew2=0:0.0001:0.2;
vi2=12*square(2*pi*10*tnew2); %este tambien tendra 2mil datos por depender de tnew2

ix=s*C*Gchen %Vc=(1/sC)*ix --> ix=sC*Vc
lsim(ix,vi2,tnew2)  %Corriente simulada a partir de Chen
xlim([0.05 0.2])
ylim([-0.1 0.1])
hold on;
plot(t,i) %De la tabla de datos
hold off;
%vemos que las graficas son practicamente iguales superpuestas...






