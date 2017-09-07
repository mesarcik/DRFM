close all;
clear all;
clc;

fs = 100e6/2^8;
% t = (0:2^25-1)/(fs);
t = (0:2^15)/(fs);


y = cos(2*pi*100*t);

y_u_int_16 = uint16((y/2 +0.5)*(2^16 -1));

y_16_bits = [];
y_8_msb = [];
y_8_lsb = [];

for i = 1:length(y_u_int_16)
 	bits = dec2bin(y_u_int_16(i),16);
 	y_8_msb(i) =  bin2dec(bits(1:8));
 	y_8_lsb(i) =  bin2dec(bits(9:16));
end

t = 1:length(y_8_msb);

plot(t,y_8_msb,t, y_8_lsb);
legend('MSB','LSB')


















