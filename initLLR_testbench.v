`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:47:47 02/29/2016
// Design Name:   initLLR
// Module Name:   E:/XILINX/BMST_NBLDPC/initLLR_testbench.v
// Project Name:  BMST_NBLDPC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: initLLR
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module initLLR_testbench;

	// Inputs
	reg wrclk;
	reg reset;
	reg start_read;
	reg input_en;
	reg frame_lock;
	reg [10:0] data_in;

	// Outputs
	wire [10:0] data_Lch;
	wire [5:0] wr_addr_Lch;
	wire wr_addr_high_Lch;
	wire wren_Lch_H0;
	wire wren_Lch_H1;
	wire wren_Lch_H2;
	wire wren_Lch_H3;
	wire wren_Lch_H4;
	wire wren_Lch_H5;
	wire wren_Lch_H6;
	wire wren_Lch_H7;
	wire wren_Lch_H8;
	wire wren_Lch_H9;
	wire data_ready;

	// Instantiate the Unit Under Test (UUT)
	initLLR uut (
		.wrclk(wrclk), 
		.reset(reset), 
		.start_read(start_read), 
		.input_en(input_en), 
		.frame_lock(frame_lock), 
		.data_in(data_in), 
		.data_Lch(data_Lch), 
		.wr_addr_Lch(wr_addr_Lch), 
		.wr_addr_high_Lch(wr_addr_high_Lch), 
		.wren_Lch_H0(wren_Lch_H0), 
		.wren_Lch_H1(wren_Lch_H1), 
		.wren_Lch_H2(wren_Lch_H2), 
		.wren_Lch_H3(wren_Lch_H3), 
		.wren_Lch_H4(wren_Lch_H4), 
		.wren_Lch_H5(wren_Lch_H5), 
		.wren_Lch_H6(wren_Lch_H6), 
		.wren_Lch_H7(wren_Lch_H7), 
		.wren_Lch_H8(wren_Lch_H8), 
		.wren_Lch_H9(wren_Lch_H9), 
		.data_ready(data_ready)
	);
	reg[6:0]cnt;
	initial begin
		// Initialize Inputs
		wrclk = 0;
		reset = 1;
		#10 reset = 0;
		start_read = 0;
		input_en = 0;
		frame_lock = 0;
		data_in = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 1;
      start_read = 1;  
	  cnt = 0;
		// Add stimulus here

	end
   always #10 wrclk = ~wrclk; 

	always@(posedge wrclk)
	begin
		if(reset == 1 && start_read == 1)
		begin
		  if(data_ready == 0)
		   begin
			   frame_lock <= 1;
			   if(frame_lock)
			   begin
					if(cnt>200 || cnt < 100)
						input_en <= 1;
					else
						input_en <= 0;
					cnt <= cnt + 1;
				   if(input_en)
					begin
						data_in <= data_in + 1'b1;
					end
			   end
			 end
			 else
			 begin
			   frame_lock <= 0;
			   input_en <= 0;
			 end 
		end
	end
endmodule

