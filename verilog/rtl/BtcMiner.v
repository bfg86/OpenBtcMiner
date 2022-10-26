module BtcMiner (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    input             clk,
    input             wb_clk,
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


  wire [31:0] pre_hash_0;
  wire [31:0] pre_hash_1;
  wire [31:0] pre_hash_2;
  wire [31:0] pre_hash_3;
  wire [31:0] pre_hash_4;
  wire [31:0] pre_hash_5;
  wire [31:0] pre_hash_6;
  wire [31:0] pre_hash_7;
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
  wire        config_enable;
  wire        config_use_nonce_in;
  wire        config_oneshot;

  BtcMinerRegs u_Regs (
    .clk            (wb_clk),
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
    .pre_hash_0     (pre_hash_0),
    .pre_hash_1     (pre_hash_1),
    .pre_hash_2     (pre_hash_2),
    .pre_hash_3     (pre_hash_3),
    .pre_hash_4     (pre_hash_4),
    .pre_hash_5     (pre_hash_5),
    .pre_hash_6     (pre_hash_6),
    .pre_hash_7     (pre_hash_7),
    .merkle_root_7  (merkle_root_7),
    .btime          (btime),
    .bits           (bits),
    .nonce_in       (nonce_in),
    .nonce_a        (nonce),
    .done_a         (done),
    .nonce_found_a  (nonce_found),
    .start          (start),
    .config_enable  (config_enable),
    .config_use_nonce_in (config_use_nonce_in),
    .config_oneshot (config_oneshot)
  );

  BtcMinerCore u_Core (
    .clk            (clk),
    .arst_n_a         (config_enable),
    .pre_hash_a_0     (pre_hash_0),
    .pre_hash_a_1     (pre_hash_1),
    .pre_hash_a_2     (pre_hash_2),
    .pre_hash_a_3     (pre_hash_3),
    .pre_hash_a_4     (pre_hash_4),
    .pre_hash_a_5     (pre_hash_5),
    .pre_hash_a_6     (pre_hash_6),
    .pre_hash_a_7     (pre_hash_7),
    .merkle_root_a_7  (merkle_root_7),
    .btime_a          (btime),
    .bits_a           (bits),
    .nonce_in_a       (nonce_in),
    .nonce_out      (nonce),
    .done           (done),
    .nonce_found_flag (nonce_found),
    .start_a          (start),
    .config_use_nonce_in_a (config_use_nonce_in),
    .config_oneshot_a (config_oneshot)
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
