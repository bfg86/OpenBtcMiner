/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

/*
	Test of OpenBtcMiner:
		- Register accessability check
		- Configures a known bitcoin block with initial nonce, and runs until valid hash is found.
*/
#define reg_btc_config      (*(volatile uint32_t*) (0x30000000))
#define reg_btc_pre_hash_0  (*(volatile uint32_t*) (0x30000004))
#define reg_btc_pre_hash_1  (*(volatile uint32_t*) (0x30000008))
#define reg_btc_pre_hash_2  (*(volatile uint32_t*) (0x3000000C))
#define reg_btc_pre_hash_3  (*(volatile uint32_t*) (0x30000010))
#define reg_btc_pre_hash_4  (*(volatile uint32_t*) (0x30000014))
#define reg_btc_pre_hash_5  (*(volatile uint32_t*) (0x30000018))
#define reg_btc_pre_hash_6  (*(volatile uint32_t*) (0x3000001C))
#define reg_btc_pre_hash_7  (*(volatile uint32_t*) (0x30000020))
#define reg_btc_merkle_7    (*(volatile uint32_t*) (0x30000024))
#define reg_btc_time        (*(volatile uint32_t*) (0x30000028))
#define reg_btc_bits        (*(volatile uint32_t*) (0x3000002C))
#define reg_btc_nonce       (*(volatile uint32_t*) (0x30000030))
#define reg_btc_status      (*(volatile uint32_t*) (0x30000034))
#define reg_btc_nonce_out   (*(volatile uint32_t*) (0x30000038))

void main()
{

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

    reg_spi_enable = 1;
    reg_wb_enable = 1;
	// reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

     /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

	reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]

    // Flag start of the test
	reg_mprj_datal = 0xAB600000;

    // Configure BtcMiner to use the initial nonce (and enable the core)
    reg_btc_config = 3;

    // This is the header for block height 125552.
    // Pre-hash calculated from version, previous block hash, and first 7 words of the merkle tree
    reg_btc_pre_hash_0 = 0x9524c593;
    reg_btc_pre_hash_1 = 0x05c56713;
    reg_btc_pre_hash_2 = 0x16e669ba;
    reg_btc_pre_hash_3 = 0x2d2810a0;
    reg_btc_pre_hash_4 = 0x07e86e37;
    reg_btc_pre_hash_5 = 0x2f56a9da;
    reg_btc_pre_hash_6 = 0xcd5bce69;
    reg_btc_pre_hash_7 = 0x7a78da2d;
    reg_btc_merkle_7   = 0xF1FC122B;
    reg_btc_time       = 0xC7F5D74D;
    reg_btc_bits       = 0xF2B9441A;

    // Set the initial nonce. The real (final) nonce is 0x42a14695 (0x9546a142 reversed)
    reg_btc_nonce = 0x42a14693;

    // Start hashing
    reg_btc_status = 1;

    // Wait for done flag
    while (reg_btc_status == 0);

    int status = 0xAB61;
    // Check nonce found
    if ((reg_btc_status & 0x2) != 2) status++;
    // Check nonce value
    if (reg_btc_nonce_out != 0x42a14695) status++;

    // Return status to testbench. Success = 0xAB610000;
    reg_mprj_datal = (status << 16);
}
