set Clock_period 10
set max_delay    [expr $Clock_period * 0.2]
set min_delay    [expr $Clock_period * 0.1]
create_clock -period $Clock_period -name CLK -add [get_ports SYS_CLK]
 
#set_input_delay -clock [get_clocks CLK] -min -add_delay  $min_delay [get_ports EN_PC]
#set_input_delay -clock [get_clocks CLK] -max -add_delay  $max_delay [get_ports EN_PC]

#set_input_delay -clock [get_clocks CLK] -min -add_delay  $min_delay [get_ports load_data]
#set_input_delay -clock [get_clocks CLK] -max -add_delay  $max_delay [get_ports load_data]

#set_output_delay -clock [get_clocks CLK] -min -add_delay $min_delay [get_ports PC_done]
#set_output_delay -clock [get_clocks CLK] -max -add_delay $max_delay [get_ports PC_done]

#set_output_delay -clock [get_clocks CLK] -min -add_delay $min_delay [get_ports oled_spi_clk]
#set_output_delay -clock [get_clocks CLK] -max -add_delay $max_delay [get_ports oled_spi_clk]

#set_output_delay -clock [get_clocks CLK] -min -add_delay $min_delay [get_ports oled_spi_data]
#set_output_delay -clock [get_clocks CLK] -max -add_delay $max_delay [get_ports oled_spi_data]

#set_output_delay -clock [get_clocks CLK] -min -add_delay $min_delay [get_ports oled_vbat]
#set_output_delay -clock [get_clocks CLK] -max -add_delay $max_delay [get_ports oled_vbat]

#set_output_delay -clock [get_clocks CLK] -min -add_delay $min_delay [get_ports oled_vdd]
#set_output_delay -clock [get_clocks CLK] -max -add_delay $max_delay [get_ports oled_vdd]

#set_output_delay -clock [get_clocks CLK] -min -add_delay $min_delay [get_ports oled_reset_n]
#set_output_delay -clock [get_clocks CLK] -max -add_delay $max_delay [get_ports oled_reset_n]

#set_output_delay -clock [get_clocks CLK] -min -add_delay $min_delay [get_ports oled_dc_n]
#set_output_delay -clock [get_clocks CLK] -max -add_delay $max_delay [get_ports oled_dc_n]

## OUTPUT

set_property PACKAGE_PIN U10     [get_ports oled_dc_n]
set_property PACKAGE_PIN U9      [get_ports oled_reset_n]
set_property PACKAGE_PIN AB12    [get_ports oled_spi_clk]
set_property PACKAGE_PIN AA12    [get_ports oled_spi_data]
set_property PACKAGE_PIN U11     [get_ports oled_vbat]
set_property PACKAGE_PIN U12     [get_ports oled_vdd]

set_property IOSTANDARD LVCMOS33 [get_ports oled_dc_n]
set_property IOSTANDARD LVCMOS33 [get_ports oled_reset_n]
set_property IOSTANDARD LVCMOS33 [get_ports oled_spi_clk]
set_property IOSTANDARD LVCMOS33 [get_ports oled_spi_data]
set_property IOSTANDARD LVCMOS33 [get_ports oled_vbat]
set_property IOSTANDARD LVCMOS33 [get_ports oled_vdd]

set_property PACKAGE_PIN T22     [get_ports PC_done]
set_property IOSTANDARD LVCMOS33 [get_ports PC_done]

## INPUT

set_property PACKAGE_PIN Y9      [get_ports SYS_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports SYS_CLK]

set_property PACKAGE_PIN F22     [get_ports Core_rst_n]
set_property IOSTANDARD LVCMOS25 [get_ports Core_rst_n]

set_property PACKAGE_PIN G22     [get_ports rst_oled]
set_property IOSTANDARD LVCMOS25 [get_ports rst_oled]

set_property PACKAGE_PIN H22     [get_ports EN_PC]
set_property IOSTANDARD LVCMOS25 [get_ports EN_PC]

set_property PACKAGE_PIN F21     [get_ports load_data]
set_property IOSTANDARD LVCMOS25 [get_ports load_data]




