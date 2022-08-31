module BtcMinerCore #(
  parameter NONCE_INIT = 32'd0,
  parameter NONCE_MAX  = 32'hFFFF_FFFF
  )(
  input wire        clk,
  input wire        arst,
  input wire        start,
  input wire        config_use_nonce_in,
  input wire        config_oneshot,
  input wire [31:0] version,
  input wire [31:0] previous_hash_0,
  input wire [31:0] previous_hash_1,
  input wire [31:0] previous_hash_2,
  input wire [31:0] previous_hash_3,
  input wire [31:0] previous_hash_4,
  input wire [31:0] previous_hash_5,
  input wire [31:0] previous_hash_6,
  input wire [31:0] previous_hash_7,
  input wire [31:0] merkle_root_0,
  input wire [31:0] merkle_root_1,
  input wire [31:0] merkle_root_2,
  input wire [31:0] merkle_root_3,
  input wire [31:0] merkle_root_4,
  input wire [31:0] merkle_root_5,
  input wire [31:0] merkle_root_6,
  input wire [31:0] merkle_root_7,
  input wire [31:0] btime,
  input wire [31:0] bits,
  input wire [31:0] nonce_in,
  output reg        done,
  output reg        nonce_found,
  output wire [31:0] nonce_out
);

  wire [5:0]  round;
  wire [31:0] k;

  wire        core_0_rst;
  reg         core_0_load_init;
  reg         core_0_valid;
  wire        core_0_ready;
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
  wire [31:0] core_0_init_0;
  wire [31:0] core_0_init_1;
  wire [31:0] core_0_init_2;
  wire [31:0] core_0_init_3;
  wire [31:0] core_0_init_4;
  wire [31:0] core_0_init_5;
  wire [31:0] core_0_init_6;
  wire [31:0] core_0_init_7;
  reg  [31:0] core_0_init_0_rg;
  reg  [31:0] core_0_init_1_rg;
  reg  [31:0] core_0_init_2_rg;
  reg  [31:0] core_0_init_3_rg;
  reg  [31:0] core_0_init_4_rg;
  reg  [31:0] core_0_init_5_rg;
  reg  [31:0] core_0_init_6_rg;
  reg  [31:0] core_0_init_7_rg;
  wire [31:0] core_0_hash_0;
  wire [31:0] core_0_hash_1;
  wire [31:0] core_0_hash_2;
  wire [31:0] core_0_hash_3;
  wire [31:0] core_0_hash_4;
  wire [31:0] core_0_hash_5;
  wire [31:0] core_0_hash_6;
  wire [31:0] core_0_hash_7;

  wire        core_1_rst;
  reg         core_1_load_init;
  reg         core_1_valid;
  wire        core_1_ready;
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

  wire timeout;

  // States
  // IDLE    - wait for start
  // CHUNK_0 - core 0 calculates first chunk
  // CHUNK_1 - core 0 calculates the second chunk with initial nonce
  // HASH    - core 0 re-calculates second chunk with incremental nonce. Core 1 hashes previous result from Core 0
  reg [1:0] state;

  // Core 0 chunk inputs
  always @(*) begin
    if (state == 2'd0) begin
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
      core_0_chunk_3  = next_nonce;
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
  assign timeout = !(nonce < NONCE_MAX);

  // (very) Simplistic nonce found
  always @(*) nonce_found = (core_1_hash_7 == 32'd0);

  // Core control signals
  always @(*) begin
    core_0_valid = start || (state != 2'd0 && core_0_ready);
    core_0_load_init = (state != 2'd0 && core_0_ready);
    core_1_valid = (state == 2'd2 && core_0_ready) ||
                   (state == 2'd3 && core_1_ready && !timeout && !nonce_found);
    core_1_load_init = core_1_valid;
  end

  // Initial values for core 0
  assign core_0_init_0 = (state == 2'd1) ? core_0_hash_0 : core_0_init_0_rg;
  assign core_0_init_1 = (state == 2'd1) ? core_0_hash_1 : core_0_init_1_rg;
  assign core_0_init_2 = (state == 2'd1) ? core_0_hash_2 : core_0_init_2_rg;
  assign core_0_init_3 = (state == 2'd1) ? core_0_hash_3 : core_0_init_3_rg;
  assign core_0_init_4 = (state == 2'd1) ? core_0_hash_4 : core_0_init_4_rg;
  assign core_0_init_5 = (state == 2'd1) ? core_0_hash_5 : core_0_init_5_rg;
  assign core_0_init_6 = (state == 2'd1) ? core_0_hash_6 : core_0_init_6_rg;
  assign core_0_init_7 = (state == 2'd1) ? core_0_hash_7 : core_0_init_7_rg;

  // Next nonce
  assign next_nonce = (state != 2'd3 && config_use_nonce_in) ? nonce_in : nonce + 1'd1;

  // Nonce output is from the previous round
  assign nonce_out = nonce - 1;

  // State machine
  always @(posedge clk or posedge arst) begin
    if (arst) begin
      nonce <= NONCE_INIT;
      state <= 2'd0;
      done <= 1'b1;
    end
    else begin
      case (state)
      2'd0: begin // IDLE
        if (start) begin
          state <= 2'd1;
          done <= 1'b0;
        end
      end
      2'd1: begin // CHUNK_0
        if (core_0_ready) begin
          core_0_init_0_rg <= core_0_hash_0;
          core_0_init_1_rg <= core_0_hash_1;
          core_0_init_2_rg <= core_0_hash_2;
          core_0_init_3_rg <= core_0_hash_3;
          core_0_init_4_rg <= core_0_hash_4;
          core_0_init_5_rg <= core_0_hash_5;
          core_0_init_6_rg <= core_0_hash_6;
          core_0_init_7_rg <= core_0_hash_7;
          state <= 2'd2;
        end
      end
      2'd2: begin // CHUNK_1
        if (core_0_ready) begin
          nonce <= next_nonce;
          state <= 2'd3;
        end
      end
      2'd3: begin // HASH
        if (core_1_ready) begin
          if (nonce_found || timeout || config_oneshot) begin
            state <= 2'd0;
            done <= 1'b1;
          end
          else begin
            nonce <= next_nonce;
          end
        end
      end
      default: begin
      end
      endcase
    end
  end

  // Sha256 Core 0
  Sha256 u0_Sha256 (
  .clk   (clk),
  .arst  (arst),
  .rst   (core_0_rst),
  .load_init (core_0_load_init),
  .valid (core_0_valid),
  .ready (core_0_ready),
  .round (round),
  .k (k),

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
  Sha256 u1_Sha256 (
  .clk   (clk),
  .arst  (arst),
  .rst   (core_1_rst),
  .load_init (core_1_load_init),
  .valid (core_1_valid),
  .ready (core_1_ready),
  .round (),
  .k (k),

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

  // Shared key memory
  Sha256KeyMem u_KeyMem (
  .clk       (clk),
  .rst       (rst),
  .k_addr    (round),
  .k         (k)
  );
endmodule
