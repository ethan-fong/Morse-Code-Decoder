module part3(ClockIn, Resetn, Start, Letter, DotDashOut);
	input ClockIn;
	input Resetn;
	input Start;
	input [2:0]Letter;
	output DotDashOut;

	wire [11:0]encoding;
	wire Enablew;
	wire w1;
	assign w1 = Enablew|Start;
	
	mux8to1 mux(Letter[2:0], encoding[11:0]);
	
	RateDivider ratediv (.d(28'b0000000000000000000011111001),.ParLoad(w1),.Clearb(Resetn),.Enable(Enablew),.clock(ClockIn)); //28'b0001011111010111100000111111 25 mil //499 28'b0000000000000000000011111001
	
	shift_reg shifter(.clock(ClockIn), .reset_n(Resetn), .ParallelLoadn(Start), .Enable(Enablew), .Data_IN(encoding[11:0]), .Q(DotDashOut));
	
endmodule



module shift_reg(clock, reset_n, ParallelLoadn, Enable, Data_IN, Q);
	input clock;
	input reset_n;
	input ParallelLoadn;
	input [11:0]Data_IN;
	input Enable;
	output reg Q;
	reg [11:0]bits;
	always@(posedge clock or negedge reset_n) //active low asynch
		if (reset_n==1'b0)
		begin
			bits <= 12'b000000000000;
			Q<=1'b0;
		end
		else if (ParallelLoadn==1'b1)
		begin
			bits<=Data_IN;
			Q<=1'b1;
		end
		else if (Enable==1'b1)
		begin
			Q<=bits[11];
			bits <= {bits[10:0],bits[11]};
		end
endmodule
		
module RateDivider(d,ParLoad,Clearb,Enable,clock);
	
	output Enable;
	input [27:0]d;// declare d
	input Clearb, clock, ParLoad;
	reg[27:0] q;// declare q
	
	always@(posedge clock, negedge Clearb)// triggered every time clock rises
	begin
		if(Clearb==1'b0)// when Clearb is 0
			q <= 28'b0000000000000000000000000000;// q is set to 0
		else if(ParLoad  ==  1'b1)// Check if parallel load
			q <= d;// load d
		else  // increment q only when Enable is 1
			q <= q - 1;// decrease q
	end 
	assign Enable=(q[27:0]==28'b0000000000000000000000000000)?1:0;
endmodule
	

module mux8to1(Letter, encoding);
	input [2:0]Letter;
	output reg [11:0]encoding;
	always@(*)
	begin
		case(Letter[2:0])
			3'b000: encoding[11:0]  = 12'b101110000000;
			3'b001: encoding[11:0]  = 12'b111010101000;
			3'b010: encoding[11:0]  = 12'b111010111010;
			3'b011: encoding[11:0]  = 12'b111010100000;
			3'b100: encoding[11:0]  = 12'b100000000000;
			3'b101: encoding[11:0]  = 12'b101011101000;
			3'b110: encoding[11:0]  = 12'b111011101000;
			3'b111: encoding[11:0]  = 12'b101010100000;
			default encoding[11:0]  = 12'b000000000000;
		endcase
	end
endmodule 