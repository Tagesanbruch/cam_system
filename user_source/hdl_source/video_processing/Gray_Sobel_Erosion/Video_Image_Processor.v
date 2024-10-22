/*-----------------------------------------------------------------------
								 \\\|///
							   \\  - -  //
								(  @ @  )
+-----------------------------oOOo-(_)-oOOo-----------------------------+
CONFIDENTIAL IN CONFIDENCE
This confidential and proprietary software may be only used as authorized
by a licensing agreement from CrazyBingo (Thereturnofbingo).
In the event of publication, the following notice is applicable:
Copyright (C) 2013-20xx CrazyBingo Corporation
The entire notice above must be reproduced on all authorized copies.
Author				:		CrazyBingo
Technology blogs 	: 		www.crazyfpga.com
Email Address 		: 		crazyfpga@vip.qq.com
Filename			:		Video_Image_Processor.v
Date				:		2013-05-26
Description			:		Video Image processor module.
Modification History	:
Date			By			Version			Change Description
=========================================================================
13/05/25		CrazyBingo	1.0				Original
14/03/16		CrazyBingo	2.0				Modification
-------------------------------------------------------------------------
|                                     Oooo								|
+-------------------------------oooO--(   )-----------------------------+
                               (   )   ) /
                                \ (   (_/
                                 \_)
-----------------------------------------------------------------------*/   

