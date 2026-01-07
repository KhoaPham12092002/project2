/* verilator lint_off UNUSED */
module dmem #(parameter W = 32)(
   input  logic         clk_i,
   input  logic         rst_ni,
   input  logic         st_en,   //0:ST, 1:WR
   input  logic         unsigned_en_mem, //0:S, 1:U
   input  logic [W-1:0] addr,
   input  logic [W-1:0] st_data,
//   input logic [3:0] addr[11:8],
   input  logic [1:0]   sel_mod,  //000:B, 001:H, 010:W
   input  logic [W-1:0] io_sw_i,
   
   output logic [W-1:0] io_lcd_o,
   output logic [W-1:0] io_ledg_o,
   output logic [W-1:0] io_ledr_o,
   output logic [W-1:0] io_hex0_o,
   output logic [W-1:0] io_hex1_o,
   output logic [W-1:0] io_hex2_o,
   output logic [W-1:0] io_hex3_o,
   output logic [W-1:0] io_hex4_o,
   output logic [W-1:0] io_hex5_o,
   output logic [W-1:0] io_hex6_o,
   output logic [W-1:0] io_hex7_o,
   output logic [W-1:0] ld_data
);
//parameter W = 32;
logic [3:0][7:0] memory      [2**9 - 1 : 0];
logic [3:0][7:0] input_peri /* [2**6 - 1 : 0]*/;
logic [3:0][7:0] output_peri [2**6 - 1 : 0];
logic [3:0][7:0] dataout_1, dataout_2, dataout_3, temp_ld_data;
logic [3:0] mask;

initial begin
   memory      = '{default: 32'b0};
   input_peri  = 32'b0;
   output_peri = '{default:32'b0};
end

//mux
  always @(*) begin
      case(addr[11:8])
        4'b0000:  temp_ld_data = dataout_1;
	4'b0001:  temp_ld_data = dataout_1;
	4'b0010:  temp_ld_data = dataout_1;
	4'b0011:  temp_ld_data = dataout_1;
	4'b0100:  temp_ld_data = dataout_1;
	4'b0101:  temp_ld_data = dataout_1;
	4'b0110:  temp_ld_data = dataout_1;
        4'b0111:  temp_ld_data = dataout_1;
	4'b1000:  temp_ld_data = dataout_2;
        4'b1001:  temp_ld_data = dataout_3; 
        default:  temp_ld_data = 32'bx;
      endcase
    end

