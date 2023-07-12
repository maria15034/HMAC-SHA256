
`timescale 1ns/1ps

module tb_hmac_sha256;

reg CLK;
reg RST;
reg init; //**
wire data_available_both;

reg [511:0] key;
reg [511:0] data;
wire [255:0] intermediate_hash;
wire data_available;
wire [255:0] hmac;

reg [511:0] key2;
reg [511:0] data2;
wire [255:0] intermediate_hash2;
wire data_available2;
wire [255:0] hmac2;

hmac_sha256 hmac_inst (
    .CLK(CLK),
    .RST(RST),
    .go(init),//**
    .key(key),
    .data(data),
    .intermediate_hash(intermediate_hash),
    .data_available(data_available),
    .hmac(hmac)
);


hmac_sha256 hmac_inst2 (
    .CLK(CLK),
    .RST(RST),
    .go(init),//**
    .key(key2),
    .data(data2),
    .intermediate_hash(intermediate_hash2),
    .data_available(data_available2),
    .hmac(hmac2)
);


assign data_available_both = data_available & data_available2;

always #5 CLK = ~CLK;

initial begin
    CLK = 1'b0;
    RST = 1'b0;
    init = 1'b1;//**
    
    key = 512'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f;
    data = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000218; // "abc" with key padding
    
    key2 = 512'h0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000;
    data2 = 512'h48692054686572658000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000240; // "Hi There" with key padding
    
    #10 RST = 1'b1;
  //  init = 1'b1; //**
   // $display("letting init = 1");
    //you can see that computation only occurs when init = 1'b1;
    
end

always @(posedge CLK) begin
    if(data_available_both == 1)
        begin
            $display("********* data available *********");
            $display("Intermediate Hash: %h", intermediate_hash);
            $display("Final Hash: %h", hmac);
            $display("HMAC: %h", hmac);
            $display("");
            $display("Intermediate Hash 2: %h", intermediate_hash2);
            $display("Final Hash 2: %h", hmac2);
            $display("HMAC 2: %h", hmac2);
            $display("");
        end
    
    else    
        begin
            $display("DATA UNAVAILABLE");
            $display("Intermediate Hash: %h", intermediate_hash);
            $display("Final Hash: %h", hmac);
            $display("HMAC: %h", hmac);
            $display("");
            $display("Intermediate Hash 2: %h", intermediate_hash2);
            $display("Final Hash 2: %h", hmac2);
            $display("HMAC 2: %h", hmac2);
            $display("");
       end
end

endmodule
