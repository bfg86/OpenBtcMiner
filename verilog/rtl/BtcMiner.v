module BtcMiner (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif  
    input             clk,
    input             arst,
    input             wb_rst,
    input      [ 7:0] wb_addr,
    input      [ 3:0] wb_sel,
    input             wb_we,
    input      [31:0] wb_wdata,
    input             wb_cycle,
    input             wb_strobe,
    input      [ 2:0] wb_cti,
    input      [ 1:0] wb_bte,
    output     [31:0] wb_rdata,
    output            wb_ack,
    output            wb_err,
    output            wb_rty
);


  wire [31:0] version;
  wire [31:0] previous_hash_0;
  wire [31:0] previous_hash_1;
  wire [31:0] previous_hash_2;
  wire [31:0] previous_hash_3;
  wire [31:0] previous_hash_4;
  wire [31:0] previous_hash_5;
  wire [31:0] previous_hash_6;
  wire [31:0] previous_hash_7;
  wire [31:0] merkle_root_0;
  wire [31:0] merkle_root_1;
  wire [31:0] merkle_root_2;
  wire [31:0] merkle_root_3;
  wire [31:0] merkle_root_4;
  wire [31:0] merkle_root_5;
  wire [31:0] merkle_root_6;
  wire [31:0] merkle_root_7;
  wire [31:0] btime;
  wire [31:0] bits;
  wire [31:0] nonce_in;
  wire  [31:0] nonce;
  wire        start;
  wire        done;
  wire        nonce_found;
  wire        config_use_nonce_in;
  wire        config_oneshot;

  BtcMinerRegs u_Regs (
    .clk            (clk),
    .wbRst          (wb_rst),
    .wbAddr         (wb_addr),
    .wbSel          (wb_sel),
    .wbWe           (wb_we),
    .wbWData        (wb_wdata),
    .wbCycle        (wb_cycle),
    .wbStrobe       (wb_strobe),
    .wbCti          (wb_cti),
    .wbBte          (wb_bte),
    .wbRData        (wb_rdata),
    .wbAck          (wb_ack),
    .wbErr          (wb_err),
    .wbRty          (wb_rty),
    .version        (version),
    .previous_hash_0(previous_hash_0),
    .previous_hash_1(previous_hash_1),
    .previous_hash_2(previous_hash_2),
    .previous_hash_3(previous_hash_3),
    .previous_hash_4(previous_hash_4),
    .previous_hash_5(previous_hash_5),
    .previous_hash_6(previous_hash_6),
    .previous_hash_7(previous_hash_7),
    .merkle_root_0  (merkle_root_0),
    .merkle_root_1  (merkle_root_1),
    .merkle_root_2  (merkle_root_2),
    .merkle_root_3  (merkle_root_3),
    .merkle_root_4  (merkle_root_4),
    .merkle_root_5  (merkle_root_5),
    .merkle_root_6  (merkle_root_6),
    .merkle_root_7  (merkle_root_7),
    .btime          (btime),
    .bits           (bits),
    .nonce_in       (nonce_in),
    .nonce          (nonce),
    .done           (done),
    .nonce_found    (nonce_found),
    .start          (start),
    .config_use_nonce_in (config_use_nonce_in),
    .config_oneshot (config_oneshot)
  );

  BtcMinerCore u_Core (
    .clk            (clk),
    .arst           (arst),
    .version        (version),
    .previous_hash_0(previous_hash_0),
    .previous_hash_1(previous_hash_1),
    .previous_hash_2(previous_hash_2),
    .previous_hash_3(previous_hash_3),
    .previous_hash_4(previous_hash_4),
    .previous_hash_5(previous_hash_5),
    .previous_hash_6(previous_hash_6),
    .previous_hash_7(previous_hash_7),
    .merkle_root_0  (merkle_root_0),
    .merkle_root_1  (merkle_root_1),
    .merkle_root_2  (merkle_root_2),
    .merkle_root_3  (merkle_root_3),
    .merkle_root_4  (merkle_root_4),
    .merkle_root_5  (merkle_root_5),
    .merkle_root_6  (merkle_root_6),
    .merkle_root_7  (merkle_root_7),
    .btime          (btime),
    .bits           (bits),
    .nonce_in       (nonce_in),
    .nonce_out      (nonce),
    .done           (done),
    .nonce_found    (nonce_found),
    .start          (start),
    .config_use_nonce_in (config_use_nonce_in),
    .config_oneshot (config_oneshot)
  );

// Cocotb waveform dump
`ifdef COCOTB_SIM
initial begin
  $dumpfile ("BtcMiner.lxt");
  $dumpvars (0, BtcMiner);
  #1;
end
`endif
endmodule
