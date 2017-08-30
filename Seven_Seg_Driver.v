module Seven_Seg_Driver (
	input [3:0] 	state,

	output [7:0]		SS0,
	output [7:0]		SS1,
	output [7:0]		SS2,
	output [7:0]		SS3,
	output [7:0]		SS4,
	output [7:0]		SS5

);

	always @ (*) begin
		//One hot coded
		if (state == 4'b_0000) begin //Waiting 
			SS5 <= ~8'b_1000_0000; //.
			SS4 <= ~8'b_1000_0000; //.
			SS3 <= ~8'b_1000_0000; //.
			SS2 <= ~8'b_1000_0000; //.
			SS1 <= ~8'b_1000_0000; //.
			SS0 <= ~8'b_1000_0000; //.
		end


		else if (state == 4'b_0001) begin //delay. 
			SS5 <= ~8'b_0101_1110; //d
			SS4 <= ~8'b_0111_1001; //E
			SS3 <= ~8'b_0011_1000; //L
			SS2 <= ~8'b_0111_0111; //A
			SS1 <= ~8'b_0110_1110; //y
			SS0 <= ~8'b_1000_0000;//.
		end

		else if (state == 4'b_0010) begin //SCALE
			SS5 <= ~8'b_0110_1101; //S
			SS4 <= ~8'b_0011_1001; //C
			SS3 <= ~8'b_0111_0111; //A
			SS2 <= ~8'b_0011_1000; //L
			SS1 <= ~8'b_0111_1001; //E
			SS0 <= ~8'b_1000_0000;// . 
		end
		else if (state == 4'b_0100) begin //lOAD DATA
			SS5 <= ~8'b_0011_1000; //L
			SS4 <= ~8'b_0011_1111; //O
			SS3 <= ~8'b_0111_0111; //A
			SS2 <= ~8'b_0101_1110; //d
			SS1 <= ~8'b_0111_0111; //A
			SS0 <= ~8'b_0111_1000;// T
		end
		else if (state == 4'b_1000) begin //Doppler 
			SS5 <= ~8'b_0101_1110; //d
			SS4 <= ~8'b_0011_1111; //0
			SS3 <= ~8'b_0111_0011; //P
			SS2 <= ~8'b_0011_1000; //L
			SS1 <= ~8'b_0111_1001; //E
			SS0 <= ~8'b_0011_0001;// r 
		end
		else if (state == 4'b_0011) begin //Delay+scale
			SS5 <= ~8'b_0101_1110; //d
			SS4 <= ~8'b_0111_1001; //E
			SS3 <= ~8'b_0100_0000; //-
			SS2 <= ~8'b_0110_1101; //S
			SS1 <= ~8'b_0011_1001; //C
			SS0 <= ~8'b_0111_0111; //A 
		end
		else if (state == 4'b_1001) begin //Delay+doppler
			SS5 <= ~8'b_0101_1110; //d
			SS4 <= ~8'b_0111_1001; //E
			SS3 <= ~8'b_0100_0000; //-
			SS2 <= ~8'b_0101_1110; //d
			SS1 <= ~8'b_0011_1111; //0
			SS0 <= ~8'b_0111_0011; //P
		end
		else if (state == 4'b_1010) begin //scale+doppler
			SS5 <= ~8'b_0110_1101; //S
			SS4 <= ~8'b_0011_1001; //C
			SS3 <= ~8'b_0100_0000; //-
			SS2 <= ~8'b_0101_1110; //d
			SS1 <= ~8'b_0011_1111; //0
			SS0 <= ~8'b_0111_0011; //P
		end
		else if (state == 4'b_1011) begin //scale+doppler+delay
			SS5 <= ~8'b_0110_1101; //S
			SS4 <= ~8'b_0011_1001; //C
			SS3 <= ~8'b_0101_1110; //d
			SS2 <= ~8'b_0011_1111; //0
			SS1 <= ~8'b_0101_1110; //d
			SS0 <= ~8'b_0111_1001; //E
		end


		else begin //error 
			SS5 <= ~8'b_0111_1001; //E
			SS4 <= ~8'b_0011_0001; //R
			SS3 <= ~8'b_0011_0001; //R
			SS2 <= ~8'b_0011_1111; //0
			SS1 <= ~8'b_0011_0001; //R
			SS0 <= ~8'b_1000_0000;// . 
		end

		// else if 

	end



endmodule // Seven_Seg_Driver