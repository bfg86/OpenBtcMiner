module BtcMinerCore #(
  parameter NONCE_INIT = 32'd0,
  parameter NONCE_MAX  = 32'hFFFF_FFFF
  )(
  input wire        clk,
  input wire        arst_n_a,
  input wire        start_a,
  input wire        config_use_nonce_in_a,
  input wire        config_oneshot_a,
  input wire [31:0] pre_hash_a_0,
  input wire [31:0] pre_hash_a_1,
  input wire [31:0] pre_hash_a_2,
  input wire [31:0] pre_hash_a_3,
  input wire [31:0] pre_hash_a_4,
  input wire [31:0] pre_hash_a_5,
  input wire [31:0] pre_hash_a_6,
  input wire [31:0] pre_hash_a_7,
  input wire [31:0] merkle_root_a_7,
  input wire [31:0] btime_a,
  input wire [31:0] bits_a,
  input wire [31:0] nonce_in_a,
  output reg        done,
  output reg        nonce_found_flag,
  output wire [31:0] nonce_out
);

  reg        arst_x;
  reg        arst;
  reg        start;
  reg        config_use_nonce_in;
  reg        config_oneshot;
  reg [31:0] pre_hash_0;
  reg [31:0] pre_hash_1;
  reg [31:0] pre_hash_2;
  reg [31:0] pre_hash_3;
  reg [31:0] pre_hash_4;
  reg [31:0] pre_hash_5;
  reg [31:0] pre_hash_6;
  reg [31:0] pre_hash_7;
  reg [31:0] merkle_root_7;
  reg [31:0] btime;
  reg [31:0] bits;
  reg [31:0] nonce_in;
  reg        transfer_x;
  reg        transfer;
  reg        transfer_d;

  reg         core_0_valid_i;
  wire        core_0_valid_o;
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

  // Synchronize reset release
  always @(posedge clk or negedge arst_n_a) begin
    if (!arst_n_a) begin
      arst_x <= 1'b1;
      arst   <= 1'b1;
    end
    else begin
      arst_x <= 1'b0;
      arst   <= arst_x;
    end
  end

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
        pre_hash_0 <= pre_hash_a_0;
        pre_hash_1 <= pre_hash_a_1;
        pre_hash_2 <= pre_hash_a_2;
        pre_hash_3 <= pre_hash_a_3;
        pre_hash_4 <= pre_hash_a_4;
        pre_hash_5 <= pre_hash_a_5;
        pre_hash_6 <= pre_hash_a_6;
        pre_hash_7 <= pre_hash_a_7;
        merkle_root_7 <= merkle_root_a_7;
        btime <= btime_a;
        bits <= bits_a;
        nonce_in <= nonce_in_a;
      end
      if (start) start <= 1'b0;
    end
  end
      

  // Timeout
  assign timeout = (nonce == NONCE_MAX);

  // (very) Simplistic nonce found
  always @(*) nonce_found = core_1_valid_o && (core_1_hash_7 == 32'd0);

  // Core control signals
  always @(*) begin
    core_0_valid_i = (state == 2'd1);
    core_1_valid_i = (state == 2'd1 && core_0_valid_o);
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
        end
      end
      2'd1: begin // HASH
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

  .init_0 (pre_hash_0),
  .init_1 (pre_hash_1),
  .init_2 (pre_hash_2),
  .init_3 (pre_hash_3),
  .init_4 (pre_hash_4),
  .init_5 (pre_hash_5),
  .init_6 (pre_hash_6),
  .init_7 (pre_hash_7),

  .chunk_0  (merkle_root_7),
  .chunk_1  (btime),
  .chunk_2  (bits),
  .chunk_3  (nonce),
  .chunk_4  (32'h8000_0000),
  .chunk_5  (32'd0),
  .chunk_6  (32'd0),
  .chunk_7  (32'd0),
  .chunk_8  (32'd0),
  .chunk_9  (32'd0),
  .chunk_10 (32'd0),
  .chunk_11 (32'd0),
  .chunk_12 (32'd0),
  .chunk_13 (32'd0),
  .chunk_14 (32'd0),
  .chunk_15 (32'h0000_0280),

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
