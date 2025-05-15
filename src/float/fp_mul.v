module fp_mul (
    input  wire [31:0] a,      // 被乘数，IEEE‑754 单精度
    input  wire [31:0] b,      // 乘数
    output wire [31:0] result  // 乘积
);
    // 1. 拆字段
    wire        sign_a = a[31];
    wire [7:0]  exp_a  = a[30:23];
    wire [22:0] man_a  = a[22:0];
    wire        sign_b = b[31];
    wire [7:0]  exp_b  = b[30:23];
    wire [22:0] man_b  = b[22:0];

    // 2. 计算符号
    wire sign_res = sign_a ^ sign_b;

    // 3. 处理特殊值：NaN、∞、零
    wire a_is_nan  = (exp_a == 8'hFF) && |man_a;
    wire b_is_nan  = (exp_b == 8'hFF) && |man_b;
    wire a_is_inf  = (exp_a == 8'hFF) && ~|man_a;
    wire b_is_inf  = (exp_b == 8'hFF) && ~|man_b;
    wire a_is_zero = (exp_a == 0) && ~|man_a;
    wire b_is_zero = (exp_b == 0) && ~|man_b;

    // 4. 普通情况的尾数扩展（隐含 1）
    wire [23:0] ext_man_a = (exp_a == 0) ? {1'b0, man_a} : {1'b1, man_a};
    wire [23:0] ext_man_b = (exp_b == 0) ? {1'b0, man_b} : {1'b1, man_b};

    // 5. 尾数相乘 => 48 位
    wire [47:0] man_prod = ext_man_a * ext_man_b;

    // 6. 阶码相加并减偏置
    wire [9:0] exp_sum = exp_a + exp_b;             // 最多 255+255=510
    wire [8:0] exp_unbiased = exp_sum - 8'd127;     // 去偏置

    // 7. 规格化：如果 man_prod[47]=1 则不用移位，否则左移 1 位
    wire       prod_msb = man_prod[47];
    wire [47:0] norm_man = prod_msb ? man_prod : (man_prod << 1);
    wire [8:0]  norm_exp = prod_msb ? (exp_unbiased + 1) : exp_unbiased;

    // 8. 舍入位和粘滞位
    wire guard_bit  = norm_man[23];      // 第 24 位
    wire round_bit  = norm_man[22];      // 第 23 位
    wire sticky_bit = |norm_man[21:0];   // 其余位或

    // 9. 舍入决定：Round to nearest, ties to even
    wire round_increment = guard_bit && (round_bit || sticky_bit || norm_man[24]);
    wire [24:0] rounded_man = norm_man[47:24] + round_increment;

    // 10. 舍入可能产生溢出（再规格化）
    wire carry_out = rounded_man[24];
    wire [7:0] final_exp = carry_out ? (norm_exp + 1) : norm_exp[7:0];
    wire [22:0] final_man = carry_out ? rounded_man[23:1] : rounded_man[22:0];

    // 11. 特殊值优先级：NaN > ∞ > 零
    assign result = a_is_nan ? {1'b0,8'hFF, 1'b1, man_a[21:0]} :
                    b_is_nan ? {1'b0,8'hFF, 1'b1, man_b[21:0]} :
                    (a_is_inf ^ b_is_inf) ? {sign_res, 8'hFF, 23'd0} :  // ∞×0 = NaN，∞×非0=∞
                    (a_is_inf || b_is_inf) ? {sign_res, 8'hFF, 23'd0} :
                    (a_is_zero || b_is_zero) ? {sign_res, 31'd0} :
                    {sign_res, final_exp, final_man};
endmodule
