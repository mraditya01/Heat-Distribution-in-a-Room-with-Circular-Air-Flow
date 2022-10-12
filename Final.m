clear;
clc;
close all;
tic
%Giovanni Muhammad Raditya
%081951007
%Variables%
T0=278; %ambient temperature [K]
Th=403; %heated wall temperature [K] 
a=2*10^-5; %diffusivity[m2/s] 
c=2; %velocity constant -> a
b=0.004; %velocity constant -> b
Nx=300; %Number of x-Tiles
Ny=300; %Number of y-Tiles
Lx=5.0; %x-axis Length of the room [m]
Ly=5.0; %y-axis Length of the room [m]
Lh=0.4; %Length of the heater (x-by-x) [m]
Center=[-0,-0]; %Center of Heater Location [m] <- change this to change the location of heater
dx = Lx/Nx; %mesh size in the x direction [m]
dy = Ly/Ny; %mesh size in the y direction [m]
dt = 0.1; %time increment [s]
Nt = 2000; %end time [s]
Nstep = floor(Nt/dt);
plotInterval = floor(Nt/dt/100); %Plot Interval for Pcolor

%%%matrix%%%
x = zeros(Nx+4,1); %location
y = zeros(Ny+4,1); %location
T_cd = zeros(Nx+4,Ny+4); %temperature for diffusion-convection equation
XconvT = zeros(Nx+4,Ny+4); %convection term in the x direction
YconvT = zeros(Nx+4,Ny+4); %convection term in the y direction
diffX = zeros(Nx+4,Ny+4); %diffusion term in the y direction for d-c eq.
diffY = zeros(Nx+4,Ny+4); %diffusion term in the y direction for d-c eq.
RHS = zeros(Nx+4,Ny+4); %Right Hand Side of the Heat Transfer eq.
Vr= zeros(Nx+4,Ny+4); 

% Setting Initial Condition
for i = 3:Nx+2
    for j = 3:Ny+2
        T_cd(i,j) = T0;
    end
end

%coordinates for figures
for i = 1:Nx+4
    x(i) = -Lx/2+(i-2) *dx;
end

for j = 1:Ny+4
    y(j) = -Ly/2+(j-2) *dy;
end

%Mesh for Pcolor
[XCoor,YCoor] = meshgrid(x,y);
XCoor = XCoor';
YCoor = YCoor';

%Setting boundary Condition in a different file
T_cd = RenewBCMiddle(T_cd,T0,Th,Lh,dx,dy,Center);

%Cool stuff (Plot figure to identify the heat value in 4 variables (x,y,T,t) using Pcolor)
figure(1)
pcolor(XCoor(3:Nx+2,3:Ny+2),YCoor(3:Nx+2,3:Ny+2),T_cd(3:Nx+2,3:Ny+2))
axis([x(3),x(Nx+2),y(3),y(Ny+2)])
shading interp
hold on
xlabel('X','FontSize',16)
ylabel('Y','FontSize',16)
colorbar('location','SouthOutside','FontSize',16)
caxis([T0 Th]);
set(gca,'FontSize',13);
colormap(jet(256));

%start the heat transfer iteration
for t=1:Nstep
    pause(0.001);
for i=3:Nx+2
for j=3:Ny+2
    if x(i)^2+y(j)^2>c^2
        Vx=b*c^2*y(j)/(y(j)^2+x(i)^2)*-1;
        Vy=b*c^2*x(i)/(y(j)^2+x(i)^2);
        Vxx(i,j)=Vx;
        Vyy(i,j)=Vy;
        Vr(i,j)=sqrt(Vx^2+Vy^2);
	else
        Vx=b*y(j)*-1;
        Vy=b*x(i);
        Vxx(i,j)=Vx;
        Vyy(i,j)=Vy;
    end
    XconvT(i,j) = Vx*(T_cd(i+1,j)-T_cd(i-1,j))/(2*dx);
    YconvT(i,j) = Vy*(T_cd(i,j+1)-T_cd(i,j-1))/(2*dy);
    diffX(i,j) = a*(-T_cd(i+2,j)+16*T_cd(i+1,j)-30*T_cd(i,j)+16*T_cd(i-1,j)-T_cd(i-2,j))/(12*dx^2);
    diffY(i,j) = a*(-T_cd(i,j+2)+16*T_cd(i,j+1)-30*T_cd(i,j)+16*T_cd(i,j-1)-T_cd(i,j-2))/(12*dy^2);
end
end
    RHS = diffX+diffY - XconvT - YconvT;
    T_cd = T_cd + dt * RHS;
    T_cd = RenewBCMiddle(T_cd,T0,Th,Lh,dx,dy,Center);
    if(mod(t,plotInterval) == 0)
    pcolor(XCoor(3:Nx+2,3:Ny+2),YCoor(3:Nx+2,3:Ny+2),T_cd(3:Nx+2,3:Ny+2))
    shading interp
    step = num2str(t*dt);
    step = strcat('t = ','',step);
    title(step,'FontSize',24);
    end
end

%1D graph at Nx=100 and along y axis
figure(2)
plot(y(3:Ny+2),T_cd(100,3:Ny+2),'-b','linewidth',1); 
legend('U=5 m/s')
xlabel('y(m)')
ylabel('T(K)')
grid minor

%Below are extras figure to visualize the velocity vector on a graph
figure(3)
q=quiver(XCoor(3:Nx+2,3:Ny+2),YCoor(3:Nx+2,3:Ny+2),Vxx(3:Nx+2,3:Ny+2),Vyy(3:Nx+2,3:Ny+2));
axis([x(3),x(Nx+2),y(3),y(Ny+2)])
title('Velocity Distribution in the room')
set(gca,'Color','k')
xlabel('x(m)')
ylabel('y(m)')
colorbar('location','SouthOutside','FontSize',16)
caxis([min(Vr(:,Nx+2)) max(Vr(:,Nx+2))]);
colormap(jet(256));
mags = sqrt(sum(cat(2, q.UData(:), q.VData(:), ...
            reshape(q.WData, numel(q.UData), [])).^2, 2));
%// Get the current colormap
currentColormap = colormap(gca);
%// Now determine the color to make each arrow using a colormap
[~, ~, ind] = histcounts(mags, size(currentColormap, 1));

%// Now map this to a colormap to get RGB
cmap = uint8(ind2rgb(ind(:), currentColormap) * 255);
cmap(:,:,4) = 255;
cmap = permute(repmat(cmap, [1 3 1]), [2 1 3]);

%// We repeat each color 3 times (using 1:3 below) because each arrow has 3 vertices
set(q.Head, ...
    'ColorBinding', 'interpolated', ...
    'ColorData', reshape(cmap(1:3,:,:), [], 4).');   %'

%// We repeat each color 2 times (using 1:2 below) because each tail has 2 vertices
set(q.Tail, ...
    'ColorBinding', 'interpolated', ...
    'ColorData', reshape(cmap(1:2,:,:), [], 4).');

