///////////////////////////////////////////////////
// Name    : Sha256.v
// Created : __date__
//
// Description:
// TODO: Write a short description of this module.
//
///////////////////////////////////////////////////

module Sha256Ppl (
  input wire clk,
  input wire arst,
  input wire rst,
  input wire valid_i,
  output reg valid_o,

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

  wire [31:0] chunk [0:15];
  reg  [31:0] hash [0:7];
  reg  [31:0] w [0:64][0:15];
  wire [31:0] k [0:63];
  reg  [31:0] a[0:64], b[0:64], c[0:64], d[0:64], e[0:64], f[0:64], g[0:64], h[0:64];
  reg [64:0] valid;

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

  // Key variable
  assign k[00] = 32'h428a2f98;
  assign k[01] = 32'h71374491;
  assign k[02] = 32'hb5c0fbcf;
  assign k[03] = 32'he9b5dba5;
  assign k[04] = 32'h3956c25b;
  assign k[05] = 32'h59f111f1;
  assign k[06] = 32'h923f82a4;
  assign k[07] = 32'hab1c5ed5;
  assign k[08] = 32'hd807aa98;
  assign k[09] = 32'h12835b01;
  assign k[10] = 32'h243185be;
  assign k[11] = 32'h550c7dc3;
  assign k[12] = 32'h72be5d74;
  assign k[13] = 32'h80deb1fe;
  assign k[14] = 32'h9bdc06a7;
  assign k[15] = 32'hc19bf174;
  assign k[16] = 32'he49b69c1;
  assign k[17] = 32'hefbe4786;
  assign k[18] = 32'h0fc19dc6;
  assign k[19] = 32'h240ca1cc;
  assign k[20] = 32'h2de92c6f;
  assign k[21] = 32'h4a7484aa;
  assign k[22] = 32'h5cb0a9dc;
  assign k[23] = 32'h76f988da;
  assign k[24] = 32'h983e5152;
  assign k[25] = 32'ha831c66d;
  assign k[26] = 32'hb00327c8;
  assign k[27] = 32'hbf597fc7;
  assign k[28] = 32'hc6e00bf3;
  assign k[29] = 32'hd5a79147;
  assign k[30] = 32'h06ca6351;
  assign k[31] = 32'h14292967;
  assign k[32] = 32'h27b70a85;
  assign k[33] = 32'h2e1b2138;
  assign k[34] = 32'h4d2c6dfc;
  assign k[35] = 32'h53380d13;
  assign k[36] = 32'h650a7354;
  assign k[37] = 32'h766a0abb;
  assign k[38] = 32'h81c2c92e;
  assign k[39] = 32'h92722c85;
  assign k[40] = 32'ha2bfe8a1;
  assign k[41] = 32'ha81a664b;
  assign k[42] = 32'hc24b8b70;
  assign k[43] = 32'hc76c51a3;
  assign k[44] = 32'hd192e819;
  assign k[45] = 32'hd6990624;
  assign k[46] = 32'hf40e3585;
  assign k[47] = 32'h106aa070;
  assign k[48] = 32'h19a4c116;
  assign k[49] = 32'h1e376c08;
  assign k[50] = 32'h2748774c;
  assign k[51] = 32'h34b0bcb5;
  assign k[52] = 32'h391c0cb3;
  assign k[53] = 32'h4ed8aa4a;
  assign k[54] = 32'h5b9cca4f;
  assign k[55] = 32'h682e6ff3;
  assign k[56] = 32'h748f82ee;
  assign k[57] = 32'h78a5636f;
  assign k[58] = 32'h84c87814;
  assign k[59] = 32'h8cc70208;
  assign k[60] = 32'h90befffa;
  assign k[61] = 32'ha4506ceb;
  assign k[62] = 32'hbef9a3f7;
  assign k[63] = 32'hc67178f2;

  function automatic reg [31:0] right_rotate(input reg [31:0] number, input reg[31:0] n);
    right_rotate = (number >> n) | (number << (32 - n));
  endfunction

  // First stage. Load data on valid
  always @(posedge clk) begin
    if (valid_i) begin
      for (integer j = 0; j<16; j=j+1) begin
        w[0][j] <= chunk[j];
      end
      a[0] <= init_0;
      b[0] <= init_1;
      c[0] <= init_2;
      d[0] <= init_3;
      e[0] <= init_4;
      f[0] <= init_5;
      g[0] <= init_6;
      h[0] <= init_7;
    end
  end

  always @(posedge clk or posedge arst) begin
    if (arst) begin
      valid[0] <= 1'b0;
    end
    else if (rst) begin
      valid[0] <= 1'b0;
    end
    else begin
      valid[0] <= valid_i;
    end
  end

  // Stage 1-63.
  genvar gv;
  generate for (gv=1; gv<65; gv=gv+1) begin : gen_stage
    wire [31:0] s0_ext, s1_ext, s0_comp, s1_comp;
    wire [31:0] ch;
    wire [31:0] maj;
    wire [31:0] temp1, temp2;


    assign s0_ext = (right_rotate (w[gv-1][1], 7)) ^ (right_rotate (w[gv-1][1], 18)) ^ (w[gv-1][1] >> 3);
    assign s1_ext = (right_rotate (w[gv-1][14], 17)) ^ (right_rotate (w[gv-1][14], 19))  ^ (w[gv-1][14] >> 10);


    always @(posedge clk) begin : la_ExtendFF
      if (valid[gv-1]) begin
        for (integer j = 0; j<15; j=j+1) begin
          w[gv][j] <= w[gv-1][j+1];
        end
        w[gv][15] <= w[gv-1][0] + s0_ext + w[gv-1][9] + s1_ext;
      end
    end


    assign s1_comp = right_rotate(e[gv-1], 6) ^ right_rotate(e[gv-1],11) ^ right_rotate(e[gv-1], 25);
    assign ch = (e[gv-1] & f[gv-1]) ^ ((~e[gv-1]) & g[gv-1]);
    assign temp1 = h[gv-1] + s1_comp + ch + k[gv-1] + w[gv-1][0];
    assign s0_comp = right_rotate(a[gv-1], 2) ^ right_rotate(a[gv-1], 13) ^ right_rotate(a[gv-1], 22);
    assign maj = (a[gv-1] & b[gv-1]) ^ (a[gv-1] & c[gv-1]) ^ (b[gv-1] & c[gv-1]);
    assign temp2 = s0_comp + maj;

    always @(posedge clk) begin : la_CompressFF
      if (valid[gv-1]) begin
        h[gv] <= g[gv-1];
        g[gv] <= f[gv-1];
        f[gv] <= e[gv-1];
        e[gv] <= d[gv-1] + temp1;
        d[gv] <= c[gv-1];
        c[gv] <= b[gv-1];
        b[gv] <= a[gv-1];
        a[gv] <= temp1 + temp2;
      end
    end

  always @(posedge clk or posedge arst) begin
    if (arst) begin
      valid[gv] <= 1'b0;
    end
    else if (rst) begin
      valid[gv] <= 1'b0;
    end
    else begin
      valid[gv] <= valid[gv-1];
    end
  end

  end
  endgenerate

  always @(posedge clk) begin
    if (valid[64]) begin
      hash[0] <= init_0 + a[64];
      hash[1] <= init_1 + b[64];
      hash[2] <= init_2 + c[64];
      hash[3] <= init_3 + d[64];
      hash[4] <= init_4 + e[64];
      hash[5] <= init_5 + f[64];
      hash[6] <= init_6 + g[64];
      hash[7] <= init_7 + h[64];
    end
  end

  always @(posedge clk or posedge arst) begin
    if (arst) begin
      valid_o <= 1'b0;
    end
    else if (rst) begin
      valid_o <= 1'b0;
    end
    else begin
      valid_o <= valid[64];
    end
  end


endmodule

