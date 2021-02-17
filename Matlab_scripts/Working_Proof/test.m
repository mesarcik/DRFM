close all;
clear all;
fs = 10000;
f0 = 100;
f_shift = 200;
t = 0:1/fs:2*pi;

% ---------------------------------------------------
%Signal

	y = cos(2*pi*10*t) + cos(2*pi*20*t)  + cos(2*pi*30*t) + cos(2*pi*40*t) +cos(2*pi*50*t);
% ---------------------------------------------------
%Plot Signal

	f = fs/2*linspace(-1,1,length(y));
	yf = fftshift(fft(y));

	figure(1); subplot(2,1,1);
	plot(y);
	title('Raw Data')
	subplot(2,1,2);
	plot(f,yf);

% ---------------------------------------------------
%I/Q Data
	I = real(hilbert(y));
	Q = imag(hilbert(y));

	figure(2); subplot(2,2,1);
	plot(real(I));
	title('I Data')
	subplot(2,2,2);
	plot(f,real((fftshift(fft(I)))));
	subplot(2,2,3);
	plot(real(Q));
	title('Q Data')
	subplot(2,2,4);
	plot(f,real((fftshift(fft(Q)))));

	% y_shift

	% y_shift_f = fft(y_shift);
	% y_shift_real_f = [y_shift_f(1:length(y_shift_f)/2)  ,fliplr( y_shift_f(1:length(y_shift_f)/2)) ];
	% y_shift_real = ifft(y_shift_real_f);
	% figure(3); subplot(2,1,1);plot(real(y_shift_real)); title('Time y_shift'); subplot(2,1,2); plot(real(y_shift_real_f)); title('Freq y_shift');

% ---------------------------------------------------
% frequency shift.

	% I_shift = (I.* exp(1j* 2*pi*f_shift*t));
	% Q_shift = (Q.* exp(1j* 2*pi*f_shift*t));

	% I_shift = (I.* cos(2*pi*f0*t));
	% Q_shift = (Q.* sin(2*pi*f0*t));

	% I_shift = I.* (cos(2*pi*f_shift*t) -1j*sin(2*pi*f_shift*t));
	% Q_shift = Q.* (cos(2*pi*f_shift*t) -1j*sin(2*pi*f_shift*t));

	I_shift = I.* (cos(2*pi*f_shift*t) ) - ( Q.* (sin(2*pi*f_shift*t)) );
	% Q_shift = Q.* (-1j*sin(2*pi*f_shift*t));

	% I_shift = (I.*cos(2*pi*f_shift*t)- (I.*(1j*sin(2*pi*f_shift*t)))) ; %
	% Q_shift = (Q.*cos(2*pi*f_shift*t)- (Q.*(1j*sin(2*pi*f_shift*t)))) ; %

% ---------------------------------------------------
% I/Q demod.

	y_shift = I_shift;

	f = fs/2*linspace(-1,1,length(y));
	y_shift_f = fftshift((fft(y_shift)));
	% y_shift_f = y_shift_f(1:length(y_shift_f)/2 +1);

	figure(4)
	subplot(2,1,1)
	plot(real(y_shift))
	title('I/Q demod')
	subplot(2,1,2)
	plot(f,y_shift_f);


	% figure(5)
	% subplot(2,1,1)
	% plot(real(I_Shift_II+1j.*Q_Shift_II))
	% title('Shifted by II')
	% subplot(2,1,2)
	% plot(real((fft((I_Shift_II+1j.*Q_Shift_II)))));
