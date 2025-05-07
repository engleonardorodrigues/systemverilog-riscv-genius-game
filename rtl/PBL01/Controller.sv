`timescale 1ns / 1ps

module controller #(
    parameter CLK_FREQ = 200_000_000 // 200 MHz
)(
    input  logic        clk,
    input  logic        rst_n,
    
    // Interface de controle

    input  logic        start_button,
    input  logic [3:0]  player_input,
    
    input  logic        speed_game,
    input  logic [1:0]  difficulty_level,
    input  logic        game_mode,
    
    // Interface para módulos externos
    
    output logic [3:0]  leds_sequence,
    output logic        game_active,
    output logic [7:0]  score_display,
    output logic [1:0]  random_out
);

// Declaração de tipos e estados
typedef enum logic [3:0] {

    ON, 
    IDLE, 
    GNR, 
    MATRIX_VALUES, 
    SHOW_SEQUENCE,
    GET_PLAYER_INPUT, 
    COMPARISON, 
    DEFEAT, 
    EVALUATE, 
    VICTORY
    
} state_t;

// Sinais de estado
state_t current_state, next_state;

// Conexão com o PRNG
logic [1:0] prng_color_bits;
logic       seed_load;
logic [3:0] seed = 4'b1010; // Seed padrão

localparam SEQUENCE_INDEX_WIDTH = 4;

// Instanciação do PRNG
PRNG prng_inst (

    .clk(clk),
    .rst_n(rst_n),
    .seed(seed),
    .seed_load(seed_load),
    //.color_bits(prng_color_bits),
    .random_out(random_out)
    //.random_out(prng_color_bits)
    
);

// Registros de controle
logic [31:0] sequence_reg;
logic [7:0]  game_settings;
logic [3:0]  game_sequence_reg;
logic [7:0]  sequence_index;
logic [27:0] timer;
logic        timer_enable;

// Temporizador 
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
    
        current_state <= ON;
        sequence_reg <= 32'h0;
        sequence_index <= 6'h0;
        timer <= 28'h0;
        
    end
    
    else begin
    
        current_state <= next_state;
        
        // Controle de temporização
        if (timer_enable) begin
            if (timer == (speed_game ? CLK_FREQ-1 : 2*CLK_FREQ-1))
                timer <= 28'h0;
            else
                timer <= timer + 1;
        end
        else begin
            timer <= 28'h0;
        end
    end
end

// MÁQUINA DE ESTADOS FINITOS

always_comb begin

    // Inicialização dos sinais padrão

    next_state = current_state;

    seed_load     = 1'b0;
    timer_enable  = 1'b0;
    leds_sequence = 4'b0000;
    game_active   = 1'b0;

    case (current_state)
    
        // Estado inicial: Aguarda até que o botão de início seja pressionado
        ON: begin
        
            if (start_button) next_state = IDLE;
            
        end
        
        // Estado IDLE: Aguarda a configuração do jogo e o início do jogo
        IDLE: begin
        
            game_active = 1'b1;

            // Configuração do jogo
            assign game_settings = {
            
                speed_game,         // speed_button: 0 = lento, 1 = rápido
                difficulty_level,   // difficulty_button: 00 = fácil, 01 = médio, 10 = difícil
                game_mode           // game_mode_button: 0 = modo siga, 1 = modo mando eu
             
             };      
            

            if (!start_button) begin

                seed_load = 1'b1;
                next_state = GNR;
                
            end
        end
        
        // Estado GNR: Gera a sequência de cores aleatórias
        GNR: begin
            
            seed = 4'b0110;               // Carrega a semente para o gerador (Implementar geração através de um contador com o START)
            next_state = MATRIX_VALUES;   
            
        end
        
        // Estado MATRIX_VALUES: Gera a sequência de cores
        MATRIX_VALUES: begin
        
            sequence_reg[sequence_index * SEQUENCE_INDEX_WIDTH  +:SEQUENCE_INDEX_WIDTH] = random_out;//prng_color_bits;               // Gera a sequência de cores
            next_state = SHOW_SEQUENCE;
            
        end

        // Estado SHOW_SEQUENCE: Mostra a sequência de cores
        SHOW_SEQUENCE: begin
        
            timer_enable = 1'b1;                                                // Habilita o temporizador (2s modo lento)
            
            leds_sequence <= sequence_reg[sequence_index * SEQUENCE_INDEX_WIDTH  +:SEQUENCE_INDEX_WIDTH];
            
            //if (timer == (speed_game ? CLK_FREQ-1 : 2*CLK_FREQ-1)) begin
                if (sequence_index == 6'd0)
                    next_state = GET_PLAYER_INPUT;
                else
                    sequence_index <= sequence_index - 1;
                    
            end
        //end
        
        // Estado GET_PLAYER_INPUT: Aguarda a entrada do jogador
        GET_PLAYER_INPUT: begin
        
            timer_enable = 1'b1;                // Habilita o temporizador
            
            if (player_input != 4'b0000)        // Aguarda a entrada do jogador
                next_state = COMPARISON;        // Se o jogador pressionar um botão, vai para a comparação
                      
        end
        
        // Estado COMPARISON: Compara a entrada do jogador com a sequência
        COMPARISON: begin
            
            // Se a entrada do jogador for diferente da sequência, vai para o estado de derrota
            if (player_input != sequence_reg[sequence_index * SEQUENCE_INDEX_WIDTH  +:SEQUENCE_INDEX_WIDTH])
                next_state = DEFEAT;

            //    
            else if (sequence_index == difficulty_level)
                next_state = EVALUATE;

            // Se a entrada do jogador for correta, continua comparando
            else begin
                sequence_index <= sequence_index - 1;
                next_state = GET_PLAYER_INPUT;
            end
        end

        // Estado DEFEAT: Jogador perdeu
        DEFEAT: begin
        
            leds_sequence = 4'b1111;
            if (timer == CLK_FREQ-1)
                next_state = IDLE;
                
        end
        
        // Estado EVALUATE: Avalia a entrada do jogador
        EVALUATE: begin
        
            if (sequence_reg[31:26] == difficulty_level)
                next_state = VICTORY;
            else
                next_state = GNR;
        end
        
        // Estado VICTORY: Jogador venceu
        VICTORY: begin
        
            leds_sequence = 4'b1010;
            if (timer == CLK_FREQ-1)
                next_state = IDLE;
                
        end
        
        default: next_state = ON;
        
    endcase
end

// Lógica de pontuação (Implementando)
always_ff @(posedge clk) begin
    if (!rst_n)
        score_display <= 8'h00;
    else if (current_state == COMPARISON && player_input == sequence_reg[sequence_index * SEQUENCE_INDEX_WIDTH  +:SEQUENCE_INDEX_WIDTH])
        score_display <= score_display + 1;
end

endmodule