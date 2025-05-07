`timescale 1ns / 1ps

module controller_tb;

    // Parâmetros de simulação
    localparam CLK_PERIOD = 5; // Período de 5ns para 200 MHz
    localparam SIM_TIME = 100000; // 100μs de simulação

    // Sinais de clock e reset
    logic clk;
    logic rst_n;
    
    // Entradas de controle
    logic       start_button;
    logic [3:0] player_input;
    logic       game_mode;
    logic       speed_game;
    logic [1:0] difficulty_level;
    
    // Saídas do controlador
    logic [3:0] leds_sequence;
    logic       game_active;
    logic [7:0] score_display;
    logic [1:0] random_out;
    logic [1:0] prng_color_bits;
    
    // Instância do DUT
    
    controller #(.CLK_FREQ(200)) dut (
    
        .clk(clk),
        .rst_n(rst_n),
        .start_button(start_button),
        .player_input(player_input),
        .speed_game(speed_game),
        .difficulty_level(difficulty_level),
        .game_mode(game_mode),
        .leds_sequence(leds_sequence),
        .game_active(game_active),
        .score_display(score_display),
        .random_out(random_out)
        //.prng_color_bits(prng_color_bits)
        //.random_out(prng_color_bits)
        
    );

    // Gerador de clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Tarefas para interação
    task press_start;
        start_button = 1;
        #(CLK_PERIOD*2);
        start_button = 0;
        #(CLK_PERIOD*2);
        start_button = 1;
    endtask
    
    task player_response(input [3:0] response);
        player_input = response;
        #(CLK_PERIOD*2);
        player_input = 4'b0101;
    endtask

    // Procedimento de teste principal
    initial begin
        // Inicialização
        rst_n = 0;
        start_button = 0;             // START
        player_input = 4'b0000;       // Entrada inicial do jogador
        speed_game = 0;               // Modo lento (2s)
        difficulty_level = 2'b00;     // Fácil (8 elementos)
        game_mode = 0;
        
        // Reset inicial
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD*2);

        // Teste 1: Fluxo normal com acertos
        $display("\n=== TESTE 1: Fluxo normal com acertos ===");
        press_start();
        
        // Aguarda geração da sequência
        while(dut.current_state != dut.SHOW_SEQUENCE) #(CLK_PERIOD);
        
        // Simula entrada correta do jogador
        repeat(8) begin
            while(dut.current_state != dut.GET_PLAYER_INPUT) #(CLK_PERIOD);
            player_response(dut.sequence_reg[dut.sequence_index*4 +:4]);
            #(CLK_PERIOD*10);
        end
        
        // Verifica vitória
        if(dut.current_state == dut.VICTORY)
            $display("Vitória alcançada! Pontuação: %0d", score_display);
        else
            $error("Falha no fluxo de vitória");

        // Teste 2: Entrada incorreta
        $display("\n=== TESTE 2: Entrada incorreta ===");
        press_start();
        
        // Aguarda primeira entrada do jogador
        while(dut.current_state != dut.GET_PLAYER_INPUT) #(CLK_PERIOD);
        player_response(4'b1111); // Resposta errada
        
        // Verifica derrota
        if(dut.current_state == dut.DEFEAT)
            $display("Derrota detectada corretamente");
        else
            $error("Falha na detecção de erro");

        // Teste 3: Mudança de dificuldade
        $display("\n=== TESTE 3: Mudança de dificuldade ===");
        difficulty_level = 2'b01; // Médio (16 elementos)
        press_start();
        
        // Verifica sequência maior
        while(dut.current_state != dut.VICTORY) begin
            if(dut.sequence_index > 6'd15)
                $error("Sequência excedeu tamanho máximo");
            #(CLK_PERIOD);
        end

        // Finalização
        #(CLK_PERIOD*10);
        $display("\n=== Todos os testes concluídos ===");
        $finish;
    end

    // Monitoramento de estados
    always @(dut.current_state) begin
        $display("[%0t] Estado alterado para: %s", 
            $time, dut.current_state.name());
    end

    // Encerra simulação após tempo determinado
    initial begin
        #SIM_TIME;
        $display("Tempo de simulação excedido!");
        $finish;
    end

endmodule