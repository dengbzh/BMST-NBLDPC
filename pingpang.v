`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:01:36 03/31/2016 
// Design Name: 
// Module Name:    infDataBuf 
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
module infDataBuf(
	wclk,
	rclk,
	rst,
	en,
	infBit,
	validIn,
	readReq,
	dataOut,
	empty,
	full,
	ready
);

input wclk,rclk,rst,en,infBit,readReq,validIn;

output reg empty,full,ready;
output reg[5:0] dataOut;

reg R0Full,R1Full;
reg R0Read,R1Read;

reg wen;
reg high;
reg [5:0]wAddr;
reg [2:0]wstate=idle;

//reg writeR0Finished,writeR1Finished;
reg [5:0]GFData;
reg [5:0]GFDataIndex;
parameter idle=3'd0,writeReady=3'd1,writeRam=3'd2;
always@(posedge wclk or negedge rst)
begin
	if(!rst)
	begin
		wen <= 0;
		wAddr <= 0;
		wstate <= idle;
		high <= 1;
		R0Full <= 0;
		R1Full <= 0;
		GFData <= 0;
		GFDataIndex <= 6'd1;
		full <=0;
		ready <= 0;
	end
	else if(en)
	begin
		case(wstate)
		idle:
		begin
			wen <= 0;
			wAddr <= 0;
			high <= ~high;
			GFData <= 0;
			wstate <= writeReady;
			GFDataIndex <= 6'd1;
			ready <= 1;
		end
		
		writeReady:
		begin
			if(R0Read)
			begin
				R0Full <= 1'b0;
				full <= 1'b0;
			end
			if(R1Read)
			begin
				R1Full <= 1'b0;
				full <= 1'b0;
			end
			
			if(((high & (~R1Full)) == 1'b1) || ((~(high|R0Full)) == 1'b1))
			begin
				if(validIn)
				begin
					GFDataIndex[5:1] <= GFDataIndex[4:0];// << 1'b1;
					GFDataIndex[0] <= GFDataIndex[5];
					
					GFData[0] <= infBit;
					GFData[5:1] <= GFData[4:0];
					if(GFDataIndex[5] == 1'b1)
					begin
						wen <= 1'b1;
						wstate <= writeRam;
					end
					else
						wen <= 1'b0;
				end
				else
					wen <= 1'b0;
			end
		end
		
		writeRam:
		begin
			if(R0Read)
			begin
				R0Full <= 1'b0;
				full <= 1'b0;
			end
			if(R1Read)
			begin
				R1Full <= 1'b0;
				full <= 1'b0;
			end
			if(validIn)
			begin
				GFDataIndex[5:1] <= GFDataIndex[4:0];// << 1'b1;
				GFDataIndex[0] <= GFDataIndex[5];
				
				GFData[0] <= infBit;
				GFData[5:1] <= GFData[4:0];
				
				if(GFDataIndex[5] == 1'b1)
				begin
					wen <= 1'b1;
					if(wAddr == 6'd48)
					begin
						ready <= 0;
						wstate <= idle;
						if(high)
						begin
							R1Full <= 1'b1;
							if(R0Full == 1'b1)
								full <= 1'b1;
						end
						else
						begin
							R0Full <= 1'b1;
							if(R1Full == 1'b1)
								full <= 1'b1;
						end
					end
					wAddr <= wAddr + 1'b1;
				end
				else
					wen <= 1'b0;
			end
			else
				wen <= 1'b0;
		end
		
		default:
			wstate <= idle;
			
		endcase
	end
end

wire[5:0] dataOut0,dataOut1;
reg[5:0] rAddr;
reg[2:0] rstate;
//reg[9:0] readIndex;
reg rhigh;
parameter readReady=3'd1,reading=3'd2;
always@(posedge rclk or negedge rst)
begin
	if(!rst)
	begin
		R0Read	<=	0;
		R1Read	<=	0;
		rAddr <= 0;
		empty <= 1'b1;
		rstate <= idle;
		//readIndex <= 10'd1;
		rhigh <= 1'b1;
		dataOut <= 0;
	end
	else if(en)
	begin
		case(rstate)
		idle:
		begin
			rhigh <= ~rhigh;
			//readIndex <= 10'd1;
			rAddr <= 0;
			rstate <= readReady;
		end
		
		readReady:
		begin
			if(rhigh&R1Full)
				R0Read <= 0;
			if((~rhigh)&R0Full)
				R1Read <= 0;
			if((R1Full|R0Full) == 1'b0)
				empty <= 1'b1;
			else
				empty <= 1'b0;
				
			if(rhigh&R1Full | (~rhigh)&R0Full)
			begin
				if(readReq)//4 clock delay
					rstate <= reading;
			end
		end
		
		reading:
		begin
			if(readReq)
			begin
				rAddr <= rAddr + 1'b1;
				if(rAddr == 6'd51)
				begin
					rstate <= idle;
					if(rhigh)
					begin
						R1Read <= 1'b1;
						if(R0Full == 1'b0)
							empty <= 1'b1;
					end
					else
					begin
						R0Read <= 1'b1;
						if(R1Full == 1'b0)
							empty <= 1'b1;
					end
				end
			end
			dataOut <= (rhigh == 1'b1 ? dataOut1 : dataOut0); 
		end
		default:
			rstate <= idle;
		endcase
	end
end

infBuf ram0(
  .clka(wclk),
  .wea(wen&(~high)),
  .addra(wAddr),
  .dina(GFData),
  .clkb(rclk),
  .addrb(rAddr),
  .doutb(dataOut0)
);
infBuf ram1(
  .clka(wclk),
  .wea(wen&high),
  .addra(wAddr),
  .dina(GFData),
  .clkb(rclk),
  .addrb(rAddr),
  .doutb(dataOut1)
);
endmodule