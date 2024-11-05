module mixer
#(
    parameter CH2_X0 = 0,
    parameter CH2_Y0 = 0,
    parameter CH2_X1 = 640,
    parameter CH2_Y1 = 480
)
(
    input  wire                 I_clk           ,
    input  wire                 I_rst_n         ,

    input  wire                 I_ch1_vsync     , // base channel
    input  wire                 I_ch1_href      ,
    input  wire     [23:0]      I_ch1_rgb       ,

    input  wire                 I_ch2_vsync     , // add channel
    input  wire                 I_ch2_href      ,
    input  wire     [23:0]      I_ch2_rgb       ,

    output reg                  O_post_vsync     ,
    output reg                  O_post_href      ,
    output reg      [23:0]      O_post_rgb    
);

reg [11:0] x_cnt;
reg [11:0] y_cnt;

always @(posedge I_clk or negedge I_rst_n) begin
    if (!I_rst_n) begin
        x_cnt <= 0;
        y_cnt <= 0;
        O_post_vsync <= 0;
        O_post_href <= 0;
        O_post_rgb <= 24'd0;
    end else begin
        if (I_ch1_vsync) begin
            x_cnt <= 0;
            y_cnt <= 0;
            O_post_vsync <= 1;
        end else if (!I_ch1_href) begin
            x_cnt <= 0;
            y_cnt <= y_cnt + 1;
            O_post_href <= 0;
        end else begin
            x_cnt <= x_cnt + 1;
            O_post_href <= 1;
        end

        if (x_cnt >= CH2_X0 && x_cnt < CH2_X1 && y_cnt >= CH2_Y0 && y_cnt < CH2_Y1) begin
            if (I_ch2_href) begin
                O_post_rgb <= I_ch2_rgb;
            end else begin
                O_post_rgb <= 24'b0;
            end
        end else begin
            O_post_rgb <= I_ch1_rgb;
        end

        if (!I_ch1_vsync) begin
            O_post_vsync <= 0;
        end
    end
end

endmodule