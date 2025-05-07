interface signals_interface(input logic clk, input logic rst_);

    // Player inputs signals of controller
    logic [3:0] player_color_button,
    logic speed_button,
    logic dificulty_button,
    logic mode_game_button,
    logic start_button,
 
    //Controller output signals
    logic game_mode,
    logic settings_values,
    logic next_sequence_index,
    logic match_index,
    logic reg_sequence_wr,
    logic enable_led,
    logic update_score,

    //GRN signals
    logic [3:0] seed;         // 4-bit seed input
    logic       seed_load;    // reload pulse for seed
    logic [3:0] color_bits;   // 4-bit pseudo-random output for colors
    logic       random_out;   // single-bit random output (e.g., LSB)

    //Memory signals
    logic mem_rd,
    logic mem_wr,

    //Register Sequence Item

endinterface

