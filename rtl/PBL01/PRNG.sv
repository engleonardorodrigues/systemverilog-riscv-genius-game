`timescale 1ns / 1ps

module PRNG  (

    input  logic        clk,         // clock de operação
    input  logic        rst_n,       // reset assíncrono ativo baixo
    input  logic [3:0] seed,         // 4-bit seed input
    input  logic       seed_load,    // reload pulse for seed
    output logic [3:0] color_bits,   // 4-bit pseudo-random output for colors
    output logic [1:0] random_out   // single-bit random output (e.g., LSB)
    //signals_interface   genius
);
    // Registrador interno do LFSR
    logic [3:0] lfsr_reg;
    logic       feedback;

    // LFSR de 4 bits com polinômio x^4 + x + 1 (taps em bit3 e bit0)
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            // No reset, inicializa com a seed
           random_out <= 'b0;
           
        end
        
        else if (seed_load) begin
            // Se receber pulso de recarga, carrega a seed novamente
            lfsr_reg <= seed;
        end
        
        else begin
            // Gera novo bit de feedback e desloca o registro
            feedback  = lfsr_reg[3] ^ lfsr_reg[0];
            lfsr_reg  <= { lfsr_reg[2:0], feedback };
            random_out <= lfsr_reg[1:0];
        end
    end

    // A saída são os 4 bits atuais do LFSR
  
endmodule
