module decoder(
    input logic [1:0] Op,               
    input logic [5:0] Funct,           
    input logic [3:0] Rd,              
    output logic [1:0] FlagW,
    output logic PCS,
    output logic RegW, MemW,
    output logic MemtoReg, ALUSrc,
    output logic [1:0] ImmSrc, RegSrc,
    output logic [2:0] ALUControl
);

  // Señales internas
  logic [9:0] controls;
  logic Branch, ALUOp;
  
  
  always_comb
    casex (Op)
     
      2'b00: if (Funct[5]) 
                controls = 10'b0000101001;
             else 
                controls = 10'b0000001001;
      

      2'b01: if (Funct[0]) 
                controls = 10'b0001111000; // LDR
             else 
                controls = 10'b1001110100; // STR
      

      2'b10: controls = 10'b0110100010; // Branch
      
      // Caso: No implementado
      default: controls = 10'bx;        // Indefinido para operaciones no soportadas
    endcase


  assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;
  
  // Decodificador de la ALU
  always_comb
    if (ALUOp) begin
        case (Funct[4:1])
          4'b0100: ALUControl = 3'b000; // ADD
          4'b0010: ALUControl = 3'b001; // SUB
          4'b0000: ALUControl = 3'b010; // AND
          4'b1100: ALUControl = 3'b011; // ORR
          4'b1101: ALUControl = 3'b100; // Shift
          4'b1001: ALUControl = 3'b101; // MUL
          4'b1011: ALUControl = 3'b110; // MOV
          default: ALUControl = 3'bx;   // Operación no soportada
        endcase
        
       
        FlagW[1] = Funct[0];
        FlagW[0] = Funct[0] &
                   (ALUControl == 3'b000 | ALUControl == 3'b001);
    end else begin
        ALUControl = 3'b000;
        FlagW = 2'b00;
    end
  
  // PC
  assign PCS = ((Rd == 4'b1111) & RegW) | Branch;  
  
endmodule
