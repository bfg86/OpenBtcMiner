# OpenBtcMiner

Two fully pipelined SHA256 cores.

![btcminer](docs/source/_static/openbtcminer.png)
# Register map

| Name        | Address | Size | Description |
|-------------|---------|------|-------------|
| CONFIG      | 0x00    |  2:0 | Bit 0: Enable Bit 1: Use NONCE_IN Bit 2: Oneshot |
| PRE_HASH_0  | 0x04    | 31:0 | |
| PRE_HASH_1  | 0x08    | 31:0 | |
| PRE_HASH_2  | 0x0C    | 31:0 | |
| PRE_HASH_3  | 0x10    | 31:0 | |
| PRE_HASH_4  | 0x14    | 31:0 | |
| PRE_HASH_5  | 0x18    | 31:0 | |
| PRE_HASH_6  | 0x1C    | 31:0 | |
| PRE_HASH_7  | 0x20    | 31:0 | |
| MERKLE_7    | 0x24    | 31:0 | |
| TIME        | 0x28    | 31:0 | |
| BITS        | 0x2C    | 31:0 | |
| NONCE_IN    | 0x30    | 31:0 | Input nonce, used for testing. Ignored if CONFIG.USE_NONCE_IN is 0.|
| STATUS      | 0x34    |  1:0 | Reading : Bit 0: Done Bit 1: Nonce found. Writing to this register will start hashing. |
| NONCE_OUT   | 0x58    | 31:0 | Output nonce |

# License
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
