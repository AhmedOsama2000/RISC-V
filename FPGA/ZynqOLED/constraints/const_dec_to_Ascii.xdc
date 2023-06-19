set Clock_period 20
set max_delay    [expr $Clock_period * 0.2]
set min_delay    [expr $Clock_period * 0.1]
create_clock -period $Clock_period -name clock -add [get_ports clock]
 
set_input_delay -clock [get_clocks clock] -min -add_delay  $min_delay [get_ports {decimal[*]}]
set_input_delay -clock [get_clocks clock] -max -add_delay  $max_delay [get_ports {decimal[*]}]

set_input_delay -clock [get_clocks clock] -min -add_delay  $min_delay [get_ports load_data]
set_input_delay -clock [get_clocks clock] -max -add_delay  $max_delay [get_ports load_data]



set_output_delay -clock [get_clocks clock] -min -add_delay $min_delay [get_ports {ascii[*]}]
set_output_delay -clock [get_clocks clock] -max -add_delay $max_delay [get_ports {ascii[*]}]

set_output_delay -clock [get_clocks clock] -min -add_delay $min_delay [get_ports complete]
set_output_delay -clock [get_clocks clock] -max -add_delay $max_delay [get_ports complete]
