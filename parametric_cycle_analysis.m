clear; clc; close all;

%% Engine Parameters (common values)
gamma_d  = 1.4;             % Inlet gamma
gamma_c  = 1.37;            % Compressor gamma
gamma_t  = 1.33;            % Turbine gamma
gamma_n  = 1.36;            % Nozzle gamma
cp       = 1100;            % [J/(kg·K)]
R        = 287;             % [J/(kg·K)]

% Efficiencies
eta_d = 0.97;   % Diffuser
eta_c = 0.85;   % Compressor
eta_b = 0.98;   % Combustor
eta_t = 0.90;   % Turbine
eta_n = 0.98;   % Nozzle

% Pressure loss factors
pi_d = 0.79;    % Overall inlet/diffuser pressure ratio from Part 1
pi_b = 0.95;    % Burner pressure ratio

% Fuel heating value [J/kg]
Qr = 45e6;      % 45 MJ/kg

%% Ranges
rc_vals = logspace(log10(2), log10(100), 1000);  % Compressor pressure ratio range
T04_vals = [1500, 1600, 1700];                   % Three combustor exit temperatures

% Colors for Specific Thrust and TSFC plots:
colors_ST   = { [0.7, 0, 0], [0.8, 0.65, 0], [0, 0, 0.7] };
colors_TSFC = { [0.8, 0.4, 0], [0.5, 0, 0.5], [0, 0.5, 0] };

n_rc  = length(rc_vals);
n_t04 = length(T04_vals);

% Mach numbers for which to repeat the figures (added Ma = 0)
MachVals = [0, 0.85, 2, 3.2];

