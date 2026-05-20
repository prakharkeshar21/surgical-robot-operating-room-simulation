clc
clear
close all

global robots handles

%% ================= ROBOT DATA =================

robots = [ ...
    struct('x',10,'y',10,'angle',0,'height',11), ...
    struct('x',40,'y',10,'angle',0,'height',11), ...
    struct('x',10,'y',40,'angle',0,'height',11), ...
    struct('x',40,'y',40,'angle',0,'height',11) ...
];

%% ================= FIGURE =================

figure('KeyPressFcn',@moveRobot,'Color','k')

hold on
grid on
view(3)
axis equal
axis([0 50 0 50 0 20])

xlabel('X','Color','w')
ylabel('Y','Color','w')
zlabel('Z','Color','w')

title('Surgical Robot Operating Room','Color','w')

%% ================= FLOOR =================

[X,Y] = meshgrid(0:50,0:50);
Z = zeros(size(X));
surf(X,Y,Z,'FaceColor',[0.85 0.85 0.85],'EdgeColor','none')

%% ================= OPERATION TABLE =================

centerX = 25;
centerY = 25;

[x,y,z] = cylinder([2.2 2.2],40);
z = z*4;
surf(x+centerX,y+centerY,z,...
'FaceColor',[0.3 0.3 0.3],...
'EdgeColor','none')

[Xt,Yt] = meshgrid(-9:0.4:9,-5:0.4:5);
Zt = ones(size(Xt))*4.3;
surf(Xt+centerX,Yt+centerY,Zt,...
'FaceColor',[0.7 0.8 0.9],...
'EdgeColor','none')

%% ================= REALISTIC PATIENT =================

px = centerX;
py = centerY;
pz = 4.3;

skinColor = [1 0.78 0.66];

% ===== TORSO (tapered) =====
r1 = 2.5;
r2 = 1.8;
[tx,ty,tz] = cylinder([r1 r2],50);
tz = tz * 2.2;

surf(tx+px, ty+py, tz+pz,...
'FaceColor',skinColor,...
'EdgeColor','none')

% ===== SHOULDERS =====
[Xs,Ys] = meshgrid(-3:0.2:3,-2:0.2:2);
Zs = 0.3*exp(-0.2*(Xs.^2 + (Ys*1.5).^2));

surf(Xs+px, Ys+(py+1.5), Zs+pz+2.2,...
'FaceColor',skinColor,...
'EdgeColor','none')

% ===== NECK =====
[nx,ny,nz] = cylinder([0.6 0.6],30);
nz = nz * 0.6;

surf(nx+px, ny+(py+2.6), nz+pz+2.2,...
'FaceColor',skinColor,...
'EdgeColor','none')

% ===== HEAD =====
[hsx,hsy,hsz] = sphere(40);
headRadius = 1.1;

surf(headRadius*hsx + px,...
     headRadius*hsy + (py+3.6),...
     headRadius*hsz + pz + 2.8,...
'FaceColor',skinColor,...
'EdgeColor','none')

% ===== PILLOW =====
[Xp,Yp] = meshgrid(-2:0.2:2,-1.5:0.2:1.5);
Zp = 0.3*ones(size(Xp));

surf(Xp+px, Yp+(py+3.6), Zp+pz+2.5,...
'FaceColor',[0.9 0.9 0.95],...
'EdgeColor','none')

% ===== SURGICAL AREA =====
[Xm,Ym] = meshgrid(-1.2:0.1:1.2,-0.6:0.1:0.6);
Zm = 0.05*exp(-2*(Xm.^2 + Ym.^2));

surf(Xm+px, Ym+py, Zm+pz+1.2,...
'FaceColor',[0.8 0 0],...
'EdgeColor','none')

camlight
lighting gouraud
material([0.3 0.8 0.2])

%% ================= DRAW ALL ROBOTS =================

handles = cell(1,length(robots));

for i = 1:length(robots)
    r = robots(i);
    handles{i} = drawRobot(r.x, r.y, r.angle, r.height);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = drawRobot(px,py,angle,toolH)

% BASE
[x,y,z] = cylinder([1.8 1.8],40);
z = z*1;
h(1) = surf(x+px,y+py,z,...
'FaceColor',[0.2 0.2 0.2],'EdgeColor','none');

% COLUMN
[x,y,z] = cylinder([0.6 0.6],40);
z = z*6 + 1;
h(2) = surf(x+px,y+py,z,...
'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');

% ARM
armLength = 4;

x1 = px;
y1 = py;
z1 = 7;

x2 = px + armLength*cosd(angle);
y2 = py + armLength*sind(angle);
z2 = toolH;

h(3) = plot3([x1 x2],[y1 y2],[z1 z2],...
'Color',[0 0.6 1],'LineWidth',6);

% ===== NEEDLE =====
needleAngle = 220;
needleLength = 1.5;

[nx,ny,nz] = cylinder([0.1 0.1],20);
nz = nz * needleLength;

rx = nx*cosd(needleAngle) - ny*sind(needleAngle);
ry = nx*sind(needleAngle) + ny*cosd(needleAngle);

h(4) = surf(rx + x2, ry + y2, nz + z2,...
'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');

[tx,ty,tz] = cylinder([0.15 0],20);
tz = tz * 0.5;

rx2 = tx*cosd(needleAngle) - ty*sind(needleAngle);
ry2 = tx*sind(needleAngle) + ty*cosd(needleAngle);

h(5) = surf(rx2 + x2, ry2 + y2, tz + z2 + needleLength,...
'FaceColor',[1 0 0],'EdgeColor','none');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function moveRobot(~,event)

global robots handles

step = 1;
angleStep = 5;
heightStep = 0.5;

centerX = 25;
centerY = 25;

for i = 1:length(robots)

    r = robots(i);

    dx = r.x - centerX;
    dy = r.y - centerY;

    dist = sqrt(dx^2 + dy^2);

    if dist ~= 0
        ux = dx / dist;
        uy = dy / dist;
    else
        ux = 0;
        uy = 0;
    end

    switch event.Key

        case 'w'
            r.x = r.x - ux * step;
            r.y = r.y - uy * step;

        case 's'
            r.x = r.x + ux * step;
            r.y = r.y + uy * step;

        case 'a'
            theta = atan2d(dy, dx) + 5;
            r.x = centerX + dist*cosd(theta);
            r.y = centerY + dist*sind(theta);

        case 'd'
            theta = atan2d(dy, dx) - 5;
            r.x = centerX + dist*cosd(theta);
            r.y = centerY + dist*sind(theta);

        case 'j'
            r.angle = r.angle + angleStep;

        case 'l'
            r.angle = r.angle - angleStep;

        case 'n'
            r.height = r.height + heightStep;

        case 'm'
            r.height = r.height - heightStep;

        otherwise
            return
    end

    robots(i) = r;

    delete(handles{i})
    handles{i} = drawRobot(r.x, r.y, r.angle, r.height);

end

drawnow

end