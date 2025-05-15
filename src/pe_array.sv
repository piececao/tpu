module pe_array(
    input wire [31:0]x_input_array[15:0],
    input wire [31:0]y_input_array[15:0],

    input wire [7:0] x_position,
    input wire [7:0] y_position,
    input wire rdn,
    output reg [31:0] output_value,

    input wire master_clock,
    input wire reset_n,
    input wire [31:0]initial_value[15:0][15:0]
);

wire [31:0]data_out_arrays[15:0][15:0];

always @(negedge reset_n or negedge rdn) begin
    if(reset_n == 0)begin
        output_value <= 0;
    end
    else begin
        output_value <= data_out_arrays[x_position][y_position];
    end
end

wire [31:0]x_input_array[15:0];
wire [31:0]y_input_array[15:0];

wire [31:0]x_output_matrix[15:0][15:0];
wire [31:0]y_output_matrix[15:0][15:0];



    
genvar i,j;
generate
for(i=0;i<16;i=i+1) begin : rows
    for(j=0;j<16;j=j+1)begin : columns
    // 左上角的情况（第一行第一列位置）
    if(i==0 && j==0) begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin(initial_value[i][j]),
            .wen(reset_n),
            .x_in(x_input_array[0]),
            .y_in(y_input_array[0]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    // 第一行的情况
    else if(i==0 && j!=0)begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin(initial_value[i][j]),
            .wen(reset_n),
            .x_in(x_output_matrix[i][j-1]),
            .y_in(y_input_array[j]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    // 第一列的情况
    else if(i!=0 && j==0)begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin(initial_value[i][j]),
            .wen(reset_n),
            .x_in(x_input_array[i]),
            .y_in(y_output_matrix[i-1][j]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    else begin
        processing_element u_pe(
            .data_stored(data_out_arrays[i][j]),
            .MCLK(master_clock),
            .readin(initial_value[i][j]),
            .wen(reset_n),
            .x_in(x_output_matrix[i][j-1]),
            .y_in(y_output_matrix[i-1][j]),
            .x_out(x_output_matrix[i][j]),
            .y_out(y_output_matrix[i][j])
        );
    end
    end
end
endgenerate

endmodule