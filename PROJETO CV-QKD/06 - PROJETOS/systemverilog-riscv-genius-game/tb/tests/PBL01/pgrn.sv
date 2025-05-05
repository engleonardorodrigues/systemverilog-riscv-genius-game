`timescale 1ns / 1ps

import typedefs::*;  // se necessário para sinais compartilhados

// Testbench para o LFSR PRNG usando a interface signals_interface
module prng_tb;

    // Parâmetros de clock
    localparam CLK_PERIOD = 10;  // 100 MHz

    // Instanciação da interface
    logic clk;
    logic rst_n;
    signals_interface dut_signals(.clk(clk), .rst_(rst_n));

    // Instanciação do DUT
    genius_lfsr_rng dut (
        .signals(dut_signals)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Reset e estímulos
    initial begin
        // Inicialização
        rst_n = 0;
        dut_signals.seed = 4'b0000;
        dut_signals.seed_load = 0;
        # (2*CLK_PERIOD);

        // Libera reset
        rst_n = 1;
        # (CLK_PERIOD);

        // Carrega uma seed inicial
        dut_signals.seed = 4'b1010;  // por exemplo
        dut_signals.seed_load = 1;
        # (CLK_PERIOD);
        dut_signals.seed_load = 0;
        # (CLK_PERIOD);

        // Deixa rodar o LFSR por alguns ciclos
        repeat (16) begin
            # (CLK_PERIOD);
            $display("Time=%0t | seed=%b | lfsr_out=%b | rnd_bit=%b",
                     $time,
                     dut_signals.seed,
                     dut_signals.color_bits,
                     dut_signals.random_out);
        end

        // Carrega nova seed no meio da simulação
        dut_signals.seed = 4'b0101;
        dut_signals.seed_load = 1;
        # (CLK_PERIOD);
        dut_signals.seed_load = 0;
        # (CLK_PERIOD);

        repeat (8) begin
            # (CLK_PERIOD);
            $display("Time=%0t | seed=%b | lfsr_out=%b | rnd_bit=%b",
                     $time,
                     dut_signals.seed,
                     dut_signals.color_bits,
                     dut_signals.random_out);
        end

        $finish;
    end

endmodule
