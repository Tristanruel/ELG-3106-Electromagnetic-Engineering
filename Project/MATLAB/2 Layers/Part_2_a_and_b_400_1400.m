j = 1j;        
n_0 = 1;    
n_1 = 1.4;    
n_2 = 2.62; 
n_3 = 3.5; 

Lambda_C = 650;
Lambda_Start = 400;
Lambda_End = 1400;
Lambda_Range = Lambda_Start:Lambda_End;

r01 = (n_0 - n_1)/(n_0 + n_1);
r12 = (n_1 - n_2)/(n_1 + n_2);
r2S = (n_2 - n_3)/(n_2 + n_3); 

t01 = 2*n_0/(n_0 + n_1);
t12 = 2*n_1/(n_1 + n_2);
t2S = 2*n_2/(n_2 + n_3);

Q01 = (1/t01)*([1 r01; r01 1]);
Q12 = (1/t12)*([1 r12; r12 1]);
Q2S = (1/t2S)*([1 r2S; r2S 1]);

Deltas = (pi/2)*(Lambda_C./Lambda_Range);
P1 = [exp(j*Deltas); exp(-j*Deltas)];

Reflectance = zeros(size(Lambda_Range));
Power = zeros(size(Lambda_Range));

for i = 1:length(Lambda_Range)
    Lambda = Lambda_Range(i);
    P_Matrix = [P1(1, i) 0; 0 P1(2, i)];
    
    T = Q01*P_Matrix*Q12*P_Matrix*Q2S;
    Gamma = T(2,1)/T(1,1);
    
    Reflectance(i) = abs(Gamma)^2;
    Trans = abs(1/T(1,1))^2/(n_0/n_3);
    IRRAD = (6.16*10^15)/((Lambda^5)*(exp(2484/Lambda)-1));
    Power(i) = Trans * IRRAD; 
end

plot(Lambda_Range, Reflectance*100);
title('Graph of Reflectivity vs Wavelength (400 nm to 1400 nm)');
xlabel('Wavelength (nm)');
ylabel('Reflectivity (%)');
xlim([Lambda_Start,Lambda_End]);
fprintf('Total Power in Watts = %f\n', sum(Power));