`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:59 02/29/2016 
// Design Name: 
// Module Name:    NB_iter_ctrl 
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
module NB_iter_ctrl(   clk,
					reset,
					data_ready,
					max_iter_num,
					
					finish_H0,
					finish_H1,
					finish_H2,
					finish_H3,
					finish_H4,
					finish_H5,
					finish_H6,
					finish_H7,
					finish_H8,
					finish_H9,

					finish_P0,
					finish_P1,
					finish_P2,
					finish_P3,
					finish_P4,

					rd_addr_high_Lch,
					
					value_start,
					check_start,
					first_iter_flag,
					
					iter_num,
					Mux_result,
					
					output_ready
						 );

input clk,
	reset, 
	data_ready,

	finish_H0,
	finish_H1,
	finish_H2,
	finish_H3,
	finish_H4,
	finish_H5,
	finish_H6,
	finish_H7,
	finish_H8,
	finish_H9,

	finish_P0,
	finish_P1,
	finish_P2,
	finish_P3,
	finish_P4;
	
input [6:0] max_iter_num;	  

output  value_start,
		first_iter_flag,
		rd_addr_high_Lch,
		check_start;
	   

output [6:0] iter_num;
output Mux_result;
output output_ready;

reg value_start,
    first_iter_flag,
	rd_addr_high_Lch,
    check_start;
	
reg iter_finished;
reg Mux_result;	
reg output_ready;
reg [6:0] iter_num;


reg [9:0] finish_value_update; 	 
reg [4:0] finish_check_update;

reg [6:0] max_iter;		 
reg [1:0] iter_state;
reg [1:0] data_ready_queue;			
parameter idle = 2'b00, value_node_update = 2'b01, check_node_update = 2'b11;



always @(posedge clk or negedge reset)
begin
	if(!reset)
	begin
		data_ready_queue <= 2'b00;
	end
	else
	begin
		if(data_ready == 1'b1)
		begin
			if(iter_finished == 1'b0)
			begin
				data_ready_queue[0] <= 1'b1;
				data_ready_queue[1] <= data_ready_queue[0];
			end
		end
		else if(iter_finished == 1'b1)
		begin
			if(data_ready_queue[1] == 1'b1)
			begin
				data_ready_queue[1] <= 1'b0;
			end
			else if(data_ready_queue[0] == 1'b1)
			begin
				data_ready_queue[0] <= 1'b0;
			end
		end
	end
end

/*-------------------------------------------------------------*/	
				   
always @(posedge clk or negedge reset)
    begin
	    if (!reset)
		begin
			value_start <= 1'b0; 			  
			check_start <= 1'b0;	
			first_iter_flag <= 1'b0;
			iter_finished <= 1'b0;
			iter_num <= 7'b0;		
			rd_addr_high_Lch <= 1'b1;
			max_iter <= max_iter_num;
			output_ready <= 1'b0;
			iter_state <= idle;
		end
		
		else
		    case(iter_state)
			    idle:
				begin	
				
					finish_value_update <= 10'd0;
					finish_check_update <= 5'd0;
					
					if (iter_finished == 1'b0 && data_ready_queue != 2'b00)
					begin
						value_start <= 1'b1; 
						check_start <= 1'b0;
						first_iter_flag <= 1'b1;
						iter_num <= 7'b0;
						output_ready <= 1'b0;
						Mux_result <= 1'b1;//value node first
						rd_addr_high_Lch <= ~rd_addr_high_Lch;
													
						iter_state <= value_node_update;  
					end
					else
					begin
						value_start <= 1'b0;							
						check_start <= 1'b0;		
						first_iter_flag <= 1'b0;
						iter_num <= 7'b0;
						iter_finished <= 1'b0;
						output_ready <= 1'b0;
						Mux_result <= 1'b0;
						iter_state <= idle;
					end	
				end
				
				value_node_update:
				begin
					finish_check_update <= 5'd0;
					value_start <= 1'b0;
					
					if (finish_H0)
					  begin
						finish_value_update[0] <= 1'b1;
					  end
					if (finish_H1)
					  begin
						finish_value_update[1] <= 1'b1;
					  end
					if (finish_H2)
					  begin
						finish_value_update[2] <= 1'b1;
					  end
					if (finish_H3)
					  begin
						finish_value_update[3] <= 1'b1;
					  end
					if (finish_H4)
					  begin
						finish_value_update[4] <= 1'b1;
					  end
					if (finish_H5)
					  begin
						finish_value_update[5] <= 1'b1;
					  end
					if (finish_H6)
					  begin
						finish_value_update[6] <= 1'b1;
					  end
					if (finish_H7)
					  begin
						finish_value_update[7] <= 1'b1;
					  end
					if (finish_H8)
					  begin
						finish_value_update[8] <= 1'b1;
					  end
					if (finish_H9)
					begin
						finish_value_update[9] <= 1'b1;
					end
					  
					  
					if (finish_value_update == 10'b11_1111_1111)
					begin
						Mux_result <= 1'b0;//for check node
					   
						if(iter_num == max_iter)  
						begin
							iter_finished <= 1'b1;	
							output_ready <= 1'b1;
							iter_state <= idle;
						end	
						else
						begin
							iter_num <= iter_num + 1'b1;
							check_start <= 1'b1;
							Mux_result <= 1'b0;							
							iter_state <= check_node_update;	
						end										
					 end	
					else
					begin
						iter_state <= value_node_update;
					end	
				end
				
				check_node_update:       
				begin
					finish_value_update <= 10'd0;
					check_start <= 1'b0;
					
					if (finish_P0)
					  begin
						finish_value_update[0] <= 1'b1;
					  end
					if (finish_P1)
					  begin
						finish_value_update[1] <= 1'b1;
					  end
					if (finish_P2)
					  begin
						finish_value_update[2] <= 1'b1;
					  end
					if (finish_P3)
					  begin
						finish_value_update[3] <= 1'b1;
					  end
					if (finish_P4)
					  begin
						finish_value_update[4] <= 1'b1;
					  end 
					
					if (finish_value_update == 5'b11111)
					begin
						value_start <= 1'b1;
						Mux_result <= 1'b1;
						first_iter_flag <= 1'b0;
						iter_state <= value_node_update;
					end		 
					else
					begin
						iter_state <= check_node_update;	
					end
				end
				
				default:iter_state <= idle;
			endcase
	end

endmodule 