%% Loop over different Mach numbers
for m = 1:length(MachVals)
    Ma = MachVals(m);
    
    %% Set ambient conditions based on Ma
    if Ma == 0
        Ta = 288.2;              % Ambient temperature [K]
        Pa = 101.30 * 1000;        % Ambient pressure [Pa]
    elseif Ma == 0.85
        Ta = 216.7;              
        Pa = 18.75 * 1000;       
    elseif Ma == 2
        Ta = 216.7;
        Pa = 7.170 * 1000;
    elseif Ma == 3.2
        Ta = 216.7;
        Pa = 2.097 * 1000;
    end

    % Calculate flight speed [m/s]
    u = Ma * sqrt(gamma_d * R * Ta);

    % Preallocate arrays for figures
    specThrust   = zeros(n_rc, n_t04);  % Specific thrust [kN·s/kg]
    specFuelCons = zeros(n_rc, n_t04);  % TSFC [kg/(N·s)]
    
    eta_o_mat  = NaN(n_rc, n_t04);  % Overall efficiency
    eta_th_mat = NaN(n_rc, n_t04);  % Thermal efficiency
    eta_p_mat  = NaN(n_rc, n_t04);  % Propulsive efficiency

    %% Main Loop: Compute cycle variables for each rc and T04
    for j = 1:n_t04
        T04 = T04_vals(j);

        for i = 1:n_rc
            rc = rc_vals(i);

            %% Compressor inlet conditions (2)
            T0a = Ta * (1 + (gamma_d - 1)/2 * Ma^2)
            T02 = T0a

            P0a = Pa * (1 + (gamma_d - 1)/2 * Ma^2)^( gamma_d/(gamma_d - 1) );
            P02 = pi_d * P0a;

            %% Compressor outlet conditions (3)
            P03 = P02 * rc;
            exponent_c = (gamma_c - 1)/gamma_c;
            T03 = T02 * (1 + (1/eta_c)*( rc^exponent_c - 1 ))

            %% Burner fuel-air ratio
            T_ratio = T04 / T03;
            T_ratio*T03
            f = (T_ratio - 1) / ( (Qr * eta_b)/(cp * T03) - T_ratio );
            
            %% Turbine inlet pressure (4)
            P04 = pi_b * P03;

            %% Turbine outlet conditions (5)
            T05 = T04 - (T03 - T02)
            if T05 < 0
                specThrust(i,j)   = NaN;
                specFuelCons(i,j) = NaN;
                continue;
            end
            exponent_t = (gamma_t - 1)/gamma_t;
            P05 = P04 * (1 + (1/eta_t)*((T05/T04) - 1))^( gamma_t/(gamma_t-1) );

            %% Nozzle inlet conditions: Afterburner inoperative (6)
            T06 = T05
            P06 = P05;

            %% Nozzle exit velocity (7)
            exponent_n = (gamma_n - 1)/gamma_n;
            delta = 1 - (Pa/P06)^exponent_n;
            if delta < 0
                ue = NaN;
            else
                ue = sqrt(2 * eta_n * (gamma_n/(gamma_n - 1)) * R * T06 * delta);
            end
            if isnan(ue)
                specThrust(i,j)   = NaN;
                specFuelCons(i,j) = NaN;
                continue;
            end

            %% Specific Thrust & Fuel Consumption
            ST = (1 + f)*ue - u;  % [m/s]
            if ST <= 0
                specThrust(i,j)   = NaN;
                specFuelCons(i,j) = NaN;
                continue;
            end
            TSFC = f / ST;  % [kg/(N·s)]

            specThrust(i,j) = ST / 1000;  % Convert to kN·s/kg
            specFuelCons(i,j) = TSFC * 1000;

            %% Efficiency Calculations
            eta_o = ((ue - u)*u) / (f * Qr);
            eta_th = (0.5*(1+f)*ue^2 - 0.5*u^2) / (f * Qr);
            eta_p = (2*(u/ue)) / (1 + (u/ue));

            eta_o_mat(i,j)  = eta_o;
            eta_th_mat(i,j) = eta_th;
            eta_p_mat(i,j)  = eta_p;
        end
    end

    % Filter out specific thrust values greater than 0.1 (kN·s/kg)
    specFuelCons(specFuelCons > 0.1) = NaN;
    
    %% First Figure: Specific Thrust & TSFC for current Mach number
    figure('Color','white');
    hold on;
    % Plot specific thrust on left y-axis
    yyaxis left;
    set(gca, 'YColor', 'k');
    for j = 1:n_t04
        semilogx(rc_vals, specThrust(:, j), 'LineStyle', '-', 'Color', colors_ST{j}, 'LineWidth', 2, ...
            'DisplayName', sprintf('T_{04} = %d K: Spec.Thrust', T04_vals(j)));
    end
    xlabel('Compressor Pressure Ratio, $r_c$', 'Interpreter','latex');
    ylabel('Specific Thrust [kN$\cdot$s/kg]', 'Interpreter','latex');
    set(gca, 'XLim', [2 100], 'XScale', 'log');
    grid on;
    
    % Plot TSFC on right y-axis
    yyaxis right;
    set(gca, 'YColor', 'k');
    for j = 1:n_t04
        semilogx(rc_vals, specFuelCons(:, j), 'LineStyle', '-', 'Color', colors_TSFC{j}, 'LineWidth', 2, ...
            'DisplayName', sprintf('T_{04} = %d K: TSFC', T04_vals(j)));
    end
    ylabel('TSFC [kg/(N$\cdot$s)]', 'Interpreter','latex');
    
    title(sprintf('Turbojet Cruise at Mach %.2f: Specific Thrust and TSFC vs Compressor Ratio', Ma), 'Interpreter','latex');
    xticks([2,3,4,5,6,7,8,9,10,15,20,25,30,40,50,60,70,80,90,100]);
    legend('Location','best');
    hold off;

    %% Second Figure: Efficiencies for T04 (1600 K) at current Mach number
    MidTempIndex = 2;   % Corresponds to T04 = 1600 K
    figure('Color','white');
    hold on; grid on; box on;
    
    semilogx(rc_vals, eta_o_mat(:, MidTempIndex), 'LineWidth', 2, ...
        'DisplayName', '\eta_o (Overall Efficiency)', 'Color', [0.8, 0.4, 0]);
    semilogx(rc_vals, eta_th_mat(:, MidTempIndex), 'LineWidth', 2, ...
        'DisplayName', '\eta_{th} (Thermal Efficiency)', 'Color', [0, 0.5, 0.7]);
    semilogx(rc_vals, eta_p_mat(:, MidTempIndex), 'LineWidth', 2, ...
        'DisplayName', '\eta_p (Propulsive Efficiency)', 'Color', [0.5, 0, 0.5]);
    
    xlabel('Compressor Pressure Ratio, $r_c$','Interpreter','latex');
    ylabel('Efficiency','Interpreter','latex');
    set(gca,'XScale','log','XLim',[2 100]);
    title(sprintf('Efficiencies at $T_{04}$ = 1600 K and Mach %.2f', Ma), 'Interpreter','latex');
    xticks([2,3,4,5,6,7,8,9,10,15,20,25,30,40,50,60,70,80,90,100]);
    legend('Location','best');
    hold off;
    
end
