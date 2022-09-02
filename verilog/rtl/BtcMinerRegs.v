module BtcMinerRegs #(
    parameter ID_CONFIG      = 8'h00,
    parameter ID_VERSION     = 8'h04,
    parameter ID_PREV_HASH_0 = 8'h08,
    parameter ID_PREV_HASH_1 = 8'h0C,
    parameter ID_PREV_HASH_2 = 8'h10,
    parameter ID_PREV_HASH_3 = 8'h14,
    parameter ID_PREV_HASH_4 = 8'h18,
    parameter ID_PREV_HASH_5 = 8'h1C,
    parameter ID_PREV_HASH_6 = 8'h20,
    parameter ID_PREV_HASH_7 = 8'h24,
    parameter ID_MERKLE_0    = 8'h28,
    parameter ID_MERKLE_1    = 8'h2C,
    parameter ID_MERKLE_2    = 8'h30,
    parameter ID_MERKLE_3    = 8'h34,
    parameter ID_MERKLE_4    = 8'h38,
    parameter ID_MERKLE_5    = 8'h3C,
    parameter ID_MERKLE_6    = 8'h40,
    parameter ID_MERKLE_7    = 8'h44,
    parameter ID_TIME        = 8'h48,
    parameter ID_BITS        = 8'h4C,
    parameter ID_NONCE       = 8'h50,
    parameter ID_STATUS      = 8'h54,
    parameter ID_NONCE_OUT   = 8'h58
) (
    // Clock / reset
    input wire clk,

    // Wishbone interface
    input             wbRst,
    input      [ 7:0] wbAddr,
    input      [ 3:0] wbSel,
    input             wbWe,
    input      [31:0] wbWData,
    input             wbCycle,
    input             wbStrobe,
    input      [ 2:0] wbCti,
    input      [ 1:0] wbBte,
    output reg [31:0] wbRData,
    output reg        wbAck,
    output            wbErr,
    output            wbRty,

    // Btc header
    output reg [31:0] version,
    output reg [31:0] previous_hash_0,
    output reg [31:0] previous_hash_1,
    output reg [31:0] previous_hash_2,
    output reg [31:0] previous_hash_3,
    output reg [31:0] previous_hash_4,
    output reg [31:0] previous_hash_5,
    output reg [31:0] previous_hash_6,
    output reg [31:0] previous_hash_7,
    output reg [31:0] merkle_root_0,
    output reg [31:0] merkle_root_1,
    output reg [31:0] merkle_root_2,
    output reg [31:0] merkle_root_3,
    output reg [31:0] merkle_root_4,
    output reg [31:0] merkle_root_5,
    output reg [31:0] merkle_root_6,
    output reg [31:0] merkle_root_7,
    output reg [31:0] btime,
    output reg [31:0] bits,
    output reg [31:0] nonce_in,

    // Miner results
    input wire [31:0] nonce,
    input wire        done,
    input wire        nonce_found,

    // Miner control
    output reg start,
    output reg config_use_nonce_in,
    output reg config_oneshot
);

  wire wbAccess;
  wire wbRead;
  wire wbWrite;

  assign wbAccess = wbCycle & wbStrobe;
  assign wbRead = wbAccess & (~wbWe) & (wbAck == 1'b0);
  assign wbWrite = wbAccess & wbWe & (wbAck == 1'b0);

  assign wbErr = 1'b0;
  assign wbRty = 1'b0;

  // Wishbone ack
  always @(posedge clk) begin
    if (wbRst) begin
      wbAck <= 1'b0;
    end else begin
      wbAck <= wbAccess & ~(wbAck);
    end
  end

  // Wishbone read
  always @(posedge clk) begin
    if (wbRst) begin
      wbRData <= 32'd0;
    end else begin
      if (wbRead) begin
        case (wbAddr)
          ID_CONFIG:      wbRData <= {30'd0, config_oneshot, config_use_nonce_in};
          ID_VERSION:     wbRData <= version;
          ID_PREV_HASH_0: wbRData <= previous_hash_0;
          ID_PREV_HASH_1: wbRData <= previous_hash_1;
          ID_PREV_HASH_2: wbRData <= previous_hash_2;
          ID_PREV_HASH_3: wbRData <= previous_hash_3;
          ID_PREV_HASH_4: wbRData <= previous_hash_4;
          ID_PREV_HASH_5: wbRData <= previous_hash_5;
          ID_PREV_HASH_6: wbRData <= previous_hash_6;
          ID_PREV_HASH_7: wbRData <= previous_hash_7;
          ID_MERKLE_0:    wbRData <= merkle_root_0;
          ID_MERKLE_1:    wbRData <= merkle_root_1;
          ID_MERKLE_2:    wbRData <= merkle_root_2;
          ID_MERKLE_3:    wbRData <= merkle_root_3;
          ID_MERKLE_4:    wbRData <= merkle_root_4;
          ID_MERKLE_5:    wbRData <= merkle_root_5;
          ID_MERKLE_6:    wbRData <= merkle_root_6;
          ID_MERKLE_7:    wbRData <= merkle_root_7;
          ID_TIME:        wbRData <= btime;
          ID_BITS:        wbRData <= bits;
          ID_NONCE:       wbRData <= nonce_in;
          ID_STATUS:      wbRData <= {30'd0, nonce_found, done};
          ID_NONCE_OUT:   wbRData <= nonce;
          default: begin
          end
        endcase
      end
    end
  end

  // Wishbone write
  always @(posedge clk) begin
    if (wbRst) begin
      config_use_nonce_in <= 1'b0;
      config_oneshot <= 1'b0;
      version <= 32'd0;
      previous_hash_0 <= 32'd0;
      previous_hash_1 <= 32'd0;
      previous_hash_2 <= 32'd0;
      previous_hash_3 <= 32'd0;
      previous_hash_4 <= 32'd0;
      previous_hash_5 <= 32'd0;
      previous_hash_6 <= 32'd0;
      previous_hash_7 <= 32'd0;
      merkle_root_0 <= 32'd0;
      merkle_root_1 <= 32'd0;
      merkle_root_2 <= 32'd0;
      merkle_root_3 <= 32'd0;
      merkle_root_4 <= 32'd0;
      merkle_root_5 <= 32'd0;
      merkle_root_6 <= 32'd0;
      merkle_root_7 <= 32'd0;
      btime <= 32'd0;
      bits <= 32'd0;
      nonce_in <= 32'd0;
      start <= 1'b0;
    end else begin
      if (wbWrite) begin
        case (wbAddr)
          ID_CONFIG: begin
            if (wbSel[0]) begin
              config_use_nonce_in <= wbWData[0];
              config_oneshot <= wbWData[1];
            end
          end
          ID_VERSION: begin
            if (wbSel[0]) version[7:0] <= wbWData[7:0];
            if (wbSel[1]) version[15:8] <= wbWData[15:8];
            if (wbSel[2]) version[23:16] <= wbWData[23:16];
            if (wbSel[3]) version[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_0: begin
            if (wbSel[0]) previous_hash_0[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_0[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_0[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_0[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_1: begin
            if (wbSel[0]) previous_hash_1[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_1[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_1[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_1[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_2: begin
            if (wbSel[0]) previous_hash_2[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_2[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_2[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_2[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_3: begin
            if (wbSel[0]) previous_hash_3[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_3[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_3[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_3[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_4: begin
            if (wbSel[0]) previous_hash_4[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_4[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_4[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_4[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_5: begin
            if (wbSel[0]) previous_hash_5[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_5[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_5[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_5[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_6: begin
            if (wbSel[0]) previous_hash_6[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_6[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_6[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_6[31:24] <= wbWData[31:24];
          end
          ID_PREV_HASH_7: begin
            if (wbSel[0]) previous_hash_7[7:0] <= wbWData[7:0];
            if (wbSel[1]) previous_hash_7[15:8] <= wbWData[15:8];
            if (wbSel[2]) previous_hash_7[23:16] <= wbWData[23:16];
            if (wbSel[3]) previous_hash_7[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_0: begin
            if (wbSel[0]) merkle_root_0[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_0[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_0[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_0[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_1: begin
            if (wbSel[0]) merkle_root_1[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_1[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_1[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_1[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_2: begin
            if (wbSel[0]) merkle_root_2[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_2[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_2[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_2[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_3: begin
            if (wbSel[0]) merkle_root_3[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_3[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_3[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_3[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_4: begin
            if (wbSel[0]) merkle_root_4[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_4[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_4[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_4[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_5: begin
            if (wbSel[0]) merkle_root_5[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_5[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_5[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_5[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_6: begin
            if (wbSel[0]) merkle_root_6[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_6[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_6[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_6[31:24] <= wbWData[31:24];
          end
          ID_MERKLE_7: begin
            if (wbSel[0]) merkle_root_7[7:0] <= wbWData[7:0];
            if (wbSel[1]) merkle_root_7[15:8] <= wbWData[15:8];
            if (wbSel[2]) merkle_root_7[23:16] <= wbWData[23:16];
            if (wbSel[3]) merkle_root_7[31:24] <= wbWData[31:24];
          end
          ID_TIME: begin
            if (wbSel[0]) btime[7:0] <= wbWData[7:0];
            if (wbSel[1]) btime[15:8] <= wbWData[15:8];
            if (wbSel[2]) btime[23:16] <= wbWData[23:16];
            if (wbSel[3]) btime[31:24] <= wbWData[31:24];
          end
          ID_BITS: begin
            if (wbSel[0]) bits[7:0] <= wbWData[7:0];
            if (wbSel[1]) bits[15:8] <= wbWData[15:8];
            if (wbSel[2]) bits[23:16] <= wbWData[23:16];
            if (wbSel[3]) bits[31:24] <= wbWData[31:24];
          end
          ID_NONCE: begin
            if (wbSel[0]) nonce_in[7:0]   <= wbWData[7:0];
            if (wbSel[1]) nonce_in[15:8]  <= wbWData[15:8];
            if (wbSel[2]) nonce_in[23:16] <= wbWData[23:16];
            if (wbSel[3]) nonce_in[31:24] <= wbWData[31:24];
          end
          ID_STATUS: begin
            start <= 1'b1;
          end
          default: begin
          end
        endcase
      end
      if (start) start <= 1'b0;
    end
  end
endmodule
