/*-----------------------------------------------------------------
File name     : run.f
Developers    : Evan Wu 
Created       : 09/14/2026
Description   : avalon_mm_led_ctrl simulator run file
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

//-uvm 

// uncomment for gui
//-gui
+access+rwc

// SimVision tcl scripts 
//-input simvision.tcl 

// options


// default timescale
-timescale 1ns/100ps 

// include directories
-incdir ../rtl/


// compile files

// DUT
../rtl/avalon_mm_led_ctrl.sv

// top module for UVM test environment
led_ctrl_tb.sv

