#===============================================================================
# Copyright (C) John-Philip Taylor
# jpt13653903@gmail.com
#
# This file is part of DE10-Lite Virtual JTAG MM Writer
#
# This file is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#=============================================================================== 

proc DwordReverse {Data} {
 set Result {}
 set i [string length $Data]
 while {$i > 0} {
  append Result [string range $Data [expr $i-4] [expr $i-1]]
  set i [expr $i-4]
 }
 set Result
};
#-------------------------------------------------------------------------------

# List all available programming hardwares, and select the USBBlaster.
foreach hardware_name [get_hardware_names] {
# puts $hardware_name
 if { [string match "USB-Blaster*" $hardware_name] } {
  set usbblaster_name $hardware_name
 }
}
 
puts "\nSelect JTAG chain connected to $usbblaster_name.\n";
 
# List all devices on the chain, and select the first device on the chain.
foreach device_name [get_device_names -hardware_name $usbblaster_name] {
# puts $device_name
 if { [string match "@1*" $device_name] } {
  set test_device $device_name
 }
}
puts "\nSelect device: $test_device.\n";
#-------------------------------------------------------------------------------

open_device -hardware_name $usbblaster_name -device_name $test_device

puts "Reading data file..."
set File [open "../Matlab_scripts/I-Q_Data.dat" "r"]
set Data [read $File]
close $File

set Length    [string length $Data]
set Length    [expr   $Length/2]
set BitLength [expr   $Length*8]
puts "The file contains $Length bytes ($BitLength bits)"

# If the input file is back-to-front, you don't need this...
# puts "Converting data to compatible format..."
# set Data [DwordReverse $Data]
#-------------------------------------------------------------------------------

puts "Locking the device..."
device_lock -timeout 1000
 # Force instance active by shifting IR
 device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value

 puts "Shifting the data..."
 device_virtual_dr_shift \
  -dr_value $Data        \
  -instance_index 0      \
  -length $BitLength     \
  -value_in_hex          \
  -no_captured_dr_value

 # Force a DR update by shifting IR
 device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value
puts "Done: unlocking the device..."
device_unlock

close_device
#-------------------------------------------------------------------------------

