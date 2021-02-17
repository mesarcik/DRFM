%===============================================================================
% Copyright (C) John-Philip Taylor
% jpt13653903@gmail.com
%
% This file is part of DE10-Lite Virtual JTAG MM Writer
%
% This file is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>
%=============================================================================== 

close all;
clear all;
fclose all;
clc;

% format compact
% format long eng
%% -----------------------------------------------------------------------------

% Data = uint8(2^7 * ones(1, 2^26));
% ExportData(Data, '50% DC');
% %% -----------------------------------------------------------------------------

% Data = uint8(0:(2^8-1));
% Data = repmat(Data, 1, 2^26/length(Data));
% ExportData(Data, 'Sawtooth');
% %% -----------------------------------------------------------------------------

% % 100 Hz when played at 390 kSps
		% fs = 100e6/2^8;
		% t = (0:2^25-1)/(fs);

		% rect = zeros(1,length(t));
		% rect(1:880) = 1;

		% I_Data = real(ifft(fft(cos(2*pi*100*t).*(2*cos(2*pi*100*t))).*rect ));
		% Q_Data = real(ifft(fft(sin(2*pi*100*t).*(2*sin(2*pi*100*t))).*rect ));
		% % I_Data = uint8(round((I_Data/2+0.5)*(2^8-1)));
		% % Q_Data = uint8(round((Q_Data/2+0.5)*(2^8-1)));


		% I_Shift_I = I_Data.*  cos(2*pi*100*t);
		% Q_Shift_I = Q_Data.*  sin(2*pi*100*t);
		% y_shift_I = I_Shift_I+ Q_Shift_I;

		% I_Data = uint16(round((I_Data/2+0.5)*(2^16-1)));
		% Q_Data = uint16(round((Q_Data/2+0.5)*(2^16-1)));

		% Data = [];
		% i_counter = 1;
		% q_counter = 1;
		% i_data  = [];
		% q_data = [];

		% for i = 1:length(t)
		% 	if(mod(i,2) == 0)
		% 		Data(i) = I_Data(i_counter);
		% 		i_data(i_counter) = I_Data(i_counter);
		% 		i_counter= i_counter+1;
		% 	else
		% 		Data(i) = Q_Data(q_counter);
		% 		q_data(q_counter) = Q_Data(q_counter);
		% 		q_counter = q_counter+1; 
		% 	end
		% end
		% ExportData(Data, '100 Hz Sine (390 kSps)');
