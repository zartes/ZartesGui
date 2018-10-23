function [u,t]=makeInputNoise()

A=1e-9;
B=1e-9;
N=10;
t=0:1e-6:1;
u(:,1)=A*randn(length(t),1);
u(:,2)=B*randn(length(t),1);