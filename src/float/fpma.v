module fpma(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         valid_in,

    // 32-bit IEEE754 single precision
    input  wire [31:0]  A_in, 
    input  wire [31:0]  B_in,
    input  wire [31:0]  C_in,

    output wire         valid_out,
    output wire [31:0]  F_out
);

    //------------------------------------------------
    // Stage 1: Decode
    //------------------------------------------------
    reg [31:0] A_s1, B_s1, C_s1;
    reg        valid_s1;

    // Break each float into sign, exponent, fraction
    wire signA_in = A_in[31];
    wire [7:0] expA_in = A_in[30:23];
    wire [22:0] fracA_in = A_in[22:0];

    wire signB_in = B_in[31];
    wire [7:0] expB_in = B_in[30:23];
    wire [22:0] fracB_in = B_in[22:0];

    wire signC_in = C_in[31];
    wire [7:0] expC_in = C_in[30:23];
    wire [22:0] fracC_in = C_in[22:0];

    // Pipeline registers for stage 1
    reg        signA_s1, signB_s1, signC_s1;
    reg [7:0]  expA_s1, expB_s1, expC_s1;
    reg [22:0] fracA_s1, fracB_s1, fracC_s1;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_s1 <= 1'b0;
            signA_s1 <= 1'b0; expA_s1 <= 8'd0; fracA_s1 <= 23'd0;
            signB_s1 <= 1'b0; expB_s1 <= 8'd0; fracB_s1 <= 23'd0;
            signC_s1 <= 1'b0; expC_s1 <= 8'd0; fracC_s1 <= 23'd0;
        end else begin
            valid_s1 <= valid_in;

            signA_s1 <= signA_in;
            expA_s1  <= expA_in;
            fracA_s1 <= fracA_in;

            signB_s1 <= signB_in;
            expB_s1  <= expB_in;
            fracB_s1 <= fracB_in;

            signC_s1 <= signC_in;
            expC_s1  <= expC_in;
            fracC_s1 <= fracC_in;
        end
    end

    //------------------------------------------------
    // Stage 2: Multiply (mantissa) & partial exponent
    //------------------------------------------------
    // In IEEE754 normal form, we have an implicit “1.” leading bit if exponent != 0.
    // We’ll add that here. If exponent=0, it’s either denormal or zero – simplified handling here.

    reg        valid_s2;
    reg        signAB_s2; 
    reg [15:0] expAB_s2;   // bigger bit width for exponent sum
    reg [47:0] prod_s2;    // 24-bit * 24-bit = 48 bits (approx)

    reg        signC_s2;
    reg [7:0]  expC_s2;
    reg [23:0] mantC_s2;   // 1 extra bit for the “1.” if normalized

    wire [23:0] mantA_s1 = (expA_s1 == 0) ? {1'b0, fracA_s1} : {1'b1, fracA_s1};
    wire [23:0] mantB_s1 = (expB_s1 == 0) ? {1'b0, fracB_s1} : {1'b1, fracB_s1};

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_s2   <= 1'b0;
            signAB_s2  <= 1'b0;
            expAB_s2   <= 16'd0;
            prod_s2    <= 48'd0;
            signC_s2   <= 1'b0;
            expC_s2    <= 8'd0;
            mantC_s2   <= 24'd0;
        end else begin
            valid_s2   <= valid_s1;

            // Multiply sign => XOR
            signAB_s2  <= signA_s1 ^ signB_s1;

            // Add exponents (minus bias=127, simplified here)
            // We'll do: expSum = (expA + expB) - 127
            // Keep bigger bits to avoid overflow
            expAB_s2   <= (expA_s1 + expB_s1) - 127;

            // Multiply mantissa
            prod_s2    <= mantA_s1 * mantB_s1;

            // Pass along C info
            signC_s2   <= signC_s1;
            expC_s2    <= expC_s1;
            mantC_s2   <= (expC_s1 == 0) ? {1'b0, fracC_s1} : {1'b1, fracC_s1};
        end
    end

    //------------------------------------------------
    // Stage 3: Normalize partial product & align C
    //------------------------------------------------
    // We have a 48-bit product; we might need to shift it to keep an implied leading 1.
    // Also align the exponent if the product is large or small.

    reg        valid_s3;
    reg        signAB_s3;
    reg [15:0] expAB_s3;
    reg [47:0] prod_s3;

    reg        signC_s3;
    reg [7:0]  expC_s3;
    reg [23:0] mantC_s3;

    // For simplicity: assume we might shift by 1 bit if the product’s leading bit is beyond 47
    // or if it’s less. Real FP designs do a more thorough check.

    reg  [47:0] normProd_s2;
    reg  [15:0] normExp_s2;
    wire        leadingBit = prod_s2[47]; // if the leading bit is set, we have an overflow

    always @* begin
        if(leadingBit == 1'b1) begin
            // shift right by 1
            normProd_s2 = prod_s2 >> 1;
            normExp_s2  = expAB_s2 + 1;
        end else begin
            normProd_s2 = prod_s2;
            normExp_s2  = expAB_s2;
        end
    end

    // Pipeline it
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_s3   <= 1'b0;
            signAB_s3  <= 1'b0;
            expAB_s3   <= 16'd0;
            prod_s3    <= 48'd0;
            signC_s3   <= 1'b0;
            expC_s3    <= 8'd0;
            mantC_s3   <= 24'd0;
        end else begin
            valid_s3   <= valid_s2;
            signAB_s3  <= signAB_s2;
            expAB_s3   <= normExp_s2;
            prod_s3    <= normProd_s2;

            signC_s3   <= signC_s2;
            expC_s3    <= expC_s2;
            mantC_s3   <= mantC_s2;
        end
    end

    //------------------------------------------------
    // Stage 4: Add product and C
    //------------------------------------------------
    // We must compare expAB_s3 vs expC_s3 to align them if needed.
    // For simplicity, assume expAB_s3 is in the range of single-precision after stage 3.

    reg        valid_s4;
    reg [31:0] addResult_s4; 
    reg        sign_s4;

    // Convert product to a 24-bit mant (with leftover bits for fraction)
    wire [7:0] finalExpAB_s3 = (expAB_s3 > 255) ? 8'hFF : 
                               (expAB_s3 < 0)   ? 8'h00 : expAB_s3[7:0];

    // "mantProd" is top 24 bits of the 48-bit product, for the integer portion
    wire [23:0] mantProd_s3 = prod_s3[46:23]; // ignoring lower fraction bits for simplicity

    // Align the smaller exponent’s mantissa
    reg [7:0]  biggerExp;
    reg [7:0]  smallerExp;
    reg [23:0] biggerMant;
    reg [23:0] smallerMant;
    reg        biggerSign, smallerSign;

    always @* begin
        if(finalExpAB_s3 > expC_s3) begin
            biggerExp    = finalExpAB_s3;
            biggerMant   = mantProd_s3;
            biggerSign   = signAB_s3;
            smallerExp   = expC_s3;
            smallerMant  = mantC_s3;
            smallerSign  = signC_s3;
        end else begin
            biggerExp    = expC_s3;
            biggerMant   = mantC_s3;
            biggerSign   = signC_s3;
            smallerExp   = finalExpAB_s3;
            smallerMant  = mantProd_s3;
            smallerSign  = signAB_s3;
        end
    end

    // Exponent difference
    wire [7:0] expDiff = biggerExp - smallerExp;

    // Shift the smaller mantissa
    wire [23:0] alignedSmaller = (expDiff >= 24) ? 24'd0 : (smallerMant >> expDiff);

    // Add or subtract
    wire signAddDiff = biggerSign ^ smallerSign;
    reg  [24:0] mantSum;
    always @* begin
        if(signAddDiff) begin
            // subtract
            if(biggerMant >= alignedSmaller) begin
                mantSum = biggerMant - alignedSmaller;
                sign_s4 = biggerSign;
            end else begin
                mantSum = alignedSmaller - biggerMant;
                sign_s4 = ~biggerSign;
            end
        end else begin
            // same sign => addition
            mantSum = biggerMant + alignedSmaller;
            sign_s4 = biggerSign;
        end
    end

    // Pipeline stage
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_s4     <= 1'b0;
            addResult_s4 <= 32'h0;
        end else begin
            valid_s4 <= valid_s3;
            // Combine sign_s4, biggerExp, mantSum => float
            addResult_s4 <= { sign_s4,
                              biggerExp,
                              mantSum[22:0] };
        end
    end

    //------------------------------------------------
    // Stage 5: Final Normalize, Round
    //------------------------------------------------
    reg        valid_s5;
    reg [31:0] fOut_s5;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_s5 <= 1'b0;
            fOut_s5  <= 32'b0;
        end else begin
            valid_s5 <= valid_s4;
            // For simplicity, assume no further normalization needed
            // In real design, you might shift mantSum if it overflowed or if it was 0
            fOut_s5  <= addResult_s4;
        end
    end

    assign valid_out = valid_s5;
    assign F_out     = fOut_s5;

endmodule