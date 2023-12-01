n_0 = 1;
n_4 = 3.5;
Lambda_C = 650;
Lambda_Start = 400;
Lambda_End = 1400;

Step_Size = 1;
Max_Iteration = 1000; %change this to a reasonable number for testing. Like 5 or 10.

n_1_Start = 1; n_1_End = 3;
n_2_Start = 1; n_2_End = 3;
n_3_Start = 1; n_3_End = 3;

if isempty(gcp('nocreate'))
    parpool(24); %change "24" to the number of CPU cores that you have/want to use
end

for Iteration = 1:Max_Iteration
    fprintf('Iteration: %d\n', Iteration);

    n_1_Size = ceil((n_1_End - n_1_Start) / Step_Size + 1);
    n_2_Size = ceil((n_2_End - n_2_Start) / Step_Size + 1);
    n_3_Size = ceil((n_3_End - n_3_Start) / Step_Size + 1);
    Max_Size = n_1_Size * n_2_Size * n_3_Size;

    Temp_Store_Total_Power = zeros(1, Max_Size);
    Temp_Store_n_1 = zeros(1, Max_Size);
    Temp_Store_n_2 = zeros(1, Max_Size);
    Temp_Store_n_3 = zeros(1, Max_Size);

    parfor idx = 1:Max_Size
        [i1, i2, i3] = ind2sub([n_1_Size, n_2_Size, n_3_Size], idx);
        
        n_1 = n_1_Start + (i1 - 1) * Step_Size;
        n_2 = n_2_Start + (i2 - 1) * Step_Size;
        n_3 = n_3_Start + (i3 - 1) * Step_Size;

        Store_PWR = zeros(1, Lambda_End - Lambda_Start + 1);

        for Lambda = Lambda_Start:Lambda_End
            r01 = (n_0 - n_1)/(n_0 + n_1);
            r12 = (n_1 - n_2)/(n_1 + n_2);
            r23 = (n_2 - n_3)/(n_2 + n_3); 
            r3S = (n_3 - n_4)/(n_3 + n_4);

            t01 = 2 * n_0 / (n_0 + n_1);
            t12 = 2 * n_1 / (n_1 + n_2);
            t23 = 2 * n_2 / (n_2 + n_3);
            t3S = 2 * n_3 / (n_3 + n_4);

            Q01 = (1 / t01) * [1 r01; r01 1];
            Q12 = (1 / t12) * [1 r12; r12 1];
            Q23 = (1 / t23) * [1 r23; r23 1];
            Q3S = (1 / t3S) * [1 r3S; r3S 1];

            Delta = (pi / 2) * (Lambda_C / Lambda);
            P1 = [exp(1i * Delta) 0; 0 exp(-1i * Delta)];
            P2 = P1;
            P3 = P1;

            T = Q01 * P1 * Q12 * P2 * Q23 * P3 * Q3S;

            Gamma = T(2, 1) / T(1, 1);
            Tau = 1 / T(1, 1);
            Trans = abs(Tau)^2 / (n_0 / n_4);
            IRRAD = (6.16 * 10^15) / (Lambda^5 * (exp(2484 / Lambda) - 1));
            Power = Trans * IRRAD;
            Store_PWR(Lambda - Lambda_Start + 1) = Power;
        end

        Temp_Store_n_1(idx) = n_1;
        Temp_Store_n_2(idx) = n_2;
        Temp_Store_n_3(idx) = n_3;
        Temp_Store_Total_Power(idx) = sum(Store_PWR);
    end

    [Best_Power, Pos] = max(Temp_Store_Total_Power);
    Best_Powers(Iteration) = Best_Power;
    b_n_1 = Temp_Store_n_1(Pos); 
    b_n_2 = Temp_Store_n_2(Pos); 
    b_n_3 = Temp_Store_n_3(Pos);

    n_1_Start = max(1, b_n_1 - Step_Size);
    n_1_End = min(3, b_n_1 + Step_Size);
    n_2_Start = max(1, b_n_2 - Step_Size);
    n_2_End = min(3, b_n_2 + Step_Size);
    n_3_Start = max(1, b_n_3 - Step_Size);
    n_3_End = min(3, b_n_3 + Step_Size);

    Step_Size = max(0.01, Step_Size / 2);
end

figure;
plot(Lambda_Start:Lambda_End, Reflectance * 100);
title('Reflectance vs Wavelength');
xlabel('Wavelength (nm)');
ylabel('Reflectance (%)');
fprintf('\nOptimal N1 = %.4f\nOptimal N2 = %.4f\nOptimal N3 = %.4f\nTotal Power = %.4f Watts\n', b_n_1, b_n_2, b_n_3, Best_Power);