//mask
     always @(*) begin
        case (sel_mod[1:0])
          2'b00: //store load byte
            if(addr[1:0] == 2'b00)
              mask = 4'b0001;
            else if(addr[1:0] == 2'b01)
              mask = 4'b0010;
            else if(addr[1:0] == 2'b10)
              mask = 4'b0100;
            else
              mask = 4'b1000;
          2'b01: //store load half word
            if(addr[1:0] == 2'b00)
              mask = 4'b0011;
            else if(addr[1:0] == 2'b01)
              mask = 4'b0011;
            else if(addr[1:0] == 2'b10)
              mask = 4'b1100;
            else
              mask = 4'b1100;
          2'b10: //store load word
            mask = 4'b1111;
          default: mask = 4'bxxxx;
      endcase
    end

//write operations
assign input_peri = io_sw_i;

//read operation (dataout 3)
    always @(*) begin
        dataout_3 = 32'b0;
        if(!st_en)
          if(sel_mod[1:0] == 2'b00) //byte
            begin
              if((mask & 4'b0001) == 4'b0001)
                dataout_3[0] = input_peri[0];
              if((mask & 4'b0010) == 4'b0010)
                dataout_3[0] = input_peri[1];
              if((mask & 4'b0100) == 4'b0100)
                dataout_3[0] = input_peri[2];
              if((mask & 4'b1000) == 4'b1000)
                dataout_3[0] = input_peri[3];
            end
          else if(sel_mod[1:0] == 2'b01) // half word
            begin
              if((mask & 4'b0011) == 4'b0011)
                dataout_3[1:0] = {input_peri[1], input_peri[0]};
              if((mask & 4'b1100) == 4'b1100)
                dataout_3[1:0] = {input_peri[3], input_peri[2]};
            end
          else dataout_3  = input_peri; //word
        else dataout_3 = 32'b0;
      end

//output periph
    //write operation datain_2
     always @(posedge clk_i) begin
        if((addr[11:8] == 4'b1000) && st_en) begin
            if((mask & 4'b0001) == 4'b0001)
              output_peri[addr[7:2]][0] <= st_data[7:0];
            if((mask & 4'b0010) == 4'b0010)
              output_peri[addr[7:2]][1] <= st_data[15:8];
            if((mask & 4'b0100) == 4'b0100)
              output_peri[addr[7:2]][2] <= st_data[23:16];
            if((mask & 4'b1000) == 4'b1000)
              output_peri[addr[7:2]][3] <= st_data[31:24];
        end
     end
    //read operation dataout_2
  always @(*)
      begin
        dataout_2 = 32'b0;
        if(!st_en)
          if(sel_mod[1:0] == 2'b00) //byte
            begin
              if((mask & 4'b0001) == 4'b0001)
                dataout_2[0] = output_peri[addr[7:2]][0];
              if((mask & 4'b0010) == 4'b0010)
                dataout_2[0] = output_peri[addr[7:2]][1];
              if((mask & 4'b0100) == 4'b0100)
                dataout_2[0] = output_peri[addr[7:2]][2];
              if((mask & 4'b1000) == 4'b1000)
                dataout_2[0] = output_peri[addr[7:2]][3];                                    
            end
          else if(sel_mod[1:0] == 2'b01) // half word
            begin
              if((mask & 4'b0011) == 4'b0011)    
                dataout_2[1:0] = {output_peri[addr[7:2]][1], output_peri[addr[7:2]][0]};
              if((mask & 4'b1100) == 4'b1100)    
                dataout_2[1:0] = {output_peri[addr[7:2]][3], output_peri[addr[7:2]][2]};          
            end
          else dataout_2  = output_peri[addr[7:2]]; //word
        else dataout_2 = 32'b0;
      end

//mem
   assign io_lcd_o  = output_peri [6'h28]; // A0 >> 2 = 28
   assign io_ledg_o = output_peri [6'h24]; // 90 >> 2 = 24
   assign io_ledr_o = output_peri [6'h20]; // 80 >> 2 = 20
   assign io_hex7_o = output_peri [6'h1C]; // 70 >> 2 = 1C
   assign io_hex6_o = output_peri [6'h18]; // 60 >> 2 = 18
   assign io_hex5_o = output_peri [6'h14]; // 50 >> 2 = 14
   assign io_hex4_o = output_peri [6'h10]; // 40 >> 2 = 10
   assign io_hex3_o = output_peri [6'h0C]; // 30 >> 2 = 0C
   assign io_hex2_o = output_peri [6'h08]; // 20 >> 2 = 08
   assign io_hex1_o = output_peri [6'h04]; // 10 >> 2 = 04
   assign io_hex0_o = output_peri [6'h00]; // 00 >> 2 = 00

 //write operation datain_1
      always @(posedge clk_i)
      begin
        if(((addr[11:8] == 4'b0000) || (addr[11:8] == 4'b0001) || (addr[11:8] == 4'b0010) || (addr[11:8] == 4'b0011) || (addr[11:8] == 4'b0100) || (addr[11:8] == 4'b0101) || (addr[11:8] == 4'b0110) || (addr[11:8] == 4'b0111)) && st_en)
          begin
            if((mask & 4'b0001) == 4'b0001)
              memory[addr[10:2]][0] <= st_data[7:0];
            if((mask & 4'b0010) == 4'b0010)
              memory[addr[10:2]][1] <= st_data[15:8];
            if((mask & 4'b0100) == 4'b0100)
              memory[addr[10:2]][2] <= st_data[23:16];
            if((mask & 4'b1000) == 4'b1000)
              memory[addr[10:2]][3] <= st_data[31:24]; 
          end
        end

    //read operation
 always @(*)
      begin
        dataout_1 = 32'b0;
        if(!st_en)
        begin 
          if(sel_mod[1:0] == 2'b00) //byte
            begin
              if((mask & 4'b0001) == 4'b0001)
                dataout_1[0] = memory[addr[10:2]][0];
              if((mask & 4'b0010) == 4'b0010)
                dataout_1[0] = memory[addr[10:2]][1];
              if((mask & 4'b0100) == 4'b0100)
                dataout_1[0] = memory[addr[10:2]][2];
              if((mask & 4'b1000) == 4'b1000)
                dataout_1[0] = memory[addr[10:2]][3];                                    
            end
          else if(sel_mod[1:0] == 2'b01) // half word
            begin
              if((mask & 4'b0011) == 4'b0011)    
                dataout_1[1:0] = {memory[addr[10:2]][1], memory[addr[10:2]][0]};
              if((mask & 4'b1100) == 4'b1100)    
                dataout_1[1:0] = {memory[addr[10:2]][3], memory[addr[10:2]][2]};       
	      end
          else dataout_1  = memory[addr[10:2]]; //word
        end
        else dataout_1 = 32'b0;
	end

//extend
    always @(*)
    begin
      if(!st_en)
        case(sel_mod)
          2'b00: //load byte
	    if(unsigned_en_mem == 0) begin
            ld_data = {(temp_ld_data[0][7] ? 24'hFFFFFF : 24'b0),temp_ld_data[0]};
            end else begin
            ld_data = {(24'b0),temp_ld_data[0]};
	    end
          2'b01: //load half word
	    if(unsigned_en_mem == 0)  begin
            ld_data = {(temp_ld_data[1][7] ? 16'hFFFF : 16'b0), temp_ld_data[1], temp_ld_data[0]};
            end else begin
            ld_data = {(16'b0), temp_ld_data[1], temp_ld_data[0]};
	    end
          default: ld_data = temp_ld_data;
        endcase
      else ld_data = temp_ld_data;
    end  
endmodule
