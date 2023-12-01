j = 1j; 
n_0 = 1;
n_3 = 3.5;
central = 650; 
Lambda_Range = 400:1400;
numLambdas = length(Lambda_Range);
IRRAD_Const = 6.16 * 10^15;
Exp_Const = 2484;

n_1_Start = 1;
n_1_End = 3;
n_2_Start = 1;
n_2_End = 3;
Step_Size = 0.4;
Max_Iteration = 5;


numN1 = ceil((n_1_End - n_1_Start) / Step_Size) + 1;
numN2 = ceil((n_2_End - n_2_Start) / Step_Size) + 1;
Store_n_1 = zeros(1, numN1 * numN2);
Store_n_2 = zeros(1, numN1 * numN2);
Store_Total_Power = zeros(1, numN1 * numN2);


for Iteration = 0:Max_Iteration
    idx = 1;
    for n_1 = n_1_Start:Step_Size:n_1_End
        for n_2 = n_2_Start:Step_Size:n_2_End
            Best_Reflec = zeros(1, numLambdas);
            Store_PWR = zeros(1, numLambdas);
            r01 = (n_0 - n_1)/(n_0 + n_1);
            r12 = (n_1 - n_2)/(n_1 + n_2);
            r2S = (n_2 - n_3)/(n_2 + n_3);
            t01 = 2 * n_0 / (n_0 + n_1);
            t12 = 2 * n_1 / (n_1 + n_2);
            t2S = 2 * n_2 / (n_2 + n_3);
            Q01 = (1/t01) * [1 r01; r01 1];
            Q12 = (1/t12) * [1 r12; r12 1];
            Q2S = (1/t2S) * [1 r2S; r2S 1];

            for i = 1:numLambdas
                Lambda = Lambda_Range(i);
                Delta = (pi/2) * (central / Lambda);
                P = [exp(j * Delta) 0; 0 exp(-j * Delta)];
                T = Q01 * P * Q12 * P * Q2S;
                Gamma = T(2,1) / T(1,1);
                Tau = 1 / T(1,1);
                Trans = (abs(Tau)^2) / (n_0 / n_3);
                Reflectance = abs(Gamma)^2;
                IRRAD = IRRAD_Const / ((Lambda^5) * (exp(Exp_Const / Lambda) - 1));
                Power = Trans * IRRAD;
                Store_PWR(i) = Power;
                Best_Reflec(i) = Reflectance;
            end
            PowerSum = sum(Store_PWR);
            Store_n_1(idx) = n_1;
            Store_n_2(idx) = n_2;
            Store_Total_Power(idx) = PowerSum;
            idx = idx + 1;
        end
    end
    [Best_Power, Pos] = max(Store_Total_Power);
    Best_n_1 = Store_n_1(Pos);
    Best_n_2 = Store_n_2(Pos);
    if Iteration < 5
        n_1_Start = max(Best_n_1 - Step_Size * 2, 1);
        n_1_End = min(Best_n_1 + Step_Size * 2, n_1_End);
        n_2_Start = max(Best_n_2 - Step_Size * 2, 1);
        n_2_End = min(Best_n_2 + Step_Size * 2, n_2_End);
        Step_Size = max(Step_Size / 2, 0.01);
    end
end

figure(1)
plot(Lambda_Range, Best_Reflec * 100);
title('Optimized Graph of Reflectivity vs Wavelength (400 nm to 1400 nm)');
xlabel('Wavelength (nm)');
ylabel('Reflectivity (%)');
xlim([400, 1400]);

fprintf(' Optimal n_1 = %.2f', Best_n_1);
fprintf('\n Optimal n_2 = %.2f', Best_n_2);
fprintf('\n Total Power in Watts = %.4f\n', Best_Power);
