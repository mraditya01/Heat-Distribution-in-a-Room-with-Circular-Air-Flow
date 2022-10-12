function [TNew] = RenewBCMiddle(T,T0,Th,L,dx,dy,C)

TNew = T;
Nx = size(T,1)-4;
Ny = size(T,2)-4;

C(1)=floor(C(1)/dx);
C(2)=floor(C(2)/dy);
L=L/2;
Lh(1)=floor(L/dx);
Lh(2)=floor(L/dy);
%Left Periodic
for i = 1:2
    for j = 3:Ny+2
       TNew(i,j) = T0; 
    end
end
%Right Periodic
for i = Nx+3:Nx+4
    for j = 3:Ny+2
       TNew(i,j) = T0; 
    end
end


%Top Heater
for j = Ny+3:Ny+4
    for i = 3:Nx+2
       TNew(i,j) = T0; 
    end
end


%Heater
for j = Ny/2+C(2)-Lh(2):Ny/2+C(2)+Lh(2)
    for i = Nx/2+C(1)-Lh(1):Nx/2+C(1)+Lh(1)
       TNew(i,j) = Th; 
    end
end


%Bottom Heater
for j = 1:2
    for i = 3:Nx+2
       TNew(i,j) = T0; 
    end
end

