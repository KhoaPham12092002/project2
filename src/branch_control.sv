/* verilator lint_off UNUSED */
module branch_control (
    input logic [W-1:0] instr,
    input logic    br_eq,
    input logic    br_lt,

    output logic   jump
);
parameter W = 32;
    // parameter format command
    parameter       BRANCH     =   5'b11000;
    parameter       JAL        =   5'b11011;
    parameter       JALR       =   5'b11001;
    // parameter function in format command 
        // BRANCH
    parameter       BEQ                 =   3'b000;
    parameter       BNE                 =   3'b001;
    parameter       BLT                 =   3'b100;
    parameter       BGE                 =   3'b101;
    parameter       BLTU                =   3'b110;
    parameter       BGEU                =   3'b111;

    always_comb begin 
        case(instr[6:2])
            BRANCH: begin                         
                case(instr[14:12])                 
                    BEQ: begin                       
                        if(br_eq)   begin    
							jump         = 1'b1;
                        end else begin             
							jump         = 1'b0;
                        end
                    end                              
                    BNE: begin                       
                        if(!br_eq) begin   
							jump         = 1'b1;
                        end else begin            
							jump         = 1'b0;
                        end
                    end                              
                    BLT: begin                       
                        if(br_lt) begin   
							jump         = 1'b1;
                        end else begin           
							jump         = 1'b0;
                        end 
                    end                              
                    BGE: begin                       
                        if(!br_lt) begin
							jump         = 1'b1;
                        end else begin         
							jump         = 1'b0;
                        end
                    end                             
                    BLTU: begin                      
                        if(br_lt) begin
							jump         = 1'b1;
                        end else begin       
							jump         = 1'b0;
                        end
                    end                             
                    BGEU: begin                     
                        if(!br_lt) begin          
							jump         = 1'b1;
                        end else begin                   
							jump         = 1'b0;
                        end
                    end                             
                    default: begin                  
							jump         = 1'b0;
                    end
                endcase     
            end
            JAL: begin              
							jump         = 1'b1;
            end
            JALR: begin             
							jump         = 1'b1;
            end 
            default: begin
							jump         = 1'b1;
            end
        endcase 
    end
endmodule

