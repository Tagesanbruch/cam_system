
`define DRAM_BYTE_NUM 4
`define ALC_MC_32B
`define AXI
//`define STG 
`define APP_ADDR_WIDTH   27



module design_top_wrapper (
    /*
        input 25MHz system clock
    */
    input wire       I_sys_clk_25m,


    /*
        external key trig input 
    */
    input wire       I_key_in,
    input wire       I_ctrl_key,
    /*
        soft mcu jtag interface
    */
    input wire       I_mcu_jtag_tms,
    input wire       I_mcu_jtag_tdi,
    output wire      O_mcu_jtag_tdo,
    input wire       I_mcu_jtag_tck,

    /*
        soft mcu uart
    */
    output wire      O_mcu_uart_tx,
    input wire       I_mcu_uart_rx,

    /*
        camera sc2210 iic configure interface
    */
    inout wire       IO_sc2210_scl,
    inout wire       IO_sc2210_sda,
 
    /*
        camera sc2210 24mhz clk
    */
	output wire      O_sc2210_clk_27m,

	output wire      O_sc2210_rst_n,

	inout wire       IO_led,

    ///hdmi tmds channel signal N
	output [2:0]O_hdmi_tx_p, //HDMI输出数据P端
	output [2:0]O_hdmi_tx_n,  //HDMI输出数据N端
    output O_hdmi_clk_p,     //HDMI输出时钟P端
	output O_hdmi_clk_n,     //HDMI输出时钟N端
    
    /*
        rgmii interface
    */
    output [3:0]  rgmii_txd,
    output        rgmii_tx_ctl,
    output        rgmii_txc,
    input  [3:0]  rgmii_rxd,
    input         rgmii_rx_ctl,
    input         rgmii_rxc,

    output wire 	 fan_pwm,
    /*
        mdio interface
    */
    inout wire    mdio,
    output wire       mdc
);
	
	wire        S_sys_clk;
    wire        S_hdmi_clk;
    wire		S_serial_clk;
    wire 		I_ddr_clk;
    wire        S_Ethernet_clk;
 
    wire[19:0]  S_user_apb_PADDR;      
    wire        S_user_apb_PSEL;       
    wire        S_user_apb_PENABLE;    
    wire        S_user_apb_PWRITE;     
    wire[31:0]  S_user_apb_PWDATA;     
    wire        S_user_apb_PREADY;    
    wire[31:0]  S_user_apb_PRDATA;    
    wire        S_user_apb_PSLVERROR; 
    wire        S_user_apb_int;       
 
    wire[31:0]  S_mcu_gpio_in;
    wire[31:0]  S_mcu_gpio_out;
    wire[31:0]  S_mcu_gpio_out_en;

    wire        S_clk_70m;

    wire        S_configure_load_en;                
    wire        S_configure_done;                   
    wire[13:0]  S_HTOTAL;                           
    wire[13:0]  S_HSA;                              
    wire[13:0]  S_HFP;                              
    wire[13:0]  S_HBP;                              
    wire[13:0]  S_HACTIVE;                          
    wire[13:0]  S_VTOTAL;                           
    wire[13:0]  S_VSA;                              
    wire[13:0]  S_VFP;                              
    wire[13:0]  S_VBP;                              
    wire[13:0]  S_VACTIVE;                          
    wire        S_hdcp_en;                          
    wire        S_video_test_source_en;                         
    wire[6:0]   S_video_VIC;                               
    wire[1:0]   S_pixel_color_deep;                        
    wire[2:0]   S_video_format;                            
    wire[1:0]   S_pixel_num_per_clock;                 
    wire        S_data_over_sample_en;    
    wire[19:0]  S_audio_clock_regeneration_CTS;            
    wire[19:0]  S_audio_clock_regeneration_N;               
    wire[2:0]   S_audio_channel_number;                    
    wire[2:0]   S_audio_sample_rate;                       

    wire        S_serdes_config_load_en;                 
    wire[1:0]   S_serdes_data_width_sel;                 
    wire[2:0]   S_serdes_tx_rate;                        
    wire[23:0]  S_serdes_ref_clk_freq;                   
    wire[15:0]  S_serdes_line_rate;                      
    wire        S_serdes_mpll_sel;                       
    wire[1:0]   S_serdes_mpll_tx_clk_div;                
    wire[7:0]   S_serdes_mpll_multiplier;                
    wire        S_serdes_config_done;      

    wire        S_serdes_configure_load_en;         
 
	wire        S_pll_lock;

    wire[19:0]  S_awb_r_gain;
    wire[19:0]  S_awb_g_gain;
    wire[19:0]  S_awb_b_gain;
 
    wire[8:0]   S_data_lane3_idelay;
    wire[8:0]   S_data_lane1_idelay;
    wire[8:0]   S_data_lane2_idelay;
    wire[8:0]   S_data_lane0_idelay;
    wire[8:0]   S_clk_lane_idelay;  
    wire[9:0]   S_camera_black_level;
    wire        S_hdmi_tpg_en;

    wire        S_hs_rx_clk;           //synthesis keep  
    wire        S_hs_rx_valid;         //synthesis keep  
    wire[31:0]  S_hs_rx_data;          //synthesis keep
 
    wire        S_csi_frame_start;  //synthesis keep      
    wire        S_csi_frame_end;  //synthesis keep         
    wire        S_csi_valid;  //synthesis keep           
    wire[31:0]  S_csi_data;          
 
    wire        S_raw8_frame_start; 
    wire        S_raw8_frame_end;   
    wire        S_raw8_valid;   //synthesis keep    
    wire[31:0]  S_raw8_data;   //synthesis keep     
 
    wire        S_raw8_cut_frame_start;  
    wire        S_raw8_cut_frame_end;    
    wire        S_raw8_cut_valid;        
    wire[31:0]  S_raw8_cut_data;       
 
    wire        S_rgb888_frame_start;
    wire        S_rgb888_frame_end;
    wire        S_rgb888_valid;      
    wire[95:0]  S_rgb888_data;        

    wire        S_awb_frame_start;    //synthesis keep
    wire        S_awb_frame_end;      //synthesis keep
    wire        S_awb_valid;          //synthesis keep
    wire[95:0]  S_awb_data;           //synthesis keep

    wire        S_mipi_rx_error;         //synthesis keep

    wire        S_vi_256b_frame_start;   //synthesis keep
    wire        S_vi_256b_valid;         //synthesis keep
    wire[255:0] S_vi_256b_data;       

    wire        S_video_out_rd_busy;
    wire        S_video_in_wr_busy; 
    wire[1:0]   S_video_out_rp;     

    wire        S_ddr_user_wr_en;        //synthesis keep
    wire        S_ddr_user_rd_en;        //synthesis keep
    wire[27:0]  S_ddr_user_addr;         //synthesis keep
    wire[255:0] S_ddr_user_wr_data;      //synthesis keep
    wire        S_ddr_user_ready;        //synthesis keep
    wire        S_ddr_user_rd_valid;     //synthesis keep
    wire[255:0] S_ddr_user_rd_data;      //synthesis keep

    wire        S_vi_ddr_wr_en;   
    wire[27:0]  S_vi_ddr_wr_addr; 
    wire[255:0] S_vi_ddr_wr_data;
    wire        S_vi_ddr_wr_ready;

    wire        S_vo_ddr_rd_en;   
    wire[27:0]  S_vo_ddr_rd_addr; 
    wire        S_vo_ddr_rd_ready;

    wire        S_video_source_vsync;
    wire        S_video_source_user; 
    wire        S_video_source_valid;
    wire        S_video_source_last; 

    wire        S_vdieo_rd_en;  
    wire[95:0]  S_video_rd_data;

    wire        S_mixer_user; 
    wire        S_mixer_valid;  
    wire        S_mixer_last;   
    wire[23:0] S_mixer_data;   

    reg[9:0]    S_hdmi_config_cnt;
    reg         S_serdes_config_done_1d;

    wire        S_ddr_clk;       //synthesis keep

    wire        S_init_calib_complete;  
    wire[27:0]  S_mc_app_addr;          
    wire[2:0]   S_mc_app_cmd;           
    wire        S_mc_app_en;            
    wire[255:0] S_mc_app_wdf_data;      
    wire        S_mc_app_wdf_end;       
    wire[31:0]  S_mc_app_wdf_mask;      
    wire        S_mc_app_wdf_wren;      
    wire[255:0] S_mc_app_rd_data;       
    wire        S_mc_app_rd_data_end;   
    wire        S_mc_app_rd_data_valid; 
    wire        S_mc_app_rdy;           
    wire        S_mc_app_wdf_rdy;       

	wire[3:0]   S_lane_error;
    
    wire[9:0]   S_ts_tempture;
    
    wire  S_fifo_empty;
    wire  S_fifo_rd_valid;
    wire  S_fifo_frame_start;
    wire[9:0]  S_fifo_rd_num;
    wire[9:0]  S_fifo_wr_num;

    wire [23:0]  S_fifo_rd_data;
    reg         S_fifo_rd_en;
    
    wire 			S_csi_rx_vsync0;//synthesis keep
	wire 			S_csi_rx_hsync0;//synthesis keep

    wire [7:0] wbuf_sync_o,rbuf_sync_o;
    reg  ud_rfifo_en;
    
    wire   vtc_rstn ;
    wire   vtc_clk;
    wire   vtc_vs;//synthesis keep
    wire   vtc_hs;//synthesis keep
    //wire   vtc_user;//synthesis keep
    wire   vtc_de_valid;//synthesis keep
    //wire   vtc_last;////synthesis keep
   
    wire S_rst;
    wire [7 :0]	rgb_r ,rgb_g ,rgb_b;// 定义寄存器保存图像的颜色数据
    assign vtc_clk = S_hdmi_clk; // 内部像素时钟
    assign vtc_rstn = S_pll_lock; //用PLL 的LOCK信号复位
    assign S_rst = ~S_pll_lock;


    wire ud_wclk,ud_wvs,ud_wde;
    wire [31:0] ud_wdata;//synthesis keep
    wire ud_rclk,ud_rvs,ud_rde;
    wire [31:0] ud_rdata;//synthesis keep
    wire [23:0] video_hdmi_data;
    
    assign S_Ethernet_clk = I_sys_clk_25m;

	PLL U_PLL(
  		.refclk   ( I_sys_clk_25m          ),
  		.lock     ( S_pll_lock             ),
        .reset	  (	~I_key_in			   ), 
 
  		.clk0_out ( O_sc2210_clk_27m             ),
  		.clk1_out ( S_sys_clk              ),
        .clk2_out ( S_clk_70m              ),
        .clk3_out ( S_hdmi_clk       ),  //像素时钟
        .clk4_out (	S_serial_clk			   ),//HDMI IO的serdes 时钟 5倍的像素时钟
        .clk5_out (	I_ddr_clk			   )
	);

	assign O_sc2210_rst_n = 1'b1;

    ///led
    assign IO_led = S_mcu_gpio_out_en[0] ? S_mcu_gpio_out[0] : 1'bz;
	assign S_mcu_gpio_in[0] = IO_led;

    ///sc2210 iic scl
    assign IO_sc2210_scl    = S_mcu_gpio_out_en[1] ? S_mcu_gpio_out[1] : 1'bz;
    assign S_mcu_gpio_in[1] = IO_sc2210_scl;

    ///sc2210 iic sda
    assign IO_sc2210_sda    = S_mcu_gpio_out_en[2] ? S_mcu_gpio_out[2] : 1'bz;
    assign S_mcu_gpio_in[2] = IO_sc2210_sda;
    
    ///fan 
    assign fan_pwm = 1'b1;


    soft_ps_wrapper#(
        .SYSCLK               ( 70000000                  ),
        .DEV_SERIES           ( "PH1"                     ),
        .CORE_TYPE            ( "MEDIUM"                  ),
        .TCM0_SIZE            ( 32*1024                   ),
        .TCM0_INITFILE        ( "SC2210_HDMI_1080P.bin.mif" ),
        .TCM0_RAMSTYLE        ( "20K"                     ),
        .UART1_BAUDRATE       ( 115200                    ),
        .MTIME_ENABLE         ( 1'b0                      ),
        .GPIO_PINNUM          ( 32                        ),
        .GPIO_INTENABLE       ( 1'b1                      ),
        .GPIO_INTCFG          ( {45'h0,3'b101,48'h0}      )
    )u_soft_ps_wrapper(
        .I_clk                ( S_clk_70m            ),
        .I_rst                ( S_rst 	             ),//

        .I_mcu_jtag_tms       ( I_mcu_jtag_tms       ),
        .I_mcu_jtag_tdi       ( I_mcu_jtag_tdi       ),
        .O_mcu_jtag_tdo       ( O_mcu_jtag_tdo       ),
        .I_mcu_jtag_tck       ( I_mcu_jtag_tck       ),

        .I_gpio_in            ( S_mcu_gpio_in        ),
        .O_gpio_out           ( S_mcu_gpio_out       ),
        .O_gpio_out_en        ( S_mcu_gpio_out_en    ),
        
        .O_uart1_tx           (         ),
        .I_uart1_rx           (         ),

        .O_user_apb_PADDR     ( S_user_apb_PADDR     ),
        .O_user_apb_PSEL      ( S_user_apb_PSEL      ),
        .O_user_apb_PENABLE   ( S_user_apb_PENABLE   ),
        .O_user_apb_PWRITE    ( S_user_apb_PWRITE    ),
        .O_user_apb_PWDATA    ( S_user_apb_PWDATA    ),
        .I_user_apb_PREADY    ( S_user_apb_PREADY    ),
        .I_user_apb_PRDATA    ( S_user_apb_PRDATA    ),
        .I_user_apb_PSLVERROR ( S_user_apb_PSLVERROR ),
        .I_user_apb_int       ( S_user_apb_int       ),

        .I_spi_miso           (  ),
        .O_spi_mosi           (  ),
        .O_spi_clk            (  ),
        .O_spi_cs             (  ),

        .I_spi2_miso          (  ),
        .O_spi2_mosi          (  ),
        .O_spi2_clk           (  ),
        .O_spi2_cs            (  ),

        .O_uart2_tx           (  ),
        .I_uart2_rx           (  ),

        .IO_i2c_scl           (  ),
        .IO_i2c_sda           (  )
    );


    apd_to_register u_apd_to_register(
        .I_clk               ( S_clk_70m            ),
        .I_rst_n             ( ~S_rst               ),
                             
        .I_apb_paddr         ( S_user_apb_PADDR     ),
        .I_apb_psel          ( S_user_apb_PSEL      ),
        .I_apb_penable       ( S_user_apb_PENABLE   ),
        .I_apb_pwrite        ( S_user_apb_PWRITE    ),
        .I_apb_pwdata        ( S_user_apb_PWDATA    ),
        .O_apb_pready        ( S_user_apb_PREADY    ),
        .O_apb_prdata        ( S_user_apb_PRDATA    ),
        .O_apb_pslverror     ( S_user_apb_PSLVERROR ),
        .O_apb_int           ( S_user_apb_int       ),
                             
        .I_pl_version        ( 32'h20230215         ),
       	.I_ts_tempture		 (	S_ts_tempture		),
        .O_awb_r_gain        ( S_awb_r_gain         ),
        .O_awb_g_gain        ( S_awb_g_gain         ),
        .O_awb_b_gain        ( S_awb_b_gain         ),
    	.O_data_lane3_idelay ( S_data_lane3_idelay  ),
    	.O_data_lane1_idelay ( S_data_lane1_idelay  ),
    	.O_data_lane2_idelay ( S_data_lane2_idelay  ),
    	.O_data_lane0_idelay ( S_data_lane0_idelay  ),
    	.O_clk_lane_idelay   ( S_clk_lane_idelay    ),
        .O_camera_black_level( S_camera_black_level ),
        //.O_hdmi_dp159_oe     ( O_hdmi_tx_en_0       ),
        .O_hdmi_tpg_en       ( S_hdmi_tpg_en        )
    );

localparam  AXI_ADDR_WIDTH = `APP_ADDR_WIDTH +2;
localparam  AXI_DATA_WIDTH = `DRAM_BYTE_NUM*8*8;

wire [AXI_ADDR_WIDTH-1:  0]      fdma_waddr;   //FDMA写通道地址
wire                             fdma_wareq;   //FDMA写通道请求
wire [15: 0]                     fdma_wsize;   //FDMA写通道一次FDMA的传输大小                                       
wire                             fdma_wbusy;   //FDMA处于BUSY状态，AXI总线正在写操作 		
wire [AXI_DATA_WIDTH-1 : 0]      fdma_wdata;   //FDMA写数据
wire                             fdma_wvalid;  //FDMA 写有效
wire                             fdma_wready;  //FDMA写准备好，用户可以写数据

wire [AXI_ADDR_WIDTH-1:  0]      fdma_raddr;   //synthesis keep     //FDMA读通道地址
wire                             fdma_rareq;   //FDMA读通道请求
wire [15: 0]                     fdma_rsize;   //FDMA读通道一次FDMA的传输大小                                       
wire                             fdma_rbusy;   //FDMA处于BUSY状态，AXI总线正在读操作 			
wire [AXI_DATA_WIDTH-1 : 0]      fdma_rdata;   //FDMA读数据
wire                             fdma_rvalid;  //FDMA 读有效
wire                             fdma_rready;  //FDMA读准备好，用户可以读数据	

wire                             O_axi_clk;
wire                             pll_locked;

//例化APP接口转AXI接口
uifdma_axi_ddr#
(
.SIMULATION      ("TRUE")   ,//"TRUE"   
.APP_ADDR_WIDTH  (`APP_ADDR_WIDTH)     ,  // 128 x 16bit                
.AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH)     ,                                     
.AXI_DATA_WIDTH  (`DRAM_BYTE_NUM*8*8) ,
.APP_DATA_WIDTH  (`DRAM_BYTE_NUM*8*8) ,
.APP_MASK_WIDTH  (`DRAM_BYTE_NUM * 8)  
)
u_uifdma_axi_ddr
(
.I_ddr_clk                       ( I_sys_clk_25m    ),
.I_sys_rstn                      ( ~S_rst         ),
.O_ddr_pll_locked                ( pll_locked   ),

// DDR signals
.ddr_reset_n                     ( ddr_reset_n  ),
.ddr_addr                        ( ddr_addr     ),
.ddr_ba                          ( ddr_ba       ),
.ddr_ck_p                        ( ddr_ck_p     ),
.ddr_ck_n                        ( ddr_ck_n     ),
.ddr_cke                         ( ddr_cke      ),
.ddr_cs_n                        ( ddr_cs_n     ),
.ddr_ras_n                       ( ddr_ras_n    ),
.ddr_cas_n                       ( ddr_cas_n    ),
.ddr_we_n                        ( ddr_we_n     ),
.ddr_odt                         ( ddr_odt      ),
.ddr_dqs_p                       ( ddr_dqs_p    ),
.ddr_dqs_n                       ( ddr_dqs_n    ),
.ddr_dq                          ( ddr_dq       ),
.ddr_dm                          ( ddr_dm       ),

.O_uart_txd                      (O_uart_txd    ),
.I_uart_rxd                      (I_uart_rxd    ),

.O_axi_clk                       (O_axi_clk     ),

.I_fdma_waddr                    (fdma_waddr)    ,// FDMA写通道地址
.I_fdma_wareq                    (fdma_wareq)    ,// FDMA写通道请求
.I_fdma_wsize                    (fdma_wsize)    ,// FDMA写通道一次FDMA的传输大小                                            
.O_fdma_wbusy                    (fdma_wbusy)    ,// FDMA处于BUSY状态，AXI总线正在写操作  
				
.I_fdma_wdata                    (fdma_wdata)    ,// FDMA写数据
.O_fdma_wvalid                   (fdma_wvalid)   ,// FDMA 写有效
.I_fdma_wready                   (1'b1)		     ,// FDMA写准备好，用户可以写数据

.I_fdma_raddr                    (fdma_raddr)    ,// FDMA读通道地址
.I_fdma_rareq                    (fdma_rareq)    ,// FDMA读通道请求
.I_fdma_rsize                    (fdma_rsize)    ,// FDMA读通道一次FDMA的传输大小                                      
.O_fdma_rbusy                    (fdma_rbusy)    ,// FDMA处于BUSY状态，AXI总线正在读操作 
				
.O_fdma_rdata                    (fdma_rdata)    ,// FDMA读数据
.O_fdma_rvalid                   (fdma_rvalid)   ,// FDMA 读有效
.I_fdma_rready                   (1'b1)		     // FDMA读准备好，用户可以读数据
);


 
    assign ud_wclk   = S_hs_rx_clk;//S_hdmi_clk;//S_sys_clk;//S_hs_rx_clk;
    assign ud_wvs    = S_csi_rx_vsync0;//S_rgb888_frame_start;//vtc_vs;
    assign ud_wde    = S_raw8_cut_valid;//S_fifo_rd_valid;//S_fifo_rd_en & (~S_fifo_empty);////vtc_de;
    assign ud_wdata  = S_raw8_cut_data;//pixelcont;//S_raw8_cut_data;//{8'd0,S_fifo_rd_data};//S_awb_data;//{8'd0,S_fifo_rd_data};//{8'd0,rgb_r,rgb_g,rgb_b};

    assign ud_rclk   = S_hdmi_clk;
    assign ud_rvs    = vtc_vs;
    assign ud_rde    = ud_rfifo_en;//vtc_de_valid_d1;//ud_rfifo_en;
    // assign video_hdmi_data  = ud_rdata[23:0];

    //例化uidbuf 控制器 
    uidbuf# (
    .VIDEO_ENABLE(1'b1),  
    .ENABLE_WRITE(1'b1), 
    .ENABLE_READ(1'b1), 
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),

    .W_BUFDEPTH(1024),
    .W_DATAWIDTH(32),//32
    .W_BASEADDR(0),
    .W_DSIZEBITS(25),//23
    .W_XSIZE(480),
    .W_XSTRIDE(480),
    .W_YSIZE(1080), 
    .W_XDIV(1), //2
    .W_BUFSIZE(3),

    .R_BUFDEPTH(1024),
    .R_DATAWIDTH(32),
    .R_BASEADDR(0),
    .R_DSIZEBITS(25),//23
    .R_XSIZE(480),
    .R_XSTRIDE(480),
    .R_YSIZE(1080),
    .R_XDIV(1),//2
    .R_BUFSIZE(3)
    )
    uidbuf_u0
    (
    .I_ui_clk(O_axi_clk),
    .I_ui_rstn(pll_locked),

    .I_W_FS(ud_wvs),
    .I_W_clk(ud_wclk),
    .I_W_wren(ud_wde),
    .I_W_data(ud_wdata), 
    .O_W_sync_cnt(wbuf_sync_o),
    .I_W_buf(wbuf_sync_o),
    .O_W_full(),

    .I_R_FS(ud_rvs),
    .I_R_clk(ud_rclk),
    .I_R_rden(ud_rde),
    .O_R_data(ud_rdata),
    .O_R_sync_cnt(),
    .I_R_buf(rbuf_sync_o),
    .O_R_empty(),
        
    .O_fdma_waddr(fdma_waddr)  ,
    .O_fdma_wareq(fdma_wareq)  ,
    .O_fdma_wsize(fdma_wsize)  ,                                     
    .I_fdma_wbusy(fdma_wbusy)  ,			
    .O_fdma_wdata(fdma_wdata)	 ,
    .I_fdma_wvalid(fdma_wvalid),
    .O_fdma_wready(fdma_wready),
    .O_fdma_raddr(fdma_raddr)  ,
    .O_fdma_rareq(fdma_rareq)  ,
    .O_fdma_rsize(fdma_rsize)  ,                                     
    .I_fdma_rbusy(fdma_rbusy)  ,			
    .I_fdma_rdata(fdma_rdata)	 ,
    .I_fdma_rvalid(fdma_rvalid),
    .O_fdma_rready(fdma_rready),
    .O_fmda_wbuf  (fdma_wbuf),	
    .O_fdma_wirq  (fdma_wirq),		
    .O_fmda_rbuf  (fdma_rbuf),	
    .O_fdma_rirq  (fdma_rirq)
    ); 

    //设置3帧缓存，读延迟写1帧
    uisetvbuf#( 
    .BUF_DELAY(1), 
    .BUF_LENTH(3)
    )
    uisetvbuf_u
    (
    .bufn_i(wbuf_sync_o),
    .bufn_o(rbuf_sync_o)
    ); 


    //以下代码需要注意时序设计，在正确的时序输出
    reg [1 :0] ud_rdata_cnt; //synthesis keep
    reg [7 :0] ud_rdata_d1;//synthesis keep
   // reg  vtc_user_d1;//synthesis keep
   // reg  vtc_last_d1;//synthesis keep
    reg  vtc_de_valid_d1; //synthesis keep

    always @(posedge vtc_clk) begin
        if(vtc_de_valid)
            ud_rdata_cnt <= ud_rdata_cnt + 'd1;
        else 
            ud_rdata_cnt <= 0;
    end

    always @(posedge vtc_clk) begin
           // vtc_user_d1     <= vtc_user;
           // vtc_last_d1     <= vtc_last;
            vtc_de_valid_d1 <= vtc_de_valid;
    end

    // 当vtc_de_valid = 1 ud_rdata_cnt =1 读1个数据，但是ud_rfifo_en延迟1个周期输出1，fifo再延迟1个周期更新数据
    always @(posedge vtc_clk) begin
        ud_rfifo_en <=  (ud_rdata_cnt == 1);
    end

    always @(posedge vtc_clk) begin
        if(vtc_de_valid)begin
            case(ud_rdata_cnt)
                'd0: ud_rdata_d1 <=  ud_rdata[31:24]; 
                'd1: ud_rdata_d1 <=  ud_rdata[23:16]; 
                'd2: ud_rdata_d1 <=  ud_rdata[15: 8];
                'd3: ud_rdata_d1 <=  ud_rdata[7 : 0];
            default:
                ud_rdata_d1 <= ud_rdata_d1;
        endcase
        end
        else 
            ud_rdata_d1 <=0;
    end

    wire 			w_rgb_vsync, w_rgb_href; //synthesis keep
    wire 	[7:0] 	w_rgb_r, w_rgb_g, w_rgb_b; 


    raw8_2_rgb888 #(
    .H_SIZE(1920), 
    .V_SIZE(1080)
    )u_raw8_2_rgb888 
    (
    .I_clk	        (vtc_clk),                //cmos video pixel clock
    .I_rst_n	    (vtc_rstn),              //global reset
            
    //CMOS YCbCr444 data output
    .I_raw_vs	    (~vtc_vs),    //Prepared Image data vsync valid signal. Reset on falling edge. 
    .I_raw_de	    (vtc_de_valid_d1),     //Prepared Image data href vaild  signal
    .I_raw_data	    (ud_rdata_d1),        //Prepared Image data 8 Bit RAW Data

    .O_rgb_vs	    (w_rgb_vsync),   //Processed Image data vsync valid signal
    .O_rgb_de	    (w_rgb_href),    //Processed Image data href vaild  signal
    .O_rgb_r		(w_rgb_r),       //Prepared Image green data to be processed 
    .O_rgb_g	    (w_rgb_g),     //Prepared Image green data to be processed
    .O_rgb_b		(w_rgb_b)       //Prepared Image blue data to be processed
    );

    // image processing

    wire 			w_awb_vs, w_awb_hs, w_awb_de; 
    wire 	[7:0] 	w_awb_r, w_awb_g, w_awb_b;
    awb u_awb 
    (
    .I_clk          (vtc_clk),
    .I_rst_n        (vtc_rstn),

    .I_red_gain     (0),
    .I_green_gain   (0),
    .I_blue_gain    (0),

    .I_awb_vs       (w_rgb_vsync),
    .I_awb_hs       (w_rgb_href),
    .I_awb_de       (w_rgb_href),
    .I_awb_rgb      ({w_rgb_r, w_rgb_g, w_rgb_b}),

    .O_awb_vs       (w_awb_vs),
    .O_awb_hs       (w_awb_hs),
    .O_awb_de       (w_awb_de),
    .O_awb_rgb      ({w_awb_r, w_awb_g, w_awb_b})
    );

    

    wire 			w_crop_vs, w_crop_hs;//synthesis keep 
    wire			w_crop_de;//synthesis keep
    wire 	[23:0] 	w_crop_data;//synthesis keep

    bound_cut u_bound_cut 
    (
    .I_clk		    (vtc_clk),
    .I_awb_vs 		(w_awb_vs),
    .I_awb_hs 		(w_awb_hs),
    .I_awb_de 		(w_awb_de),
    .I_awb_data 	({w_awb_r, w_awb_g, w_awb_b}),
            
    .O_awb_vs 		(w_crop_vs),
    .O_awb_hs 		(w_crop_hs),
    .O_awb_de 		(w_crop_de),
    .O_awb_data     (w_crop_data)
    );

    wire clk  			;
    wire rst_n			;
    wire per_frame_vsync;
    wire per_frame_href;
    wire per_frame_clken;
    wire [7:0] per_img_red		;
    wire [7:0] per_img_green		;
    wire [7:0] per_img_blue		;
    wire post_frame_vsync;
    wire post_frame_href;
    wire post_frame_clken;
    wire post_img_Bit;
    wire [7:0] Sobel_Threshold;
	wire [23:0]post_img_pixel;
    wire [7:0] post_img_Y		;
    wire [7:0] state;

    assign clk  			    =       vtc_clk        ;
    assign rst_n			    =       vtc_rstn              ;
    assign per_frame_vsync      =       w_crop_vs;  
    assign per_frame_href       =       w_crop_de;   
    assign per_frame_clken      =       w_crop_de;      
    assign per_img_red		    =       w_crop_data[23:16];
    assign per_img_green		=       w_crop_data[15:8];
    assign per_img_blue		    =       w_crop_data[7:0];
    assign Sobel_Threshold      =       8'd20;
    assign post_img_pixel 		=  		(state > 15) ? {24{post_img_Bit}} : {post_img_Y, post_img_Y, post_img_Y};
//    assign post_img_pixel 		=  		S_rx_axis_m_data;
    
    Video_Image_Processor#(
        .IMG_HDISP(12'd1920),	//1280*720
        .IMG_VDISP(12'd1080)
    )u_Video_Image_Processor
    (
        //global clock
        .clk  			    (clk  			),       //cmos video pixel clock
        .rst_n			    (rst_n			),       //global reset
        .per_frame_vsync    (per_frame_vsync),       //Prepared Image data vsync valid signal
        .per_frame_href     (per_frame_href),	        //Prepared Image data href vaild  signal
        .per_frame_clken    (per_frame_clken),       //Prepared Image data output/capture enable clock
        .per_img_red		(per_img_red		),
        .per_img_green		(per_img_green		),
        .per_img_blue		(per_img_blue		),
        .post_frame_vsync   (post_frame_vsync),	        //Processed Image data vsync valid signal
        .post_frame_href    (post_frame_href),       //Processed Image data href vaild  signal
        .post_frame_clken   (post_frame_clken),	    //Processed Image data output/capture enable clock
        .post_img_Bit	    (post_img_Bit),
        .post_img_Y         (post_img_Y),       //Processed Image brightness output
        .Sobel_Threshold    (Sobel_Threshold)		//Sobel Threshold for image edge detect	
    );

    uivtc#
    (
    .H_ActiveSize       (1920), //视频时间参数,行视频信号，一行有效(需要显示的部分)像素所占的时钟数，一个时钟对应一个有效像素
    .H_SyncStart        (1920+88), //视频时间参数,行同步开始，即多少时钟数后开始产生行同步信号 
    .H_SyncEnd          (1920+88+44),//视频时间参数,行同步结束，即多少时钟数后停止产生行同步信号，之后就是行有效数据部分
    .H_FrameSize        (1920+88+44+148), //视频时间参数,行视频信号，一行视频信号总计占用的时钟数

    .V_ActiveSize       (1080),//视频时间参数,场视频信号，一帧图像所占用的有效(需要显示的部分)行数量，通常说的视频分辨率即H_ActiveSize*V_ActiveSize
    .V_SyncStart        (1080+4),//视频时间参数,场同步开始，即多少行数后开始产生场同步信号 
    .V_SyncEnd          (1080+4+5), //视频时间参数,场同步结束，多少行后停止产生长同步信号  
    .V_FrameSize        (1080+4+5+36) //视频时间参数,场视频信号，一帧视频信号总计占用的行数量       
    )
    uivtc_inst
    (
    .I_vtc_clk(vtc_clk),  //系统时钟 
    .I_vtc_rstn(vtc_rstn),//系统复位
    .O_vtc_vs  (vtc_vs),//场同步输出
    .O_vtc_hs  (vtc_hs),//行同步输出
    .O_vtc_de_valid(vtc_de_valid)//视频数据有效
    );


    //hdmi 输出IP
    hdmi_tx#(
    //HDMI视频参数设置       
    .H_ActiveSize       (1920), //视频时间参数,行视频信号，一行有效(需要显示的部分)像素所占的时钟数，一个时钟对应一个有效像素
    .H_SyncStart        (1920+88), //视频时间参数,行同步开始，即多少时钟数后开始产生行同步信号 
    .H_SyncEnd          (1920+88+44),//视频时间参数,行同步结束，即多少时钟数后停止产生行同步信号，之后就是行有效数据部分
    .H_FrameSize        (1920+88+44+148), //视频时间参数,行视频信号，一行视频信号总计占用的时钟数

    .V_ActiveSize       (1080),//视频时间参数,场视频信号，一帧图像所占用的有效(需要显示的部分)行数量，通常说的视频分辨率即H_ActiveSize*V_ActiveSize
    .V_SyncStart        (1080+4),//视频时间参数,场同步开始，即多少行数后开始产生场同步信号 
    .V_SyncEnd          (1080+4+5), //视频时间参数,场同步结束，多少行后停止产生长同步信号  
    .V_FrameSize        (1080+4+5+36),  //视频时间参数,场视频信号，一帧视频信号总计占用的行数量               
        
    .VIDEO_VIC          ( 16       ),
    .VIDEO_TPG          ( "Disable"),//设置disable，用户数据驱动HDMI接口，否则设置eable产生内部测试图形
    .VIDEO_FORMAT       ( "RGB444" )//设置输入数据格式为RGB格式
    )u_hdmi_tx
    (
    .I_pixel_clk        ( S_hdmi_clk           ),//像素时钟
    .I_serial_clk       ( S_serial_clk           ),//串行发送时钟
    .I_rst              ( S_rst              ),//异步复位信号，高电平有效

    .I_video_rgb_enable (1'b1                ),//是否使能RGB输入接口，设置1使能，否则采用stream video时序接口  
    .I_video_in_vs      (post_frame_vsync            ),//RGB 输入VS 帧同步
    .I_video_in_de      (post_frame_href            ),//RGB 输入de有效
    .I_video_in_data    (post_img_pixel   ), //视频输入数据     

    .O_hdmi_clk_p       ( O_hdmi_clk_p       ),//HDMI时钟通道
    .O_hdmi_tx_p        ( O_hdmi_tx_p        )//HDMI数据通道
    );


    video_cutting u_video_cutting(
        .I_clk              ( S_hs_rx_clk            ),
        .I_rst_n            ( ~S_rst                 ),
    
        .I_raw8_frame_start ( S_raw8_frame_start     ),
        .I_raw8_frame_end   ( S_raw8_frame_end       ),
        .I_raw8_valid       ( S_raw8_valid           ),
        .I_raw8_data        ( S_raw8_data            ),

        .O_raw8_frame_start ( S_raw8_cut_frame_start ),
        .O_raw8_frame_end   ( S_raw8_cut_frame_end   ),
        .O_raw8_valid       ( S_raw8_cut_valid       ),
        .O_raw8_data        ( S_raw8_cut_data        )
    );


    raw10_unpacket u_raw10_unpacket(
        .I_clk                ( S_hs_rx_clk          ), 
        .I_rst_n              ( ~S_rst               ),
                                                     
        .I_csi_frame_start    ( S_csi_frame_start    ),
        .I_csi_frame_end      ( S_csi_frame_end      ),
        .I_csi_valid          ( S_csi_valid          ),
        .I_csi_data           ( S_csi_data           ),
        
       	.I_camera_black_level ( S_camera_black_level ),

        .O_raw8_frame_start   ( S_raw8_frame_start   ),
        .O_raw8_frame_end     ( S_raw8_frame_end     ),
        .O_raw8_valid         ( S_raw8_valid         ),
        .O_raw8_data          ( S_raw8_data          )
    );


    csi_unpacket u_csi_unpacket(
        .I_clk             ( S_hs_rx_clk       ),
        .I_rst_n           ( ~S_rst            ),

        .I_hs_valid        ( S_hs_rx_valid     ),
        .I_hs_data         ( S_hs_rx_data      ),

        .O_csi_frame_start ( S_csi_frame_start ),
        .O_csi_frame_end   ( S_csi_frame_end   ),
        .O_csi_rx_vsync0	( S_csi_rx_vsync0	),
    	.O_csi_rx_hsync0	( S_csi_rx_hsync0	),
        .O_csi_valid       ( S_csi_valid       ),
        .O_csi_data        ( S_csi_data        )
    );


    mipi_dphy_rx_ph1a_mipiio_wrapper#(
        .LANE_NUM              ( 4 ),
        .BYTE_NUM              ( 1 )
    )u_mipi_dphy_rx_ph1a_mipiio_wrapper(
        .I_lp_clk              ( S_clk_70m       ), 
        .I_rst                 ( S_rst           ),
 
        .I_clk_lane_in_delay   ( 9'd0            ),
        .I_data_lane0_in_delay ( 9'd0            ),
        .I_data_lane1_in_delay ( 9'd0            ),
        .I_data_lane2_in_delay ( 9'd0            ),
        .I_data_lane3_in_delay ( 9'd0            ),

        .I_lane_invert         ( 4'b0000         ),//1101 

        .O_hs_rx_clk           ( S_hs_rx_clk     ),
        .O_hs_rx_valid         ( S_hs_rx_valid   ),
        .O_hs_rx_data          ( S_hs_rx_data    ),

        .O_lp_rx_lane0_p       (  ),
        .O_lp_rx_lane0_n       (  ),

        .I_lp_tx_en            ( 1'b0            ),
        .I_lp_tx_lane0_p       ( 1'b0            ),
        .I_lp_tx_lane0_n       ( 1'b0            ),

        .O_lane_error          ( S_lane_error    )
    );

    
    al_temac u_al_temac(
    //   // 异步复位
    //   input         reset_n,
    //   // 时钟
    //   input wire    sysclk_P,
    //   // RGMII 接口
    //   output [3:0]  rgmii_txd,
    //   output        rgmii_tx_ctl,
    //   output        rgmii_txc,
    //   input  [3:0]  rgmii_rxd,
    //   input         rgmii_rx_ctl,
    //   input         rgmii_rxc,
    //   // MDIO 接口
    //   //---------------
    //   inout         mdio,
    //   output        mdc
    .reset_n (~S_rst),
    .sysclk_P (S_Ethernet_clk),
    .rgmii_txd (rgmii_txd),
    .rgmii_tx_ctl (rgmii_tx_ctl),
    .rgmii_txc (rgmii_txc),
    .rgmii_rxd (rgmii_rxd),
    .rgmii_rx_ctl (rgmii_rx_ctl),
    .rgmii_rxc (rgmii_rxc),
    .mdio (mdio),
    .mdc (mdc)
    );
    
    wire [1:0] I_key;
    
    assign I_key[0] = 1'b0;
    assign I_key[1] = I_ctrl_key;
    
    // Key in
    state_control (
        .clk(I_sys_clk_25m),
        .rst_n(I_key_in),
        .I_Key(I_Key),
        .state(state)
    );

endmodule