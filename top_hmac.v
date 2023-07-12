`timescale 1ns / 1ps

module top_hmac (
    input wire CLK,
    input wire RST,
    input wire init,//** when = 1, computation begins
    
    output wire data_available_both //outputs a 1 when HMAC finished
);

reg data_available;
reg data_available2;

assign data_available_both = data_available & data_available2;

wire [511:0] key; 
wire [511:0] data; // the data block

wire [511:0] key2; 
wire [511:0] data2; 

wire [255:0] intermediate_hash;
wire [255:0] hmac; // final HMAC output

wire [255:0] intermediate_hash2;
wire [255:0] hmac2; // final HMAC output



// generateing the key and data signals internally.
// hardcoded in atm
assign key = 512'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f;
assign data = 512'h6162638000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000218;

assign key2 = 512'h0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000;
assign data2 = 512'h48692054686572658000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000240; // "Hi There" with key padding
    
//the data is padded manually
//so you take the data, append '80' (1 ) and then the length in hex at end (512 + (#extra chars *4 ))

hmac_sha256 hmac_sha256_inst (
    .CLK(CLK),
    .RST(RST),
    .go(init),//**
    .key(key),
    .data(data),
    .intermediate_hash(intermediate_hash),
    .data_available(data_available),
    .hmac(hmac)
);

hmac_sha256 hmac_sha256_inst2 (
    .CLK(CLK),
    .RST(RST),
    .go(init),//**
    .key(key2),
    .data(data2),
    .intermediate_hash(intermediate_hash2),
    .data_available(data_available2),
    .hmac(hmac2)
);

endmodule
