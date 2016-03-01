`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:37:59 02/29/2016 
// Design Name: 
// Module Name:    initLLR 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module initLLR(wrclk,
                      reset,
					  start_read,
					  input_en,
					  frame_lock,
					  data_in,
					  
					  data_Lch,
					  wr_addr_Lch,
					  wr_addr_high_Lch,

					  wren_Lch_H0,
					  wren_Lch_H1,
					  wren_Lch_H2,
					  wren_Lch_H3,
					  wren_Lch_H4,
					  wren_Lch_H5,
					  wren_Lch_H6,
					  wren_Lch_H7,
					  wren_Lch_H8,
					  wren_Lch_H9,
					  
					 // data_full,//提前两个时钟通知前一级停止传输。
					  data_ready
					  );
input wrclk,
      reset,
      start_read,
	  input_en,  
	  frame_lock; 

parameter 	DATAWIDTH = 11 - 1,
			ADDR_WIDTH = 6 - 1,
            MAX_ADD = (1 << ADDR_WIDTH) - 1;
			
input [DATAWIDTH:0] data_in;	  

output [DATAWIDTH:0] data_Lch;
output [ADDR_WIDTH:0] wr_addr_Lch;
output wr_addr_high_Lch;
output data_ready;
output wren_Lch_H0, wren_Lch_H1, wren_Lch_H2, 
	   wren_Lch_H3, wren_Lch_H4, wren_Lch_H5,
	   wren_Lch_H6, wren_Lch_H7, wren_Lch_H8,
	   wren_Lch_H9;		

reg [DATAWIDTH:0] data_Lch;
reg [ADDR_WIDTH:0] wr_addr_Lch;
reg wr_addr_high_Lch;
reg data_ready;
reg wren_Lch_H0, wren_Lch_H1, wren_Lch_H2, 
	   wren_Lch_H3, wren_Lch_H4, wren_Lch_H5,
	   wren_Lch_H6, wren_Lch_H7, wren_Lch_H8,
	   wren_Lch_H9;	
	   
reg [ADDR_WIDTH:0] counter;

reg [9:0] wr_en_state;
reg [2:0] read_state;
parameter  read_idle = 3'b000, 
		   initial_Lch = 3'b001,
		   /*
		   initial_Lch_H0 = 4'b0001, initial_Lch_H1 =  4'b0010,
		   initial_Lch_H2 = 4'b0011, initial_Lch_H3 = 4'b0100, initial_Lch_H4 = 4'b0101,
		   initial_Lch_H5 = 4'b0110, initial_Lch_H6 = 4'b0111, initial_Lch_H7 = 4'b1000,
		   initial_Lch_H8 = 4'b1001, initial_Lch_H9 = 4'b1010, 
		   */
		   frame_unlock = 3'b011;			

always @(posedge wrclk or negedge reset)
   if(!reset) 
   begin
		data_ready <= 1'b0;		
		wr_addr_high_Lch <= 1'b1;//乒乓操作写地址高位  		
		wren_Lch_H0 <= 1'b0;
		wren_Lch_H1 <= 1'b0;
		wren_Lch_H2 <= 1'b0;
		wren_Lch_H3 <= 1'b0;
		wren_Lch_H4 <= 1'b0;
		wren_Lch_H5 <= 1'b0;
		wren_Lch_H6 <= 1'b0;
		wren_Lch_H7 <= 1'b0;
		wren_Lch_H8 <= 1'b0;
		wren_Lch_H9 <= 1'b0;
		
		wr_addr_Lch <= 0;
		wr_en_state <= 0;
	    read_state <= read_idle;
	end		
   else
      case(read_state)
			read_idle : 
			begin
			
				wr_addr_Lch <= 0;
				{wren_Lch_H9,
				wren_Lch_H8,
				wren_Lch_H7,
				wren_Lch_H6,
				wren_Lch_H5,
				wren_Lch_H4,
				wren_Lch_H3,
				wren_Lch_H2,
				wren_Lch_H1,
				wren_Lch_H0
				} <= 10'd0;
				
				counter <= 0;
				data_ready <= 1'b0;
				if(start_read) 
				begin
					wr_addr_high_Lch <= ~wr_addr_high_Lch;
					read_state <= initial_Lch;
					wr_en_state <= 10'd1;
				end
				else 
				begin
					wr_addr_Lch <= 0;
					read_state <= read_idle;
				end
				
            end			 
        
			initial_Lch : 
			begin
		      if(frame_lock) 
			  begin
			      if(input_en) 
				  begin
						data_Lch <= data_in;
						
						{wren_Lch_H9,
						wren_Lch_H8,
						wren_Lch_H7,
						wren_Lch_H6,
						wren_Lch_H5,
						wren_Lch_H4,
						wren_Lch_H3,
						wren_Lch_H2,
						wren_Lch_H1,
						wren_Lch_H0
						} <= wr_en_state;
						
						wr_addr_Lch <= counter;
					 
						if(counter == 6'b11_1111) 
						begin
							counter <= 0;
							wr_en_state <= wr_en_state << 1;
							if(wr_en_state[9] == 1'b0)
							begin							
								read_state <= initial_Lch;
							end
							else
							begin
								read_state <= read_idle;
								data_ready <= 1'b1;
							end
						end
						else
						begin
							counter <= counter + 1'b1;
							read_state <= initial_Lch;
						end
				   end
				   else 
				   begin
					   {wren_Lch_H9,
						wren_Lch_H8,
						wren_Lch_H7,
						wren_Lch_H6,
						wren_Lch_H5,
						wren_Lch_H4,
						wren_Lch_H3,
						wren_Lch_H2,
						wren_Lch_H1,
						wren_Lch_H0
						} <= 10'd0;
					   read_state <= initial_Lch;
				   end
            end        			   
            else 
			begin
			    {wren_Lch_H9,
				wren_Lch_H8,
				wren_Lch_H7,
				wren_Lch_H6,
				wren_Lch_H5,
				wren_Lch_H4,
				wren_Lch_H3,
				wren_Lch_H2,
				wren_Lch_H1,
				wren_Lch_H0
				} <= 10'd0;
				read_state <= frame_unlock;
            end				 
		   end	
		   
			frame_unlock : 
			begin	
				wr_addr_Lch <= 0;
				{wren_Lch_H9,
				wren_Lch_H8,
				wren_Lch_H7,
				wren_Lch_H6,
				wren_Lch_H5,
				wren_Lch_H4,
				wren_Lch_H3,
				wren_Lch_H2,
				wren_Lch_H1,
				wren_Lch_H0
				} <= 10'd0;	

					
				if(start_read) 
				begin
					counter <= 0;
					read_state <= initial_Lch;
				end
				else 
				begin 
					read_state <= frame_unlock;
				end					 
			end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
			default : 
			begin
				read_state <= read_idle;
			end
		endcase
   
endmodule
				 