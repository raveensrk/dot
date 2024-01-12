iab abcase case(sel)<CR>	2'b00    : out = a;<CR>  2'b01    : out = b;<CR>  2'b10    : out = c;<CR>  default  : out = 0;<CR>endcase
iab always always begin<CR>end
iab build_phase function void build_phase(uvm_phase phase);<CR>string inst_name;<CR>super.build_phase(phase);<CR>endfunction
iab connect_phase function void connect_phase(uvm_phase phase);<CR>endfunction
iab display $display("var = %0d", var);
iab drive_item task drive_item(input simple_item item);<CR>endtask: drive_item
iab for for (int i=0; i<n; i++) begin<CR>end
iab if if () begin<CR>end else begin<CR>end
iab iftp if($test$plusargs("")) begin<CR>end else begin<CR>end
iab ifvp if(!$value$plusargs("NAME=%d", name)) name = 0;
iab initial initial begin<CR>end
iab run_phase task run_phase(uvm_phase phase);<CR><C-i>forever begin<CR>end<CR>endtask
iab set_reg_value set_reg_value("reg", "field", 1);
iab tp $test$plusargs("")
iab uvm_config_db_get uvm_config_db#(int)::get(null, "db_name", "var_name", get_value);
iab uvm_config_db_set uvm_config_db#(int)::set(null, "db_name", "var_name", 1/*set value*/);
iab uvm_error `uvm_error(get_name(), $sformatf("receiving %4d", var));
iab uvm_fatal `uvm_fatal(get_name(), $psprintf(""));
iab vp $value$plusargs("NAME=%d", name)
set isfname-==
set syntax=verilog
iab class class name extends uvm_component;<CR>endclass // name
iab Constructor function new(string name, uvm_component p = null);<CR>    super.new(name,p);<CR>    obj_name = new("obj_name",this);<CR>endfunction
