module ram_display#(
    parameter WIDTH = 480,
    parameter HEIGHT = 320
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg out_vsync,
    output reg out_href,
    output reg [23:0] out_rgb
);

    reg [11:0] row;
    reg [11:0] col;
    reg [17:0] addr;
    reg ram_ce;
    reg start_prev;

    wire [23:0] fb_dob;
    wire fb_ceb;
    wire fb_clkb;

    assign fb_clkb = clk;
    assign fb_ceb = ram_ce;

    framebuffer_ram u_framebuffer_ram( 
        .dia    (24'b0), 
        .addra  (18'b0), 
        .cea    (1'b0), 
        .clka   (clk),
        .dob    (fb_dob), 
        .addrb  (addr), 
        .ceb    (fb_ceb),
        .clkb   (clk)
    );

    // assign out_rgb = fb_dob;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row <= 0;
            col <= 0;
            addr <= 0;
            ram_ce <= 0;
            out_vsync <= 0;
            out_href <= 0;
            out_rgb <= 0;
        end else if (!start_prev && start) begin
            ram_ce <= 1;
            out_vsync <= 1;
            out_href <= 1;
            out_rgb <= fb_dob;
            row <= 0;
            col <= 0;
        end else if(out_vsync) begin
            if (row < HEIGHT) begin
                if (col < WIDTH) begin
                    out_href <= 1;
                    out_rgb <= fb_dob;
                    addr <= addr + 1;
                    col <= col + 1;
                end else begin
                    out_href <= 1;
                    out_rgb <= fb_dob;
                    addr <= addr + 1;
                    col <= 0;
                    row <= row + 1;
                end
            end 
            else begin
                out_href <= 0;
                out_vsync <= 0;
                ram_ce <= 0;
            end
        end
        start_prev <= start;
    end

endmodule