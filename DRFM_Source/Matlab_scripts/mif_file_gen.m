f = 100;
N = 2^12;
t = 0:(N-1);


y = sin(2*pi*f*(t./N));
% y = uint8(round((y/2+0.5)*(2^8-1)));
y = uint16(round((y/2+0.5)*(2^16-1)));

% I_Data = uint8(round((I_Data/2+0.5)*(2^8-1)));


figure(1); plot(y);

width = 16;


mif_file = fopen('sin.mif','wb');
fprintf(mif_file, 'Depth= %d ;\n',N);
fprintf(mif_file, 'Width = %d ;\n' ,width);
fprintf(mif_file, 'ADDRESS_RADIX = HEX; \n');
fprintf(mif_file, 'DATA_RADIX = BIN;\n');
fprintf(mif_file, 'CONTENT \nBEGIN\n\n');

count = 0;
for j=1:N
	b = transpose(dec2bin(y(j),16));
	h =dec2hex(count,3);
	fprintf(mif_file, '%s : %s; \n',h,b);
	count = count +1;
end	

fprintf(mif_file, '\n');

fprintf(mif_file, 'END;');

fclose(mif_file);