clear; clc;

%% Part I: Supersonic Inlet Design

% Problem Inputs
M1 = 3.2;
gamma = 1.4;

%% Program Inputs
delta = 0.1;          % Flow turning angle increment in degrees
x = 25;               % Maximum theta1 in degrees
tol = 0.1;            % Tolerance for equality check (if nee
ded later)
% Preallocate a results matrix
% Columns: [theta1, beta1, Mn1b, Mn1a, M2, Po_21, Mn2b, beta2, theta2, Mn2a, M3, Po_32, Mn3b, beta3, theta3, Mn3a, M4, Po_43, M5, Po_54, pi_d]
results = nan(length(0:delta:x), 21);

%% Theta values in degrees
theta1_vals = 0:delta:x;

%% Loop over theta1 values (all in degrees)
for i = 1:length(theta1_vals)
    theta1 = theta1_vals(i);
    
    % Handle theta1 = 0 separately (no deflection)
    if theta1 == 0
        results(i,:) = [theta1, NaN(1,20)];
        fprintf('Iteration %d: theta1 = %.2f° (skipped, theta1=0)\n', i, theta1);
        continue;
    end
    
    %% Region 1 to 2 Calculations (Oblique Shock 1)
    
    % Beta 
    f = @(beta) (2 * cotd(beta) * (M1^2 * sind(beta)^2 - 1)) / ...
                ((gamma + 1) * M1^2 - 2 * (M1^2 * sind(beta)^2 - 1)) - tand(theta1);
    
    beta_lower = theta1 + 0.1; % start just above theta1 to avoid singularities in cotd
    beta_upper = beta_lower;
    foundBracket = false;
    while beta_upper < 90
        if f(beta_lower) * f(beta_upper) < 0
            foundBracket = true;
            break;
        end
        beta_upper = beta_upper + 0.5;
    end
    
    if foundBracket
        beta1 = fzero(f, [beta_lower, beta_upper]);
    else
        beta1 = NaN;
    end
    
    % Mn1b, Mn1a, and M2
    if isnan(beta1)
        Mn1b = NaN;
        Mn1a = NaN;
        M2 = NaN;
    else
        Mn1b = M1 * sind(beta1);
        Mn1a_sqrt = ( (Mn1b^2 + 2/(gamma - 1)) / ((2*gamma/(gamma - 1)) * Mn1b^2 - 1) );
        if Mn1a_sqrt < 0
            Mn1a = NaN;
        else
            Mn1a = sqrt(Mn1a_sqrt);
        end

        if abs(sind(beta1 - theta1)) < eps
            M2 = NaN;
        else
            M2 = Mn1a / sind(beta1 - theta1);
        end
    end
    
    % pi_1
    if isnan(Mn1b)
        Po_21 = NaN;
    else
        Po_21 = (((gamma + 1) * Mn1b^2) / ((gamma - 1) * Mn1b^2 + 2))^(gamma/(gamma-1)) * ...
                ((gamma + 1) / (2 * gamma * Mn1b^2 - (gamma - 1)))^(1/(gamma - 1));
    end
    
    %% Region 2 to 3 Calculations (Oblique Shock 2)
    
    % Mn2b
    Mn2b = Mn1b;
    
    % Beta
    if ~isnan(M2) && M2 >= Mn2b
        beta2 = asind(Mn2b / M2);
    else
        beta2 = NaN;
    end
    
    % Theta
    if ~isnan(beta2) && ~isnan(M2)
        theta2 = atand((2 * cotd(beta2) * (M2^2 * sind(beta2)^2 - 1)) / ...
                (((gamma + 1) * M2^2) - 2 * (M2^2 * sind(beta2)^2 - 1)));
    else
        theta2 = NaN;
    end
    
    % Mn2a
    if ~isnan(Mn2b)
        Mn2a_sqrt = ( (Mn2b^2 + 2/(gamma - 1)) / ((2*gamma/(gamma - 1)) * Mn2b^2 - 1) );
        if Mn2a_sqrt < 0
            Mn2a = NaN;
        else
            Mn2a = sqrt(Mn2a_sqrt);
        end
    else
        Mn2a = NaN;
    end
    
    % M3
    if ~isnan(Mn2a) && ~isnan(beta2) && ~isnan(theta2) && abs(sind(beta2 - theta2)) >= eps
        M3 = Mn2a / sind(beta2 - theta2);
    else
        M3 = NaN;
    end
    
    % pi_2
    if ~isnan(Mn2b)
        Po_32 = (((gamma + 1) * Mn2b^2) / ((gamma - 1) * Mn2b^2 + 2))^(gamma/(gamma-1)) * ...
                ((gamma + 1) / (2 * gamma * Mn2b^2 - (gamma - 1)))^(1/(gamma - 1));
    else
        Po_32 = NaN;
    end
    
    %% Region 3 to 4 Calculations (Oblique Shock 3)
    
    % Mn3b
    Mn3b = Mn2b;
    
    % M3
    if ~isnan(M3) && M3 >= Mn3b
        beta3 = asind(Mn3b / M3);
    else
        beta3 = NaN;
    end
    
    % theta3
    if ~isnan(beta3) && ~isnan(M3)
        theta3 = atand((2 * cotd(beta3) * (M3^2 * sind(beta3)^2 - 1)) / ...
                (((gamma + 1) * M3^2) - 2 * (M3^2 * sind(beta3)^2 - 1)));
    else
        theta3 = NaN;
    end
    
    % Mn3a
    if ~isnan(Mn3b)
        Mn3a_sqrt = ( (Mn3b^2 + 2/(gamma - 1)) / ((2*gamma/(gamma - 1)) * Mn3b^2 - 1) );
        if Mn3a_sqrt < 0
            Mn3a = NaN;
        else
            Mn3a = sqrt(Mn3a_sqrt);
        end
    else
        Mn3a = NaN;
    end
    
    % M4
    if ~isnan(Mn3a) && ~isnan(beta3) && ~isnan(theta3) && abs(sind(beta3 - theta3)) >= eps
        M4 = Mn3a / sind(beta3 - theta3);
    else
        M4 = NaN;
    end
    
    % pi_3
    if ~isnan(Mn3b)
        Po_43 = (((gamma + 1) * Mn3b^2) / ((gamma - 1) * Mn3b^2 + 2))^(gamma/(gamma-1)) * ...
                ((gamma + 1) / (2 * gamma * Mn3b^2 - (gamma - 1)))^(1/(gamma - 1));
    else
        Po_43 = NaN;
    end
    
    %% Region 4 to 5 Calculations (Normal Shock)
    
    % M5
    M5_sqrt = ( (M4^2 + 2/(gamma - 1)) / ((2*gamma/(gamma - 1)) * M4^2 - 1) );
    if M5_sqrt < 0 
        M5 = NaN; 
    else
        M5 = sqrt(M5_sqrt);
    end
    % pi_4
    if ~isnan(M4)
        Po_54 = (((gamma + 1) * M4^2) / ((gamma - 1) * M4^2 + 2))^(gamma/(gamma-1)) * ...
                ((gamma + 1) / (2 * gamma * M4^2 - (gamma - 1)))^(1/(gamma - 1));
    else
        Po_54 = NaN;
    end
    
    %% Final Pressure Recovery Ratio Calculation
    pi_d = Po_21 * Po_32 * Po_43 * Po_54;
    
    %% Store all computed values in the results matrix
    results(i,:) = [theta1, beta1, Mn1b, Mn1a, M2, Po_21, ...
                    Mn2b, beta2, theta2, Mn2a, M3, Po_32, ...
                    Mn3b, beta3, theta3, Mn3a, M4, Po_43, M5, Po_54, pi_d];
    
    %% Display the results for this iteration
    fprintf('Iteration %d:\n', i);
    fprintf('  Region 1-2: theta1 = %.2f°, beta1 = %.2f°, Mn1b = %.4f, Mn1a = %.4f, M2 = %.4f, Po21 = %.4f\n', ...
            theta1, beta1, Mn1b, Mn1a, M2, Po_21);
    fprintf('  Region 2-3: Mn2b = %.4f, beta2 = %.2f°, theta2 = %.2f°, Mn2a = %.4f, M3 = %.4f, Po32 = %.4f\n', ...
            Mn2b, beta2, theta2, Mn2a, M3, Po_32);
    fprintf('  Region 3-4: Mn3b = %.4f, beta3 = %.2f°, theta3 = %.2f°, Mn3a = %.4f, M4 = %.4f, Po43 = %.4f\n', ...
            Mn3b, beta3, theta3, Mn3a, M4, Po_43);
    fprintf('  Region 4-5: M5 = %.4f, Po54 = %.4f\n', M5, Po_54);
    fprintf('  Pressure Recovery Ratio (pi_d) = %.4f\n', pi_d);
