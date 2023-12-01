n_0 = 1;
n_1 = 1.4;
n_2 = 2.6192;
n_3 = 3.5;
g01 = (n_0-n_1)/(n_0+n_1);
g12 = (n_1-n_2)/(n_1+n_2);
g23 = (n_2-n_3)/(n_2+n_3);
t01 = 2*n_0/(n_0+n_1);
t12 = 2*n_1/(n_1+n_2);
t23 = 2*n_2/(n_2+n_3);
lambda_c = 650;
wavelength = 200:1:2199;
L_values = 200:1:2399; 

q01 = (1/t01)*[1 g01; g01 1];
q12 = (1/t12)*[1 g12; g12 1];
q23 = (1/t23)*[1 g23; g23 1];

Power = zeros(1, length(wavelength));

for k = 1:length(wavelength)
    L = L_values(k);
    delta_m = (pi/2) * (lambda_c / L);
    p1 = [exp(1i*delta_m) 0; 0 exp(-1i*delta_m)];
    T = q01 * p1 * q12 * p1 * q23;
    g = T(2,1) / T(1,1);
    r = abs(g)^2;
    pow = (((1-r)*(6.16*10^15)) / ((L^5)*(exp(2484/L)-1)));
    Power(k) = pow;
end

wavelength1 = 400:1:1399;

figure(1);
plot(wavelength, Power);
title('Power Transmitted vs Wavelength (400 nm to 1400 nm)');
xlabel('Wavelength (nm)');
ylabel('Power (W/m^2)');
xlim([400,1400]);

figure(2);
plot(wavelength, Power);
title('Power Transmitted vs Wavelength (200 nm to 2200 nm)');
xlabel('Wavelength (nm)');
ylabel('Power (W/m^2)');
xlim([200,2200]);

fprintf('Total Power in Watts (400 nm to 1400 nm) = %f\n', sum(Power(231:1399)));
fprintf('Total Power in Watts (200 nm 2200 nm) = %f\n', sum(Power));
