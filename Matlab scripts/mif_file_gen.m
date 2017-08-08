Fs = 512;
t = 2*pi/Fs:2*pi/Fs:10*pi;


y = (square(2*pi*10*t));
for i=1:length(y)
	if y(i) < 0
		y(i) = 0;
	end
end

depth = 512;
width = 16;


mif_file = fopen('sin.mif','wt');
fprintf(mif_file, 'Depth= %d ;\n',depth);
fprintf(mif_file, 'Width = %d ;\n' ,width);
fprintf(mif_file, 'ADDRESS_RADIX = HEX; \n');
fprintf(mif_file, 'DATA_RADIX = BIN;\n');
fprintf(mif_file, 'CONTENT \nBEGIN\n\n');

count = 0;
for j=1:16:length(y) -16
	b = transpose(dec2bin(y(j:j+15)));
	h =dec2hex(count,2);
	fprintf(mif_file, '%s : %s; \n',h,b);
	count = count +1;
end	

fprintf(mif_file, '\n');

fprintf(mif_file, 'END;');

fclose(mif_file);