`timescale 1ns/1ns
module Video_Image_Processor
#(
	parameter	[11:0]	IMG_HDISP = 12'd1280,	//1280*720
	parameter	[11:0]	IMG_VDISP = 12'd720
)
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock
	// input		[7:0]	per_img_Y,			//Prepared Image brightness input
    input 				per_frame_hsync,
	input 		[7:0]	per_img_red,		//Prepared Image red data input
	input 		[7:0]	per_img_green,		//Prepared Image green data input
	input 		[7:0]	per_img_blue,		//Prepared Image blue data input

	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
    output 				post_frame_hsync,
	output				post_img_Bit,		//Processed Image Bit flag outout(1: Value, 0:inValid)
	output 		[7:0]	post_img_Y,		//Processed Image brightness output	

	//user interface
	input		[7:0]	Sobel_Threshold		//Sobel Threshold for image edge detect	
);

wire 		mid1_frame_vsync;
wire 		mid1_frame_href;
wire 		mid1_frame_clken;
wire 		mid1_frame_hsync;
wire [7:0]	mid1_img_Y;
wire [7:0]	mid1_img_Cb;		
wire [7:0]	mid1_img_Cr;		

//-------------------------------------
//Convert the RGB888 format to YCbCr444 format.
Image_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
(
	//global clock
	.clk				(clk),					//cmos video pixel clock
	.rst_n				(rst_n),				//system reset

	//Image data prepred to be processd
	.per_frame_vsync	(per_frame_vsync),		//Prepared Image data vsync valid signal
	.per_frame_href		(per_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken	(per_frame_clken),		//Prepared Image data output/capture enable clock
    .per_frame_hsync	(per_frame_hsync),
	.per_img_red		(per_img_red),			//Prepared Image red data input
	.per_img_green		(per_img_green),		//Prepared Image green data input
	.per_img_blue		(per_img_blue),			//Prepared Image blue data input
	
	//Image data has been processd
	.post_frame_vsync	(mid1_frame_vsync),		//Processed Image frame data valid signal
	.post_frame_href	(mid1_frame_href),		//Processed Image hsync data valid signal
	.post_frame_clken	(mid1_frame_clken),		//Processed Image data output/capture enable clock
    .post_frame_hsync 	(mid1_frame_hsync),
	.post_img_Y			(mid1_img_Y),			//Processed Image brightness output
	.post_img_Cb		(mid1_img_Cb),			//Processed Image blue shading output
	.post_img_Cr		(mid1_img_Cr)			//Processed Image red shading output
);

//--------------------------------------
//Image edge detector with Sobel.
wire			post1_frame_vsync;	//Processed Image data vsync valid signal
wire			post1_frame_href;	//Processed Image data href vaild  signal
wire			post1_frame_clken;	//Processed Image data output/capture enable clock
wire			post1_img_Bit;		//Processed Image Bit flag outout(1: Value, 0:inValid)
VIP_Sobel_Edge_Detector
#(
	.IMG_HDISP	(IMG_HDISP),	//1280*720
	.IMG_VDISP	(IMG_VDISP)
)
u_VIP_Sobel_Edge_Detector
(
	//global clock
	.clk					(clk),  				//cmos video pixel clock
	.rst_n					(rst_n),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync		(mid1_frame_vsync),		//Prepared Image data vsync valid signal
	.per_frame_href			(mid1_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken		(mid1_frame_clken),		//Prepared Image data output/capture enable clock
	.per_frame_hsync		(mid1_frame_hsync),		//Prepared Image data vsync valid signal
	.per_img_Y				(mid1_img_Y),			//Prepared Image brightness input

	//Image data has been processd
	.post_frame_vsync		(post1_frame_vsync),		//Processed Image data vsync valid signal
	.post_frame_href		(post1_frame_href),		//Processed Image data href vaild  signal
	.post_frame_clken		(post1_frame_clken),		//Processed Image data output/capture enable clock
	.post_frame_hsync		(post1_frame_hsync),		//Processed Image data vsync valid signal
	.post_img_Bit			(post1_img_Bit),			//Processed Image Bit flag outout(1: Value, 0:inValid)
	
	//User interface
	.Sobel_Threshold		(Sobel_Threshold)					//Sobel Threshold for image edge detect
);


wire			post2_frame_vsync;	//Processed Image data vsync valid signal
wire			post2_frame_hsync;	//Processed Image data vsync valid signal
wire			post2_frame_href;	//Processed Image data href vaild  signal
wire			post2_frame_clken;	//Processed Image data output/capture enable clock
wire			post2_img_Bit;		//Processed Image Bit flag outout(1: Value, 0:inValid)

//--------------------------------------
//Bit Image Process with Erosion before Dilation Detector.
VIP_Bit_Erosion_Detector
#(
	.IMG_HDISP	(IMG_HDISP),	//1280*720
	.IMG_VDISP	(IMG_VDISP)
)
u_VIP_Bit_Erosion_Detector
(
	//global clock
	.clk					(clk),  				//cmos video pixel clock
	.rst_n					(rst_n),				//global reset

	//Image data prepred to be processd
	.per_frame_vsync		(post1_frame_vsync),	//Prepared Image data vsync valid signal
	.per_frame_hsync		(post1_frame_hsync),	//Prepared Image data vsync valid signal
	.per_frame_href			(post1_frame_href),		//Prepared Image data href vaild  signal
	.per_frame_clken		(post1_frame_clken),	//Prepared Image data output/capture enable clock
	.per_img_Bit			(post1_img_Bit),		//Processed Image Bit flag outout(1: Value, 0:inValid)

	//Image data has been processd
	.post_frame_vsync		(post2_frame_vsync),		//Processed Image data vsync valid signal
	.post_frame_hsync		(post2_frame_hsync),		//Processed Image data vsync valid signal
	.post_frame_href		(post2_frame_href),		//Processed Image data href vaild  signal
	.post_frame_clken		(post2_frame_clken),		//Processed Image data output/capture enable clock
	.post_img_Bit			(post2_img_Bit)			//Processed Image Bit flag outout(1: Value, 0:inValid)
);

// //Mid 1
// assign post_frame_clken = mid1_frame_clken;
// assign post_frame_vsync = mid1_frame_vsync;
// assign post_frame_href 	= mid1_frame_href;
// assign post_frame_hsync = mid1_frame_hsync;
// assign post_img_Y 		= mid1_img_Y;

assign post_frame_clken = post1_frame_clken;
assign post_frame_vsync = post1_frame_vsync;
assign post_frame_href 	= post1_frame_href;
assign post_frame_hsync = post1_frame_hsync;
assign post_img_Y 		= {8{post1_img_Bit}};
assign post_img_Bit 	= post1_img_Bit;
// assign post_frame_clken = post2_frame_clken;
// assign post_frame_vsync = post2_frame_vsync;
// assign post_frame_href 	= post2_frame_href;
// assign post_frame_hsync = mid1_frame_hsync;
// assign post_img_Y 		= {8{post2_img_Bit}};
// assign post_img_Bit 	= post2_img_Bit;

// // M_axis_video_out_valid: valid when post_frame_href and post_frame_clken are active
// // M_axis_video_out_last: valid when processing the last pixel in a row
// // M_axis_video_out_data: combine processed image data into 24-bit RGB format

// // Pixel counter to determine the last pixel in a row
// reg [20:0] pixel_count;
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n)
//         pixel_count <= 20'd0;
//     else if (post_frame_href) begin
//         if (pixel_count == IMG_HDISP)
//             pixel_count <= 20'd0;
//         else
//             pixel_count <= pixel_count + 1;
// 	end else 
// 		pixel_count <= pixel_count;
// end


endmodule
