function [c,ceq] = nonlinConstrFunc(z)

cOP = classOptimParam();    % constant Optimization Prameters
ceq = zeros(cOP.n,1);       % Compute nonlinear equalities at z

testingODE = 0; % select 1 to get an plot of the y and v solution of ode45
if testingODE
    testVal = [];
    testY = cell(1,cOP.n); 
    testT = cell(1,cOP.n);
end

h = cOP.tf/cOP.n;
n = cOP.n+1;
x = z(1:2*n);
u = z(2*n+1:4*n);

% multiple shooting
for i = 0:cOP.n-1   % shooting n-1 times
    [t,y] = ode45(@constrODE,[i*h,(i+1)*h],x(2*i+1:2*i+2),[],u(2*i+1:2*i+2));
    % equality constraints (Stetigkeitsbed f�r die Knoten)
    % X(t_{i+1})-X_{i+1} = 0
    % with X(t_{i+1}) being y(end,1:2) the Runge Kutta approximation
    ceq(2*i+1,1) = y(end,1)-x(2*i+3);
    ceq(2*i+2,1) = y(end,2)-x(2*i+4);
    if testingODE
        testVal(i+1,:) = [y(end,1) y(end,2)];
        testY{i+1} = y(:,1:2);
        testT{i+1} = t;
    end
end

if testingODE
    %     subplot(2,1,1)
    %     plot(testVal(:,1));
    %     title('ODE Solution position y')
    %     subplot(2,1,2)
    %     plot(testVal(:,2));
    %     title('ODE Solution velocity v')
    % plot of multiple shooted position values y
    close all
    figure
    for i = 1:cOP.n
        plot(testT{i},testY{i}(:,1),'b.')
        hold on
    end
end

cCCP = classCarConstantParam();     % constant Car Parameters

% Compute nonlinear inequalities
% u(1) <= R*((u(2)+...)
c = u(1:2:2*n-1)-cCCP.R*(u(2:2:2*n)+cCCP.F_A(x(2:2:2*n))+cCCP.F_R*ones(n,1)+cCCP.m*cCCP.a_max(x(2:2:2*n)));
end