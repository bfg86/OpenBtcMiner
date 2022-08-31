module BtcMinerUart (
    input  clk,
    input  rst,
    input  uart_rx,
    output uart_tx,

    input  [31:0] wbRData,
    input         wbAck,
    input         wbErr,
    input         wbRty,
    output        wbRst,
    output [ 7:0] wbAddr,
    output [ 3:0] wbSel,
    output        wbWe,
    output [31:0] wbWData,
    output        wbCycle,
    output        wbStrobe,
    output [ 2:0] wbCti,
    output [ 1:0] wbBte

);

UartCore u_UartCore (
  .ck                 (clk),
  .rst                (rst),
  .brgTick            (brgTick),
  .brgOversample8     (brg_oversample),
  .txData             (txData),
  .startTx            (startTx),
  .txReady            (txReady),
  .rxData             (rxData),
  .rxReady            (rxReady),
  .rxParityError      (rxParityError),
  .rxProtocolError    (rxProtocolError),
  .clearFlags         (clearFlags),
  .uartRx_a           (uart_rx),
  .uartTx             (uart_tx)
);

localparam BRG_DIV_FACTOR = 100_000_000 / 115_200;
localparam BRG_COUNTER_WIDTH = $clog2(BRG_DIV_FACTOR);

BaudRateGenerator #(
  // $clog2(divFactor)
  .COUNTER_WIDTH    (BRG_COUNTER_WIDTH)
) u_BaudRateGenerator (
  .ck               (clk),
  .arst_n           (1'b1),
  .rst_n            (~rst),
  .divFactor        (BRG_DIV_FACTOR),  // clock frequency / desired baud rate
  .tick             (brg_tick),
  .tick_inv         (),
  .oversample8      (brg_oversample)
);
endmodule
