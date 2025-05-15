`timescale 1ns/1ps

module pe_array_tb();

// output declaration of module pe_array
wire [31:0] output_value;
reg [31:0]x_input_array[15:0];
reg [31:0]y_input_array[15:0];

reg [7:0]x_position;
reg [7:0]y_position;

reg rdn,master_clock,reset_n;

pe_array u_pe_array(
    .x_input_array  (x_input_array ),
    .y_input_array  (y_input_array),
    .x_position   	(x_position    ),
    .y_position   	(y_position    ),
    .rdn          	(rdn           ),
    .output_value 	(output_value  ),
    .master_clock 	(master_clock  ),
    .reset_n      	(reset_n       )
);

integer i;
initial begin
    rdn = 1;
    master_clock = 0;
    reset_n = 1;
    for(i = 0; i < 16; i=i+1)begin
        //1.87
        x_input_array[i] = 32'h3FEF5C29;
    end
    for(i = 0; i < 16; i=i+1)begin
        //2.123
        y_input_array[i] = 32'h4007DF3B;
    end
    #10
    reset_n = 0;
    #10
    reset_n = 1;

    for(i=0;i<10;i=i+1)begin
        #50 master_clock = ~master_clock;
    end
    for(i = 0; i < 16; i=i+1)begin
        x_input_array[i] = 0;
    end
    for(i = 0; i < 16; i=i+1)begin
        y_input_array[i] = 0;
    end
    forever #50 master_clock = ~master_clock;
end

initial begin
    #2000 $finish();
end


endmodule