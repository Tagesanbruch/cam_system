#create_clock -period 10 -name ddr_clk -waveform {0 5} [get_nets I_ddr_clk]
create_clock -name clk_25m -period 40 -waveform {0 20} [get_ports {I_sys_clk_25m}]

create_clock -name rgmii_rx_clk    -period 8 -waveform {0 4} [get_ports {rgmii_rxc}]
 
create_clock -name hs_rx_clk -period 20 -waveform {0 10} [get_pins {u_mipi_dphy_rx_ph1a_mipiio_wrapper/u_ph1a_mipiio_wrapper/u_PH1_PHY_MIPIIO.hsrx_byteclk_to_fabric}]
 
create_clock -name S_hdmi_clk -period 6.66 -waveform {0 3.33} [get_nets {S_hdmi_clk}]
create_clock -name S_serial_clk -period 1.33 -waveform {0 0.67} [get_nets {S_serial_clk}]
#create_clock -name I_ddr_clk -period 10 -waveform {0 5} [get_nets {I_ddr_clk}]

create_generated_clock -name CLK125 	-source [get_ports {I_sys_clk_25m}] -master_clock {clk_25m} -phase 0  -multiply_by 1.25 [get_nets {u_al_temac/gtx_clk}]
#create_generated_clock -name CLK125_90  -source [get_ports {sysclk_P}] -master_clock {clkin} -phase 90 -multiply_by 1.25 [get_nets {gtx_clk90}]
create_generated_clock -name CLK50      -source [get_ports {I_sys_clk_25m}] -master_clock {clk_25m} -phase 0  -multiply_by 0.5  [get_nets {u_al_temac/s_axi_aclk}]

 
rename_clock -name {cpu_clk_70m} -source [get_ports {I_sys_clk_25m}] -master_clock {clk_25m} [get_pins {U_PLL/pll_inst.clkc[2]}]
rename_clock -name {cam_clk_27m} -source [get_ports {I_sys_clk_25m}] -master_clock {clk_25m} [get_pins {U_PLL/pll_inst.clkc[0]}]

derive_pll_clocks


set_false_path -from [get_regs {vtc_vs}] -to [get_regs {u_uifdma_axi_ddr/u_ddr_phy/u_clk/hctrl_clk_bufg}]

set_clock_groups -exclusive -group [get_clocks {CLK125}]  -group [get_clocks {CLK50}] -group [get_clocks {rgmii_rx_clk}]  -group [get_clocks { S_hdmi_clk }]  -group [get_clocks { clk_25m }] -group [get_clocks { cpu_clk_70m }] -group [get_clocks { cam_clk_27m }] -group [get_clocks { hs_rx_clk }] -group [get_clocks {u_uifdma_axi_ddr/u_ddr_phy/hctrl_clk}]
