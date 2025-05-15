module fp_add (
    input  wire [31:0] a,      // 被加数
    input  wire [31:0] b,      // 加数
    output wire [31:0] result  // 和
);
    // 1. 拆字段
    wire        sign_a = a[31];
    wire [7:0]  exp_a  = a[30:23];
    wire [22:0] man_a  = a[22:0];
    wire        sign_b = b[31];
    wire [7:0]  exp_b  = b[30:23];
    wire [22:0] man_b  = b[22:0];

    // 2. 特殊值判断
    wire a_nan  = (exp_a==8'hFF) && |man_a;
    wire b_nan  = (exp_b==8'hFF) && |man_b;
    wire a_inf  = (exp_a==8'hFF) && ~|man_a;
    wire b_inf  = (exp_b==8'hFF) && ~|man_b;
    wire a_zero = (exp_a==0) && ~|man_a;
    wire b_zero = (exp_b==0) && ~|man_b;

    // 3. 规格化尾数（隐含 1）
    wire [24:0] ext_a = (exp_a==0) ? {2'b00, man_a} : {2'b01, man_a};
    wire [24:0] ext_b = (exp_b==0) ? {2'b00, man_b} : {2'b01, man_b};

    // 4. 对阶：令 A 为阶码更大者
    wire swap = {exp_a, man_a} < {exp_b, man_b};
    wire [7:0] exp_max = swap ? exp_b : exp_a;
    wire [7:0] exp_min = swap ? exp_a : exp_b;
    wire        sign_max = swap ? sign_b : sign_a;
    wire [24:0] man_max  = swap ? ext_b : ext_a;
    wire        sign_min = swap ? sign_a : sign_b;
    wire [24:0] man_min  = swap ? ext_a : ext_b;
    wire [7:0]  exp_diff = exp_max - exp_min;
    //  确定符号：
    wire sign_result = swap ? sign_b : sign_a;

    parameter GUARD = 5;

    // 5. 小阶尾数右移对齐，加上保护位
    wire [24+GUARD:0] man_min_guarded = {man_min, 5'b0} >> exp_diff;
    wire [24+GUARD:0] man_max_guarded = {man_max, 5'b0};

    // 6. 开始计算（大减小） 异号相减，同号相加
    wire op_substraction = sign_a ^ sign_b;
    wire [29:0]man_result_guarded = op_substraction 
        ? man_max_guarded - man_min_guarded 
        : man_max_guarded + man_min_guarded;
    wire [7:0]exp_result_original = exp_max;

    // 7. 前导0统计
    reg [7:0]leading_zeros;
    integer i;
    always @(*) begin
        casex (man_result_guarded)
        30'b1x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 0;
        30'b0x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 1;
        30'b00_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 2;
        30'b00_0xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 3;
        30'b00_00xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 4;
        30'b00_000x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 5;
        30'b00_0000_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 6;
        30'b00_0000_0xxx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 7;
        30'b00_0000_00xx_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 8;
        30'b00_0000_000x_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 9;
        30'b00_0000_0000_xxxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 10;
        30'b00_0000_0000_0xxx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 11;
        30'b00_0000_0000_00xx_xxxx_xxxx_xxxx_xxxx: leading_zeros = 12;
        30'b00_0000_0000_000x_xxxx_xxxx_xxxx_xxxx: leading_zeros = 13;
        30'b00_0000_0000_0000_xxxx_xxxx_xxxx_xxxx: leading_zeros = 14;
        30'b00_0000_0000_0000_0xxx_xxxx_xxxx_xxxx: leading_zeros = 15;
        30'b00_0000_0000_0000_00xx_xxxx_xxxx_xxxx: leading_zeros = 16;
        30'b00_0000_0000_0000_000x_xxxx_xxxx_xxxx: leading_zeros = 17;
        30'b00_0000_0000_0000_0000_xxxx_xxxx_xxxx: leading_zeros = 18;
        30'b00_0000_0000_0000_0000_0xxx_xxxx_xxxx: leading_zeros = 19;
        30'b00_0000_0000_0000_0000_00xx_xxxx_xxxx: leading_zeros = 20;
        30'b00_0000_0000_0000_0000_000x_xxxx_xxxx: leading_zeros = 21;
        30'b00_0000_0000_0000_0000_0000_xxxx_xxxx: leading_zeros = 22;
        30'b00_0000_0000_0000_0000_0000_0xxx_xxxx: leading_zeros = 23;
        30'b00_0000_0000_0000_0000_0000_00xx_xxxx: leading_zeros = 24;
        30'b00_0000_0000_0000_0000_0000_000x_xxxx: leading_zeros = 25;
        30'b00_0000_0000_0000_0000_0000_0000_xxxx: leading_zeros = 26;
        30'b00_0000_0000_0000_0000_0000_0000_0xxx: leading_zeros = 27;
        30'b00_0000_0000_0000_0000_0000_0000_00xx: leading_zeros = 28;
        30'b00_0000_0000_0000_0000_0000_0000_000x: leading_zeros = 29;
        30'b00_0000_0000_0000_0000_0000_0000_0000: leading_zeros = 30;
        endcase
    end

    // 指数调整
    wire [7:0]exp_result_1 = leading_zeros == 0 
        ? exp_result_original + 1
        : exp_result_original + leading_zeros - 1;
    // 小数规格化
    wire [24+GUARD:0]man_result_normalized = man_result_guarded << leading_zeros;

    // 小数舍入(结果包含溢出位和前导1)
    wire sticky = |man_result_normalized[GUARD-3:0];
    wire round = man_result_normalized[GUARD-2];
    wire need_round = man_result_normalized[GUARD-1] && (round | sticky | man_result_normalized[GUARD]);

    wire [24:0]man_result_rounded = {1'b0, man_result_normalized[24+GUARD:GUARD+1]} + need_round;

    // 处理舍入导致的溢出
    wire [22:0]man_result_final = man_result_rounded[24] == 1
        ? man_result_rounded[23:1]
        : man_result_rounded[22:0];
    wire [7:0]exp_result_final = exp_result_1 + man_result_rounded[24];

    assign result = {
        sign_result,
        exp_result_final,
        man_result_final
    };

endmodule