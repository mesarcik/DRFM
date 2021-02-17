function [y,Q] = my_hilbert(y)


	y_f =  (fft(y));
	Q   =  ifft(([y_f(1:length(y)/2),-y_f(1+length(y)/2:length(y)) ]));
	% figure(66);
	% subplot(2,1,1);
	% plot(real(fft(I)));
	% title('I');
	% subplot(2,1,2);
	% plot(real(fft(Q)));
	% title('Q');
end


