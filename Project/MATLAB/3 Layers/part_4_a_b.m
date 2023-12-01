j = 1j; 
n_0 = 1; 
n_1 = 1.4;
n_3 = 3.15;
n_4 = 3.5;  
Center = 650;
num_N_2 = 300; 

r01 = (n_0 - n_1) / (n_0 + n_1);
r3S = (n_3 - n_4) / (n_3 + n_4);
t01 = 2 * n_0 / (n_0 + n_1);
t3S = 2 * n_3 / (n_3 + n_4);
Q01 = (1 / t01) * [1 r01; r01 1];
Q3S = (1 / t3S) * [1 r3S; r3S 1];
Store_n_2 = linspace(1.4, 3, num_N_2);

Store_Total_Power_1 = computeTotalPower(400, 1400, Q01, Q3S, n_0, n_1, n_3, n_4, Center, num_N_2, Store_n_2);
Store_Total_Power_2 = computeTotalPower(200, 2200, Q01, Q3S, n_0, n_1, n_3, n_4, Center, num_N_2, Store_n_2);

plot(Store_n_2, Store_Total_Power_1, 'r', Store_n_2, Store_Total_Power_2, 'b');
title('Total Power Transmitted vs Varying n_2 Values');
xlabel('n_2');
ylabel('Total Power (W/m^2)');
legend('Wavelength 200-2200nm', 'Wavelength 400-1400nm');

[max_Power_1, maxY_1] = max(Store_Total_Power_1);
fprintf(' Maximum power transmitted in Watts (Wavelength 400-1400nm) = %.2fW', max_Power_1);
fprintf('\n n_2 value = %.2f', Store_n_2(maxY_1));

[max_Power_2, maxY_2] = max(Store_Total_Power_2);
fprintf('\n Maximum power transmitted in Watts (Wavelength 200-2200nm) = %.2fW', max_Power_2);
fprintf('\n n_2 value = %.2f \n', Store_n_2(maxY_2));
hold on;

function Store_Total_Power = computeTotalPower(Lambda_Start, Lambda_End, Q01, Q3S, n_0, n_1, n_3, n_4, Center, numN2, Store_n_2)
    Lambda_Array = Lambda_Start:Lambda_End;
    Delta_Array = (pi / 2) * (Center ./ Lambda_Array);
    IRRAD_Array = 6.16 * 10^15 ./ (Lambda_Array .^ 5 .* (exp(2484 ./ Lambda_Array) - 1));
    Store_Total_Power = zeros(1, numN2);

    for idx = 1:numN2
        N2 = Store_n_2(idx);
        r12 = (n_1 - N2) / (n_1 + N2);
        r23 = (N2 - n_3) / (N2 + n_3);
        t12 = 2 * n_1 / (n_1 + N2);
        t23 = 2 * N2 / (N2 + n_3);
        Q12 = (1 / t12) * [1 r12; r12 1];
        Q23 = (1 / t23) * [1 r23; r23 1];

        P = [exp(j * Delta_Array); exp(-j * Delta_Array)];
        T = zeros(2, length(Lambda_Array));
        for i = 1:length(Lambda_Array)
            P1 = [P(1, i) 0; 0 P(2, i)];
            T(:, i) = Q01 * P1 * Q12 * P1 * Q23 * P1 * Q3S * [1; 0];
        end
        Tau = 1 ./ T(1, :);
        Trans = (abs(Tau) .^ 2) * (n_4 / n_0);
        Store_PWR = Trans .* IRRAD_Array;

        Store_Total_Power(idx) = sum(Store_PWR);
    end
end
