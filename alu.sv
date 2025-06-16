module alu #(parameter N = 32)
  (
    input  logic [N-1:0] a, b,
    input  logic [2:0]   ALUControl,
    input  logic [4:0]   Shamt,
    input  logic [1:0]   ShiftType,
    output logic [N-1:0] Result,
    output logic [3:0]   ALUFlags
  );
  
  
   // Resultados intermedios para diferentes operaciones
   logic [N-1:0] resultADD, resultSUB, resultAND, resultOR, resultShift, resultMUL;
   logic         cout, coutADD, coutSUB;

   // Instancias de componentes internos
   adderalu #(32) adder_inst(a, b, 1'b0, resultADD, coutADD);   // Instancia para suma
   adderalu #(32) subtractor_inst(a, ~b, 1'b1, resultSUB, coutSUB); // Instancia para resta
   shift b_shifter(b, ShiftType, Shamt, resultShift);  // Instancia para desplazamientos
   mulalu #(N) mul_inst(a, b, resultMUL);       // Multiplicador (parametrizable)


   assign resultAND = a / b;                    
   assign resultOR = a * b;                     

   // Lógica para seleccionar la operación según ALUControl
   always_comb begin 
      case (ALUControl)
         3'b000:   // Add
         begin
            Result = resultADD;
            cout = coutADD;
         end

         3'b001:   // Subtract
         begin
            Result = resultSUB;
            cout = coutSUB;
         end

         3'b010:   // DIV
         begin
            Result = resultAND;
            cout = 0;
         end

         3'b011:   // MUL
         begin
            Result = resultOR;
            cout = 0;
         end

         3'b100:   // Shift
         begin
            Result = resultShift;
            cout = 0;
         end

         3'b101:   // CMP
         begin
            Result = resultMUL;
            cout = 0;
         end

         3'b110:   // MOV
         begin
            Result = a;
            cout = 0;
         end

         default:
         begin
            Result = 32'b0;
            cout = 0;
         end
      endcase
   end


   assign ALUFlags[3] = Result[N-1];            // Bit más significativo de Result indica si es negativo
   assign ALUFlags[2] = &(~Result);             // Si todos los bits de Result son 0, Z=1 (Zero flag)
   assign ALUFlags[1] = ((~ALUControl[1]) & cout); // Carry generado en operaciones de suma/resta (no Shift)
   assign ALUFlags[0] = ~(a[N-1] ^ b[N-1] ^ ALUControl[0]) & (a[N-1] ^ Result[N-1]) & ~ALUControl[1];
   

endmodule