end

% Define column headers for the results matrix
headers = {'theta1', 'beta1', 'Mn1b', 'Mn1a', 'M2', 'Po21', ...
           'Mn2b', 'beta2', 'theta2', 'Mn2a', 'M3', 'Po32', ...
           'Mn3b', 'beta3', 'theta3', 'Mn3a', 'M4', 'Po43', 'M5', 'Po54', 'pi_d'};

% Convert the results matrix to a table using the headers
results_table = array2table(results, 'VariableNames', headers);

% Write the table to an Excel file
writetable(results_table, 'shock_results.xlsx');

%% Display "Designed Inlet Parameters" if M4 ~ 1.30
tolM4 = 1e-3;
idx = find(abs(results(:,17) - 1.30) < tolM4, 1, 'first');  % Column 17 is M4
if isempty(idx)
    fprintf('No iteration found with M4 = 1.30 within tolerance.\n');
else
    % Gather relevant values from that iteration
    beta1  = results(idx,2);   theta1 = results(idx,1);
    beta2  = results(idx,8);   theta2 = results(idx,9);
    beta3  = results(idx,14);  theta3 = results(idx,15);
    M2_val = results(idx,5);
    M3_val = results(idx,11);
    M4_val = results(idx,17);
    M5_val = results(idx,19);
    Po21   = results(idx,6);
    Po32   = results(idx,12);
    Po43   = results(idx,18);
    Po54   = results(idx,20);
    % pi_d is the overall pressure recovery ratio (column 21)
    pi_d   = results(idx,21);
   
    % Creating the Designed Inlet Parameters Table
    n    = (1:5)';
    Mn   = [M1; M2_val; M3_val; M4_val; M5_val];
    B    = [beta1; beta2; beta3; NaN; NaN];
    T    = [theta1; theta2; theta3; NaN; NaN];
    Pd   = [Po21; Po32; Po43; Po54; NaN];  % Pi_d at each station
    
    % Print table header
    fprintf('\nDesigned Inlet Parameters:\n');
    fprintf(' n     M_n     Beta     Theta    Pi_n\n');
    
    % Print each row with consistent alignment
    for row = 1:5
        % Beta
        if ~isnan(B(row))
            betaStr = sprintf('%8.4f', B(row));
        else
            betaStr = '        ';  % blank
        end
        
        % Theta
        if ~isnan(T(row))
            thetaStr = sprintf('%8.4f', T(row));
        else
            thetaStr = '        ';  % blank
        end
        
        % Pi_d
        if ~isnan(Pd(row))
            pidStr = sprintf('%8.4f', Pd(row));
        else
            pidStr = '        ';  % blank
        end
        
        fprintf('%2d %8.4f %8s %8s %8s\n', ...
                n(row), Mn(row), betaStr, thetaStr, pidStr);
    end
    
    % Now display the overall pressure recovery ratio (pi_d)
    fprintf('\nOverall Pressure Recovery Ratio (pi_d) = %.4f\n', pi_d);
end