
module hmac_sha256 (
    input wire CLK,
    input wire RST,
    input wire go,//**
    input wire [511:0] key, // key
    input wire [511:0] data, // data block
    output reg [255:0] intermediate_hash,
    output reg data_available, // =1 when hmac finished
    output reg [255:0] hmac // HMAC output
);

localparam [511:0] ipad = 512'h36363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636;
localparam [511:0] opad = 512'h5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C;

reg [255:0] dummy_data; //to hold XOR results as part of fsm

reg [1023:0] inner_block; //key xored with ipad + data appended
wire [255:0] inner_digest; //inner_block hash result (for step 4)
wire inner_ready;
wire inner_digest_valid;

reg [1023:0] outer_block; //key xored with opad
wire [255:0] outer_digest; // step7 ; hash result of outer_block concatenated with inner_digest
wire outer_ready;
wire outer_digest_valid;

reg inner_init;
reg inner_next;
reg outer_init;
reg outer_next;

integer state;

reg [511:0] inner_block_reg;
reg [511:0] outer_block_reg;

sha256_core sha256_inner_inst (
    .CLK(CLK),
    .RST(RST),
    .init(inner_init),
    .next(inner_next),
    .mode(1'b1), // SHA256 mode
    .block(inner_block_reg),
    .ready(inner_ready),
    .digest(inner_digest),
    .digest_valid(inner_digest_valid)
);

sha256_core sha256_outer_inst (
    .CLK(CLK),
    .RST(RST),
    .init(outer_init),
    .next(outer_next),
    .mode(1'b1), // SHA256 mode
    .block(outer_block_reg),
    .ready(outer_ready),
    .digest(outer_digest),
    .digest_valid(outer_digest_valid)
);

always @* begin
   inner_block[1023:512] = key ^ ipad;
   inner_block[511:0] = data;
   
   outer_block[1023:512] = key ^ opad;
//   outer_block[511:256] = inner_digest;
   outer_block[255:0] = 256'h8000000000000000000000000000000000000000000000000000000000000300;
end

//always @(posedge CLK) begin
//    if (!RST) begin
//        dummy_data <= 0;
//    end else begin
//        if(inner_ready)
//            begin
//                dummy_data <= key ^ OPAD;
//            end
//    end
//end


always @(posedge CLK) begin
    if (RST == 1'b0) begin
        hmac <= 256'h0;
        state <= 0;
        inner_init <= 1'b0;
        inner_next <= 1'b0;
        outer_init <= 1'b0;
        outer_next <= 1'b0;
        inner_block_reg <= inner_block[511:0];
        outer_block_reg <= outer_block[511:0];
    //end else begin
    end else if (go == 1'b1) begin   // ** checking if 'go'/init is high
        case (state)
            0: begin
                inner_block_reg <= inner_block[1023:512];
                state <= 1;
            end
            1: begin
                inner_init <= 1'b1;
                state <= 2;
            end
            2: begin
                inner_init <= 1'b0;
                state <= 3;
            end
            3: begin
                if (inner_ready) begin
                    dummy_data <= inner_digest;
                    state <= 4;
                end
            end
            4: begin
                inner_block_reg <= inner_block[511:0];
                state <= 5;
            end 
            5: begin
                inner_next <= 1'b1;
                state <= 6;
            end                       
            6: begin
                inner_next <= 1'b0;
                state <= 7;
            end
            7: begin
                if (inner_ready) begin
                    dummy_data <= inner_digest;
                    intermediate_hash <= inner_digest;
                    state <= 8;
                end
            end
            8: begin
                outer_block_reg <= outer_block[1023:512];
                outer_block[511:256] <= inner_digest;
                state <= 9;
            end            
            9: begin
                outer_init <= 1'b1;
                state <=10; 
            end
            10: begin
                outer_init <= 1'b0;
                state <=11; 
            end
            
            11: begin
                if (outer_ready) begin
                    dummy_data <= outer_digest;
                    state <= 12;
                end
            end
            12: begin
                outer_block_reg <= outer_block[511:0];
                state <= 13;
            end             
            13: begin
                outer_next <= 1'b1;
                state <= 14; 
            end 
            14: begin
                outer_next <= 1'b0;
                state <= 15; 
            end                            
            15: begin 
                if (outer_ready) begin 
                    hmac <= outer_digest;
                    data_available <= 1; 
                    state<=0; 
                end 
            end 
        endcase
    end
end

endmodule
