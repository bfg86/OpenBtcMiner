///////////////////////////////////////////////////
// Name    : Sha256.v
// Created : __date__
//
// Description:
// TODO: Write a short description of this module.
//
///////////////////////////////////////////////////

module Sha256 (
  input wire clk,
  input wire arst,
  input wire rst,
  input wire load_init,
  input wire valid,
  output reg ready,

  output reg [5:0] round,
  input wire [31:0] k,

  input wire [31:0] init_0,
  input wire [31:0] init_1,
  input wire [31:0] init_2,
  input wire [31:0] init_3,
  input wire [31:0] init_4,
  input wire [31:0] init_5,
  input wire [31:0] init_6,
  input wire [31:0] init_7,

  input wire [31:0] chunk_0,
  input wire [31:0] chunk_1,
  input wire [31:0] chunk_2,
  input wire [31:0] chunk_3,
  input wire [31:0] chunk_4,
  input wire [31:0] chunk_5,
  input wire [31:0] chunk_6,
  input wire [31:0] chunk_7,
  input wire [31:0] chunk_8,
  input wire [31:0] chunk_9,
  input wire [31:0] chunk_10,
  input wire [31:0] chunk_11,
  input wire [31:0] chunk_12,
  input wire [31:0] chunk_13,
  input wire [31:0] chunk_14,
  input wire [31:0] chunk_15,

  output wire [31:0] hash_0,
  output wire [31:0] hash_1,
  output wire [31:0] hash_2,
  output wire [31:0] hash_3,
  output wire [31:0] hash_4,
  output wire [31:0] hash_5,
  output wire [31:0] hash_6,
  output wire [31:0] hash_7

);

  wire [31:0] chunk [16];
  reg  [31:0] hash [8];
  reg [31:0] w [16];
  wire [31:0] w_i_q, w_i_d;
  reg [31:0] a, b, c, d, e, f, g, h;
  reg [31:0] s0_ext, s1_ext, s0_comp, s1_comp;
  reg [31:0] ch;
  reg [31:0] maj;
  reg [31:0] temp1, temp2;


  // States:
  // IDLE
  // COMPRESS -> 64 cycles
  // ADD
  reg [1:0] state;

  // Since verilog does not support multi-dim arrays in port list..
  assign chunk[0] = chunk_0;
  assign chunk[1] = chunk_1;
  assign chunk[2] = chunk_2;
  assign chunk[3] = chunk_3;
  assign chunk[4] = chunk_4;
  assign chunk[5] = chunk_5;
  assign chunk[6] = chunk_6;
  assign chunk[7] = chunk_7;
  assign chunk[8] = chunk_8;
  assign chunk[9] = chunk_9;
  assign chunk[10] = chunk_10;
  assign chunk[11] = chunk_11;
  assign chunk[12] = chunk_12;
  assign chunk[13] = chunk_13;
  assign chunk[14] = chunk_14;
  assign chunk[15] = chunk_15;

  assign hash_0 = hash[0];
  assign hash_1 = hash[1];
  assign hash_2 = hash[2];
  assign hash_3 = hash[3];
  assign hash_4 = hash[4];
  assign hash_5 = hash[5];
  assign hash_6 = hash[6];
  assign hash_7 = hash[7];


  function automatic reg [31:0] right_rotate(input reg [31:0] number, input reg[31:0] n);
    right_rotate = (number >> n) | (number << (32 - n));
  endfunction

  assign w_i_q = w[15];
  assign w_i_d = w[0] + s0_ext + w[9] + s1_ext;

  always_comb begin : la_ExtendComb
    s0_ext = (right_rotate (w[1], 7)) ^ (right_rotate (w[1], 18)) ^ (w[1] >> 3);
    s1_ext = (right_rotate (w[14], 17)) ^ (right_rotate (w[14], 19))  ^ (w[14] >> 10);
  end

  always_comb begin : la_CompressComb
    s1_comp = right_rotate(e, 6) ^ right_rotate(e,11) ^ right_rotate(e, 25);
    ch = (e & f) ^ ((~e) & g);
    temp1 = h + s1_comp + ch + k + w[0];
    s0_comp = right_rotate(a, 2) ^ right_rotate(a, 13) ^ right_rotate(a, 22);
    maj = (a & b) ^ (a & c) ^ (b & c);
    temp2 = s0_comp + maj;
  end

  always_ff @(posedge clk) begin
    int j;
    case (state)
      2'd0 : begin
        if (valid) begin
          for (j = 0; j<16; j=j+1) begin
            w[j] <= chunk[j];
          end
        end
      end
      2'd1 : begin
        for (j = 0; j<15; j=j+1) begin
          w[j] <= w[j+1];
        end
        w[15] <= w[0] + s0_ext + w[9] + s1_ext;
      end
      default : begin
      end
    endcase
  end

  always_ff @(posedge clk) begin
      case (state)
        2'd0 : begin
          if (valid) begin
            if (load_init) begin
            a <= init_0;
            b <= init_1;
            c <= init_2;
            d <= init_3;
            e <= init_4;
            f <= init_5;
            g <= init_6;
            h <= init_7;
            end
            else begin
            a <= hash[0];
            b <= hash[1];
            c <= hash[2];
            d <= hash[3];
            e <= hash[4];
            f <= hash[5];
            g <= hash[6];
            h <= hash[7];
            end
          end
        end
        2'd1 : begin
          h <= g;
          g <= f;
          f <= e;
          e <= d + temp1;
          d <= c;
          c <= b;
          b <= a;
          a <= temp1 + temp2;
        end
        default : begin
        end
      endcase
    end

  always_ff @(posedge clk or posedge arst) begin
    if (arst) begin
      hash[0] <= 32'h6a09e667;
      hash[1] <= 32'hbb67ae85;
      hash[2] <= 32'h3c6ef372;
      hash[3] <= 32'ha54ff53a;
      hash[4] <= 32'h510e527f;
      hash[5] <= 32'h9b05688c;
      hash[6] <= 32'h1f83d9ab;
      hash[7] <= 32'h5be0cd19;
    end
    else begin
      if (rst) begin
        hash[0] <= 32'h6a09e667;
        hash[1] <= 32'hbb67ae85;
        hash[2] <= 32'h3c6ef372;
        hash[3] <= 32'ha54ff53a;
        hash[4] <= 32'h510e527f;
        hash[5] <= 32'h9b05688c;
        hash[6] <= 32'h1f83d9ab;
        hash[7] <= 32'h5be0cd19;
      end
      else begin
        case (state)
          2'd0 : begin
            if (valid && load_init) begin
              hash[0] <= init_0;
              hash[1] <= init_1;
              hash[2] <= init_2;
              hash[3] <= init_3;
              hash[4] <= init_4;
              hash[5] <= init_5;
              hash[6] <= init_6;
              hash[7] <= init_7;
            end
          end
          2'd2 : begin
            hash[0] <= hash[0] + a;
            hash[1] <= hash[1] + b;
            hash[2] <= hash[2] + c;
            hash[3] <= hash[3] + d;
            hash[4] <= hash[4] + e;
            hash[5] <= hash[5] + f;
            hash[6] <= hash[6] + g;
            hash[7] <= hash[7] + h;
          end
          default : begin
          end
        endcase
      end
    end
  end

  always_ff @(posedge clk or posedge arst) begin
    if (arst) begin
      state <= 2'd0;
      ready <= 1'b1;
      round <= 6'd0;
    end else begin
      if (rst) begin
        state <= 2'd0;
        ready <= 1'b1;
        round <= 6'd0;
      end
      else begin
      case (state)
        2'd0 : begin
          if (valid) begin
            ready <= 1'b0;
            round <= 6'd0;
            state <= 2'd1;
          end
        end
        2'd1 : begin
          if (round == 6'd63) begin
            state <= 2'd2;
          end
          else begin
            round <= round + 6'd1;
          end
        end
        2'd2 : begin
          ready <= 1'b1;
          state <= 2'd0;
        end
        default : begin
        end
      endcase
      end
    end
  end
endmodule

