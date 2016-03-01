`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:50:55 03/01/2016
// Design Name:   NB_iter_ctrl
// Module Name:   E:/XILINX/BMST_NBLDPC/NB_iter_ctrl_testbench.v
// Project Name:  BMST_NBLDPC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: NB_iter_ctrl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module NB_iter_ctrl_testbench;

	// Inputs
	reg clk;
	reg reset;
	reg data_ready;
	reg [6:0] max_iter_num;
	reg finish_H0;
	reg finish_H1;
	reg finish_H2;
	reg finish_H3;
	reg finish_H4;
	reg finish_H5;
	reg finish_H6;
	reg finish_H7;
	reg finish_H8;
	reg finish_H9;
	reg finish_P0;
	reg finish_P1;
	reg finish_P2;
	reg finish_P3;
	reg finish_P4;

	// Outputs
	wire rd_addr_high_Lch;
	wire value_start;
	wire check_start;
	wire first_iter_flag;
	wire [6:0] iter_num;
	wire Mux_result;
	wire output_ready;

	// Instantiate the Unit Under Test (UUT)
	NB_iter_ctrl uut (
		.clk(clk), 
		.reset(reset), 
		.data_ready(data_ready), 
		.max_iter_num(max_iter_num), 
		.finish_H0(finish_H0), 
		.finish_H1(finish_H1), 
		.finish_H2(finish_H2), 
		.finish_H3(finish_H3), 
		.finish_H4(finish_H4), 
		.finish_H5(finish_H5), 
		.finish_H6(finish_H6), 
		.finish_H7(finish_H7), 
		.finish_H8(finish_H8), 
		.finish_H9(finish_H9), 
		.finish_P0(finish_P0), 
		.finish_P1(finish_P1), 
		.finish_P2(finish_P2), 
		.finish_P3(finish_P3), 
		.finish_P4(finish_P4), 
		.rd_addr_high_Lch(rd_addr_high_Lch), 
		.value_start(value_start), 
		.check_start(check_start), 
		.first_iter_flag(first_iter_flag), 
		.iter_num(iter_num), 
		.Mux_result(Mux_result), 
		.output_ready(output_ready)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		data_ready = 0;
		max_iter_num = 7'd20;
		finish_H0 = 0;
		finish_H1 = 0;
		finish_H2 = 0;
		finish_H3 = 0;
		finish_H4 = 0;
		finish_H5 = 0;
		finish_H6 = 0;
		finish_H7 = 0;
		finish_H8 = 0;
		finish_H9 = 0;
		finish_P0 = 0;
		finish_P1 = 0;
		finish_P2 = 0;
		finish_P3 = 0;
		finish_P4 = 0;
		#10 reset = 0;
		#10 reset = 1;
		
		// Wait 100 ns for global reset to finish
		#100;
      data_ready = 1;  
		// Add stimulus here

	end
   
	reg[9:0] cnt = 0;
	reg[1:0] state = 0;
	always#10 clk = ~clk;
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			if(data_ready == 1)
			begin
				case(state)
				2'd0:
				begin
					if(value_start)
						state <= 2'd2;
					if(check_start)
						state <= 2'd1;
					cnt <= 0;	
				end
				
				2'd1:
				begin
					if(value_start)
					begin
						state <= 2'd2;
						cnt <= 0;
				   end
					else
					begin
						if(cnt == 100)
						begin
							{finish_P0,finish_P1,finish_P2,finish_P3,finish_P4} <= 5'b1_1111;
							cnt <= cnt + 1;
						end
						else if(cnt == 101)
						begin
							{finish_P0,finish_P1,finish_P2,finish_P3,finish_P4} <=  0;
						end
						else
							cnt <= cnt + 1;
					
					end
				end
				
				2'd2:
				begin
					if(check_start)
					begin
						state <= 2'd1;
						cnt <= 0;
				   end
					else
					begin
						if(cnt == 100)
						begin
							{finish_H0,finish_H1,finish_H2,finish_H3,finish_H4,finish_H5,finish_H6,finish_H7,finish_H8,finish_H9} <= 10'b11_1111_1111;
							cnt <= cnt + 1;
						end
						else if(cnt == 101)
						begin
							{finish_H0,finish_H1,finish_H2,finish_H3,finish_H4,finish_H5,finish_H6,finish_H7,finish_H8,finish_H9} <= 0;
						end
						else
							cnt <= cnt + 1;
					end
				end
				endcase
			end
			
		end
	end
		
endmodule

