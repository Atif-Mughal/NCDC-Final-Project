// 64 bit option for AWS labs
-64
-access
+rwc
//-gui
-sv 
-timescale 1ns/1ns
+SVSEED=random
-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d
+UVM_TESTNAME=base_test
+UVM_VERBOSITY=UVM_HIGH


// include directories
//*** add incdir include directories here
-incdir ../Master-UVC/
-incdir ../Slave-UVC/





// compile files
//*** add compile files here
./axi_parameters.sv
../Master-UVC/axi_master_pkg.sv
../Slave-UVC/axi_slave_pkg.sv
axi4_if.sv


//AXI_scoreboard.sv
hw_top.sv
axi_top.sv