%% -----------------------------------------------------------------------------
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%	THIS SHOULD BE CHANGED TO 16 BITS IN THE FUTURE. %%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		fs = 100e6/2^8;
		% t = (0:2^25-1)/(fs);
		t = (0:2^16)/(fs);

		
		% I_Data = real(ifft(fft(cos(2*pi*100*t).*(2*cos(2*pi*100*t))).*rect ));
		% Q_Data = real(ifft(fft(sin(2*pi*100*t).*(2*sin(2*pi*100*t))).*rect ));
		y = cos(2*pi*10*t) + cos(2*pi*20*t)  + cos(2*pi*30*t) + cos(2*pi*40*t) +cos(2*pi*50*t);
		
		% y = cos(2*pi*440*t);

		I_Data = real(hilbert(y)); 
		Q_Data = imag(hilbert(y));
		% figure(1); subplot(2,1,1); plot(I_Data); title('I');subplot(2,1,2); plot(real(Q_Data)); title('Q'); 

		% u16_I = uint16(round((I_Data/2+0.5)*(2^16-1)));
		% u16_Q = uint16(round((Q_Data/2+0.5)*(2^16-1)));


		u16_I = uint16(round(((I_Data +2) / 7)*(2^16-1)));
		u16_Q = uint16(round(((Q_Data +18) /22)*(2^16-1)));
		figure(2); subplot(2,1,1); plot(u16_I); title('u16_I');subplot(2,1,2); plot(u16_Q); title('u16_I');

		% % u16_I = uint16(round ((I_Data + 1 *ones(1,length(I_Data)))/2)*(2^16 -1) ));
		% % u16_Q = uint16(round ((Q_Data + 1*ones(1,length(Q_Data)))/2)*(2^16 -1)));



		% u16_sin = uint16(round((sin(2*pi*2e3*t)/2+0.5)*(2^16-1)));
		% u16_cos = uint16(round((cos(2*pi*2e3*t)/2+0.5)*(2^16-1)));

		% u_I_shift_real = (u16_I.*u16_cos);
		% u_Q_shift_real = (u16_Q.*u16_sin) ; %
		% figure(2); ;subplot(2,1,1);plot(u_I_shift_real); title ('I Shift ');subplot(2,1,2); plot(u_Q_shift_real);title ('Q Shift ');

		% u_y_shift_real = u16_cos - (u16_sin);
		% figure(3); subplot(2,1,1);plot(u_y_shift_real); title ('Y out ');subplot(2,1,2); plot(real(fft(u_y_shift_real)));

		% u16_I = uint16(round((I_Data + 2/ ((7))+0.34576)*(2^16-1)));
		% u16_Q = uint16(round((Q_Data + 16/((20)))*(2^16-1)));


		% u16_I = uint16(((I_Data + 2 *ones(1,length(I_Data)))/7)*(2^16 -1) );
		% u16_Q = uint16(((Q_Data + 16*ones(1,length(Q_Data)))/20)*(2^16 -1));

		% figure(2); subplot(2,1,1); plot(u16_I); title('u16_I');subplot(2,1,2); plot(real(u16_Q)); title('u16_Q'); 
				
		
		% % Real signal reconstruction
		f_shift = 5e3;
		y_shift_real = (I_Data.*cos(2*pi*f_shift*t) - (I_Data.*sin(2*pi*f_shift*t))) ; %
		figure(3); subplot(2,1,1);plot((y_shift_real)); title('Time y_(shift)'); subplot(2,1,2); plot(real(fftshift(fft(y_shift_real)))); title('Freq y_(shift)');
		% figure(4); subplot(2,1,1);plot(real(y)); title('Time y'); subplot(2,1,2); plot(real(fftshift(fft(y)))); title('Freq y');
	
		
		% Data = [];
		% i_counter = 1;
		% q_counter = 1;
		% i_data  = [];
		% q_data = [];

		% for i = 1:length(t)
		% 	if(mod(i,2) == 0)
		% 		Data(i) = u16_I(i_counter);
		% 		i_data(i_counter) = u16_I(i_counter);
		% 		i_counter= i_counter+1;
		% 	else
		% 		Data(i) = u16_Q(q_counter);
		% 		q_data(q_counter) = u16_Q(q_counter);
		% 		q_counter = q_counter+1; 
		% 	end
		% end
		% ExportData(Data, 'I-Q_Data');


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%	THIS SHOULD BE CHANGED TO 16 BITS IN THE FUTURE. %%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 100 Hz when played at 1.28 kSps
% fs = 100e6/(2^8);
% t = (0:2^25-1)/fs;
% Data = sin(2*pi*440*t);
% Data = uint16(round((Data/2+0.5)*(2^16-1)));
% ExportData(Data, '440 Hz Sine (1.28 kSps)');
%% -----------------------------------------------------------------------------

% 100 Hz when played at 48 kSps
% fs = 100e6/2^8/8;
% t = (0:2^26-1)/fs;
% Data = sin(2*pi*100*t);
% Data = uint8(round((Data/2+0.5)*(2^8-1)));
% ExportData(Data, '100 Hz Sine (48.8 kSps)');
%% -----------------------------------------------------------------------------

% % Song at 48.8 kSps
% [x, x_fs] = audioread('Song.mp3'); x = mean(x, 2);
% x_t = (0:length(x)-1)/x_fs;
% fs = 100e6/2^11; % 48.8 kSps
% t = (0:2^26-1)/fs;
% Data = interp1(x_t, x, t);
% Data(find(isnan(Data))) = 0;
% Data = Data / max(abs(Data));
% Data = uint8(round((Data/2+0.5)*(2^8-1)));
% ExportData(Data, 'Song (48.8 kSps)');
%% -----------------------------------------------------------------------------
