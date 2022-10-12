function [TNew] = RenewBCJet(T,T0,Th,L,dx,dy,C)

TNew = T;
Nx = size(T,1)-4;
Ny = size(T,2)-4;

C(1)=floor(C(1)/dx);
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

%Jet Heater
for j = Ny+3:Ny+4
    for i = Nx/2+C(1)-Lh(1):Nx/2+C(1)+Lh(1)
       TNew(i,j) = Th; 
    end
end

%Top Free Left
for j = Ny+3:Ny+4
    for i = 3:Nx/2+C(1)-Lh(1)-1
       TNew(i,j) = T(i,j-Ny); 
    end
end
%Top Free Right
for j = Ny+3:Ny+4
    for i = Nx/2+C(1)+Lh(1)+1:Nx+2
       TNew(i,j) = T(i,j-Ny); 
    end
end


%Bottom Heater
for j = 1:2
    for i = Nx/2+C(1)-Lh(1):Nx/2+C(1)+Lh(1)
       TNew(i,j) = T0; 
    end
end

%Bottom Free Left
for j = 1:2
    for i = 3:Nx/2+C(1)-Lh(1)-1
       TNew(i,j) = T(i,Nx+j); 
    end
end

%Bottom Free Right
for j = 1:2
    for i = Nx/2+C(1)+Lh(1)+1:Nx+2
       TNew(i,j) = T(i,Nx+j); 
    end
end
