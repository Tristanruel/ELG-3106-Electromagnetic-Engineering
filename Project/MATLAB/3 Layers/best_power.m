%This code will take a while to run, if you see it saying "Iteration: x"
%it is working, don't be afraid.
n_0 = 1;
n_4 = 3.5;
Lambda_C = 650;
Lambda_Start = 400;
Lambda_End = 1400;
Step_Size = 1;
Max_Iteration = 1000; %change this to a reasonable number for testing. Like 5 or 10.

Max_Size = ceil((3 - 1) / 0.4 + 1) ^ 3;
Store_n_1 = zeros(1, Max_Size);
Store_n_2 = zeros(1, Max_Size);
Store_n_3 = zeros(1, Max_Size);
Store_Total_Power = zeros(1, Max_Size);
Best_Powers = zeros(1, Max_Iteration);
Best_Power=0;

n_1_Start = 1; n_1_End = 3;
n_2_Start = 1; n_2_End = 3;
n_3_Start = 1; n_3_End = 3;
index = 1;

for Iteration = 1:Max_Iteration
    fprintf('Iteration: %d\n', Iteration);

    for n_1 = n_1_Start:Step_Size:n_1_End
        for n_2 = n_2_Start:Step_Size:n_2_End
            for n_3 = n_3_Start:Step_Size:n_3_End
                Store_PWR = zeros(1, Lambda_End - Lambda_Start + 1);
                Reflectance = zeros(1, Lambda_End - Lambda_Start + 1);

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
                    Reflectance(Lambda - Lambda_Start + 1) = abs(Gamma)^2;
                    Trans = abs(Tau)^2 / (n_0 / n_4);
                    IRRAD = (6.16 * 10^15) / (Lambda^5 * (exp(2484 / Lambda) - 1));
                    Power = Trans * IRRAD;
                    Store_PWR(Lambda - Lambda_Start + 1) = Power;
                    Best_Powers(Iteration) = Best_Power;
                end

                Store_n_1(index) = n_1;
                Store_n_2(index) = n_2;
                Store_n_3(index) = n_3;
                Store_Total_Power(index) = sum(Store_PWR);
                index = index + 1;
            end
        end
    end

    [Best_Power, Pos] = max(Store_Total_Power);
    b_n_1 = Store_n_1(Pos); b_n_2 = Store_n_2(Pos); b_n_3 = Store_n_3(Pos);
    n_1_Start = max(1, b_n_1 - Step_Size * 2);
    n_1_End = min(3, b_n_1 + Step_Size * 2);
    n_2_Start = max(1, b_n_2 - Step_Size * 2);
    n_2_End = min(3, b_n_2 + Step_Size * 2);
    n_3_Start = max(1, b_n_3 - Step_Size * 2);
    n_3_End = min(3, b_n_3 + Step_Size * 2);
    Step_Size = max(0.01, Step_Size / 2);
end

plot(Lambda_Start:Lambda_End, Reflectance * 100);
title('Reflectivity vs Wavelength (400 nm to 1400 nm)');
xlabel('Wavelength (nm)');
ylabel('Reflectivity (%)');
xlim([Lambda_Start, Lambda_End]);
fprintf('\nOptimal n_1 = %.4f\nOptimal n_2 = %.4f\nOptimal n_3 = %.4f\nTotal Power Production (400 nm to 1400nm) = %.4f Watts\n', b_n_1, b_n_2, b_n_3, Best_Power);
