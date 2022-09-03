module BtcMinerCore #(
  parameter NONCE_INIT = 32'd0,
  parameter NONCE_MAX  = 32'hFFFF_FFFF
  )(
  input wire        clk,
  input wire        arst,
  input wire        start_a,
  input wire        config_use_nonce_in_a,
  input wire        config_oneshot_a,
  input wire [31:0] version_a,
  input wire [31:0] previous_hash_a_0,
  input wire [31:0] previous_hash_a_1,
  input wire [31:0] previous_hash_a_2,
  input wire [31:0] previous_hash_a_3,
  input wire [31:0] previous_hash_a_4,
  input wire [31:0] previous_hash_a_5,
  input wire [31:0] previous_hash_a_6,
  input wire [31:0] previous_hash_a_7,
  input wire [31:0] merkle_root_a_0,
  input wire [31:0] merkle_root_a_1,
  input wire [31:0] merkle_root_a_2,
  input wire [31:0] merkle_root_a_3,
  input wire [31:0] merkle_root_a_4,
  input wire [31:0] merkle_root_a_5,
  input wire [31:0] merkle_root_a_6,
  input wire [31:0] merkle_root_a_7,
  input wire [31:0] btime_a,
  input wire [31:0] bits_a,
  input wire [31:0] nonce_in_a,
  output reg        done,
  output reg        nonce_found_flag,
  output wire [31:0] nonce_out
);

  reg        start;
  reg        config_use_nonce_in;
  reg        config_oneshot;
  reg [31:0] version;
  reg [31:0] previous_hash_0;
  reg [31:0] previous_hash_1;
  reg [31:0] previous_hash_2;
  reg [31:0] previous_hash_3;
  reg [31:0] previous_hash_4;
  reg [31:0] previous_hash_5;
  reg [31:0] previous_hash_6;
  reg [31:0] previous_hash_7;
  reg [31:0] merkle_root_0;
  reg [31:0] merkle_root_1;
  reg [31:0] merkle_root_2;
  reg [31:0] merkle_root_3;
  reg [31:0] merkle_root_4;
  reg [31:0] merkle_root_5;
  reg [31:0] merkle_root_6;
  reg [31:0] merkle_root_7;
  reg [31:0] btime;
  reg [31:0] bits;
  reg [31:0] nonce_in;
  reg        transfer_x;
  reg        transfer;
  reg        transfer_d;

  reg         start_d;
  reg         core_0_valid_i;
  wire        core_0_valid_o;
  reg  [31:0] core_0_chunk_0;
  reg  [31:0] core_0_chunk_1;
  reg  [31:0] core_0_chunk_2;
  reg  [31:0] core_0_chunk_3;
  reg  [31:0] core_0_chunk_4;
  reg  [31:0] core_0_chunk_5;
  reg  [31:0] core_0_chunk_6;
  reg  [31:0] core_0_chunk_7;
  reg  [31:0] core_0_chunk_8;
  reg  [31:0] core_0_chunk_9;
  reg  [31:0] core_0_chunk_10;
  reg  [31:0] core_0_chunk_11;
  reg  [31:0] core_0_chunk_12;
  reg  [31:0] core_0_chunk_13;
  reg  [31:0] core_0_chunk_14;
  reg  [31:0] core_0_chunk_15;
  reg  [31:0] core_0_init_0;
  reg  [31:0] core_0_init_1;
  reg  [31:0] core_0_init_2;
  reg  [31:0] core_0_init_3;
  reg  [31:0] core_0_init_4;
  reg  [31:0] core_0_init_5;
  reg  [31:0] core_0_init_6;
  reg  [31:0] core_0_init_7;
  wire [31:0] core_0_hash_0;
  wire [31:0] core_0_hash_1;
  wire [31:0] core_0_hash_2;
  wire [31:0] core_0_hash_3;
  wire [31:0] core_0_hash_4;
  wire [31:0] core_0_hash_5;
  wire [31:0] core_0_hash_6;
  wire [31:0] core_0_hash_7;


  reg         core_1_valid_i;
  wire        core_1_valid_o;
  wire [31:0] core_1_chunk_0;
  wire [31:0] core_1_chunk_1;
  wire [31:0] core_1_chunk_2;
  wire [31:0] core_1_chunk_3;
  wire [31:0] core_1_chunk_4;
  wire [31:0] core_1_chunk_5;
  wire [31:0] core_1_chunk_6;
  wire [31:0] core_1_chunk_7;
  wire [31:0] core_1_chunk_8;
  wire [31:0] core_1_chunk_9;
  wire [31:0] core_1_chunk_10;
  wire [31:0] core_1_chunk_11;
  wire [31:0] core_1_chunk_12;
  wire [31:0] core_1_chunk_13;
  wire [31:0] core_1_chunk_14;
  wire [31:0] core_1_chunk_15;
  wire [31:0] core_1_init_0;
  wire [31:0] core_1_init_1;
  wire [31:0] core_1_init_2;
  wire [31:0] core_1_init_3;
  wire [31:0] core_1_init_4;
  wire [31:0] core_1_init_5;
  wire [31:0] core_1_init_6;
  wire [31:0] core_1_init_7;
  wire [31:0] core_1_hash_0;
  wire [31:0] core_1_hash_1;
  wire [31:0] core_1_hash_2;
  wire [31:0] core_1_hash_3;
  wire [31:0] core_1_hash_4;
  wire [31:0] core_1_hash_5;
  wire [31:0] core_1_hash_6;
  wire [31:0] core_1_hash_7;

  reg  [31:0] nonce;
  wire [31:0] next_nonce;

  reg  nonce_found;
  wire timeout;

  // States
  // IDLE    - wait for start
  // CHUNK_0 - core 0 calculates first chunk
  // CHUNK_1 - core 0 calculates the second chunk with initial nonce
  // HASH    - core 0 re-calculates second chunk with incremental nonce. Core 1 hashes previous result from Core 0
  reg [1:0] state;

  // Synchronize configuration data. 
  always @(posedge clk or posedge arst) begin
    if (arst) begin
      transfer_x <= 1'b0;
      transfer   <= 1'b0;
      transfer_d <= 1'b0;
    end
    else begin
      transfer_x <= start_a;
      transfer   <= transfer_x;
      transfer_d <= transfer;
    end
  end

  // Use any toggle of "start" to do the transfer
  always @(posedge clk or posedge arst) begin
    if (arst) begin
      start <= 1'b0;
    end
    else begin
      if (transfer ^ transfer_d) begin
        start <= 1'b1;
        config_use_nonce_in <= config_use_nonce_in_a;
        config_oneshot <= config_oneshot_a;
        version <= version_a;
        previous_hash_0 <= previous_hash_a_0;
        previous_hash_1 <= previous_hash_a_1;
        previous_hash_2 <= previous_hash_a_2;
        previous_hash_3 <= previous_hash_a_3;
        previous_hash_4 <= previous_hash_a_4;
        previous_hash_5 <= previous_hash_a_5;
        previous_hash_6 <= previous_hash_a_6;
        previous_hash_7 <= previous_hash_a_7;
        merkle_root_0 <= merkle_root_a_0;
        merkle_root_1 <= merkle_root_a_1;
        merkle_root_2 <= merkle_root_a_2;
        merkle_root_3 <= merkle_root_a_3;
        merkle_root_4 <= merkle_root_a_4;
        merkle_root_5 <= merkle_root_a_5;
        merkle_root_6 <= merkle_root_a_6;
        merkle_root_7 <= merkle_root_a_7;
        btime <= btime_a;
        bits <= bits_a;
        nonce_in <= nonce_in_a;
      end
      if (start) start <= 1'b0;
    end
  end
      
  // Core 0 chunk inputs
  always @(*) begin
    if (start_d) begin
      core_0_chunk_0  = version;
      core_0_chunk_1  = previous_hash_0;
      core_0_chunk_2  = previous_hash_1;
      core_0_chunk_3  = previous_hash_2;
      core_0_chunk_4  = previous_hash_3;
      core_0_chunk_5  = previous_hash_4;
      core_0_chunk_6  = previous_hash_5;
      core_0_chunk_7  = previous_hash_6;
      core_0_chunk_8  = previous_hash_7;
      core_0_chunk_9  = merkle_root_0;
      core_0_chunk_10 = merkle_root_1;
      core_0_chunk_11 = merkle_root_2;
      core_0_chunk_12 = merkle_root_3;
      core_0_chunk_13 = merkle_root_4;
      core_0_chunk_14 = merkle_root_5;
      core_0_chunk_15 = merkle_root_6;
    end
    else begin
      core_0_chunk_0  = merkle_root_7;
      core_0_chunk_1  = btime;
      core_0_chunk_2  = bits;
      core_0_chunk_3  = nonce;
      core_0_chunk_4  = 32'h8000_0000;
      core_0_chunk_5  = 32'd0;
      core_0_chunk_6  = 32'd0;
      core_0_chunk_7  = 32'd0;
      core_0_chunk_8  = 32'd0;
      core_0_chunk_9  = 32'd0;
      core_0_chunk_10 = 32'd0;
      core_0_chunk_11 = 32'd0;
      core_0_chunk_12 = 32'd0;
      core_0_chunk_13 = 32'd0;
      core_0_chunk_14 = 32'd0;
      core_0_chunk_15 = 32'h0000_0280;
    end
  end

  // Timeout
  assign timeout = (nonce == NONCE_MAX);

  // (very) Simplistic nonce found
  always @(*) nonce_found = core_1_valid_o && (core_1_hash_7 == 32'd0);

  // Core control signals
  always @(*) begin
    core_0_valid_i = start_d || (state == 2'd2);
    core_1_valid_i = (state == 2'd2 && core_0_valid_o);
  end

  always @(posedge clk or posedge arst) begin
    if (arst) start_d <= 1'b0;
    else start_d <= start;
  end

  assign nonce_out = nonce;

  // State machine
  always @(posedge clk or posedge arst) begin
    if (arst) begin
      state <= 2'd0;
      done <= 1'b1;
      nonce_found_flag <= 1'b0;
      nonce <= 32'd0;
    end
    else begin
      case (state)
      2'd0: begin // IDLE
        if (start) begin
          state <= 2'd1;
          done <= 1'b0;
          nonce <= config_use_nonce_in ? nonce_in : NONCE_INIT;
          nonce_found_flag <= 1'b0;
          core_0_init_0 <= 32'h6a09e667;
          core_0_init_1 <= 32'hbb67ae85;
          core_0_init_2 <= 32'h3c6ef372;
          core_0_init_3 <= 32'ha54ff53a;
          core_0_init_4 <= 32'h510e527f;
          core_0_init_5 <= 32'h9b05688c;
          core_0_init_6 <= 32'h1f83d9ab;
          core_0_init_7 <= 32'h5be0cd19;
        end
      end
      2'd1: begin // CHUNK_0
        if (core_0_valid_o) begin
          core_0_init_0 <= core_0_hash_0;
          core_0_init_1 <= core_0_hash_1;
          core_0_init_2 <= core_0_hash_2;
          core_0_init_3 <= core_0_hash_3;
          core_0_init_4 <= core_0_hash_4;
          core_0_init_5 <= core_0_hash_5;
          core_0_init_6 <= core_0_hash_6;
          core_0_init_7 <= core_0_hash_7;
          state <= 2'd2;
        end
      end
      2'd2: begin // HASH
        nonce <= nonce + 1'b1;
        if (core_1_valid_o && (nonce_found || timeout || config_oneshot)) begin
          state <= 2'd0;
          done <= 1'b1;
          nonce <= nonce - 132; // It takes 132 cycles to propagate a nonce to its hash.
          nonce_found_flag <= nonce_found;
        end
      end
      default: begin
      end
      endcase
    end
  end

  // Sha256 Core 0
  Sha256Ppl u0_Sha256 (
  .clk   (clk),
  .arst  (arst),
  .rst   (nonce_found),
  .valid_i (core_0_valid_i),
  .valid_o (core_0_valid_o),

  .init_0 (core_0_init_0),
  .init_1 (core_0_init_1),
  .init_2 (core_0_init_2),
  .init_3 (core_0_init_3),
  .init_4 (core_0_init_4),
  .init_5 (core_0_init_5),
  .init_6 (core_0_init_6),
  .init_7 (core_0_init_7),

  .chunk_0  (core_0_chunk_0),
  .chunk_1  (core_0_chunk_1),
  .chunk_2  (core_0_chunk_2),
  .chunk_3  (core_0_chunk_3),
  .chunk_4  (core_0_chunk_4),
  .chunk_5  (core_0_chunk_5),
  .chunk_6  (core_0_chunk_6),
  .chunk_7  (core_0_chunk_7),
  .chunk_8  (core_0_chunk_8),
  .chunk_9  (core_0_chunk_9),
  .chunk_10 (core_0_chunk_10),
  .chunk_11 (core_0_chunk_11),
  .chunk_12 (core_0_chunk_12),
  .chunk_13 (core_0_chunk_13),
  .chunk_14 (core_0_chunk_14),
  .chunk_15 (core_0_chunk_15),

  .hash_0 (core_0_hash_0),
  .hash_1 (core_0_hash_1),
  .hash_2 (core_0_hash_2),
  .hash_3 (core_0_hash_3),
  .hash_4 (core_0_hash_4),
  .hash_5 (core_0_hash_5),
  .hash_6 (core_0_hash_6),
  .hash_7 (core_0_hash_7)
  );

  // Sha256 Core 1
  Sha256Ppl u1_Sha256 (
  .clk   (clk),
  .arst  (arst),
  .rst   (nonce_found),
  .valid_i (core_1_valid_i),
  .valid_o (core_1_valid_o),

  .init_0 (32'h6a09e667),
  .init_1 (32'hbb67ae85),
  .init_2 (32'h3c6ef372),
  .init_3 (32'ha54ff53a),
  .init_4 (32'h510e527f),
  .init_5 (32'h9b05688c),
  .init_6 (32'h1f83d9ab),
  .init_7 (32'h5be0cd19),

  .chunk_0  (core_0_hash_0),
  .chunk_1  (core_0_hash_1),
  .chunk_2  (core_0_hash_2),
  .chunk_3  (core_0_hash_3),
  .chunk_4  (core_0_hash_4),
  .chunk_5  (core_0_hash_5),
  .chunk_6  (core_0_hash_6),
  .chunk_7  (core_0_hash_7),
  .chunk_8  (32'h8000_0000),
  .chunk_9  (32'd0),
  .chunk_10 (32'd0),
  .chunk_11 (32'd0),
  .chunk_12 (32'd0),
  .chunk_13 (32'd0),
  .chunk_14 (32'd0),
  .chunk_15 (32'h0000_0100),

  .hash_0 (core_1_hash_0),
  .hash_1 (core_1_hash_1),
  .hash_2 (core_1_hash_2),
  .hash_3 (core_1_hash_3),
  .hash_4 (core_1_hash_4),
  .hash_5 (core_1_hash_5),
  .hash_6 (core_1_hash_6),
  .hash_7 (core_1_hash_7)
  );

endmodule
