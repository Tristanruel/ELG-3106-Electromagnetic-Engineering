n_0 = 1; 
n_1 = 1.4; 
n_3 = 3.15; 
n_cell = 3.5; 
lambda_C = 650;

r01 = (n_0 - n_1)/(n_0 + n_1);
t01 = 2*n_0/(n_0 + n_1);
Q01 = (1/t01)*([1 r01; r01 1]);
r3S = (n_3 - n_cell)/(n_3 + n_cell);
t3S = 2*n_3/(n_3 + n_cell);
Q3S = (1/t3S)*([1 r3S; r3S 1]);
Delta = pi/2;
P = [exp(1j*Delta) 0; 0 exp(-1j*Delta)];
n_2_range = 0:0.01:4.5;
Store_Reflectance = zeros(1, length(n_2_range));

for i = 1:length(n_2_range)
    n_2 = n_2_range(i);
    r12 = (n_1 - n_2)/(n_1 + n_2);
    t12 = 2*n_1/(n_1 + n_2);
    Q12 = (1/t12)*([1 r12; r12 1]);
    r23 = (n_2 - n_3)/(n_2 + n_3);
    t23 = 2*n_2/(n_2 + n_3);
    Q23 = (1/t23)*([1 r23; r23 1]);
    T = Q01*P*Q12*P*Q23*P*Q3S;
    Gamma = T(2,1)/T(1,1);
    Store_Reflectance(i) = abs(Gamma)^2;
end

[~, Min_Index] = min(Store_Reflectance);
min_n_2 = n_2_range(Min_Index);
plot(n_2_range, Store_Reflectance * 100);
title('Reflectivity versus n_2 Values for lambda_C = 650 nm');
xlabel('n_2 Value');
ylabel('Reflectivity (%)');
fprintf('n_1 = 1.4\nMinimum Reflectivity found at n_2 = %.2f\nn_3 = 3.15\n', min_n_2);
