" TODO change to :IS
iab casee case(sel)<CR>	2'b00    : out = a;<CR>  2'b01    : out = b;<CR>  2'b10    : out = c;<CR>  default  : out = 0;<CR>endcase
iab displayy $display("None");
iab forr for (int i=0; i<=n; i++) begin<CR>end
iab iff if () begin<CR>end else begin<CR>end
iab ifft if($test$plusargs("")) begin<CR>end else begin<CR>end
iab iffv if(!$value$plusargs("NAME=%d", name)) name = 0;
iab alwayss always begin<CR>end
iab printff $sformatf("")
iab rbrv env.read_block_reg_value("block", "reg", "field", value);
iab srv env.set_reg_value("reg", "field", 1);
iab build_phasee function void build_phase(uvm_phase phase);<CR>string inst_name;<CR>super.build_phase(phase);<CR>endfunction
iab classs class name extends uvm_component;<CR>endclass // name
iab connect_phasee function void connect_phase(uvm_phase phase);<CR>endfunction
iab drive_itemm task drive_item(input simple_item item);<CR>endtask: drive_item
iab initiall initial begin<CR>end
iab run_phasee task run_phase(uvm_phase phase);<CR><C-i>forever begin<CR>end<CR>endtask
iab uvm_infoo `uvm_info(get_name(), $sformatf(""), UVM_NONE);
iab ucdg uvm_config_db#(int)::get(null, "db_name", "var_name", get_value);
iab ucds uvm_config_db#(int)::set(null, "db_name", "var_name", 1/*set value*/);
iab uvm_errorr `uvm_error(get_name(), $sformatf("receiving %4d", var));
iab uvm_fatall `uvm_fatal(get_name(), $sformatf(""));
set autoindent
set expandtab
set isfname-==
set shiftwidth=4
set smartindent
set tabstop=4 softtabstop=4
set formatprg=verible-verilog-format\ --indentation_spaces\ 4\ --over_column_limit_penalty\ 100\ -
set nu
set nowrap
command! SplitPlusargs :s/ -p/ \\\r-p/g
" set errorformat+=%.%#xmvlog:\ %.%#\\,%.%#(%f\\,%l\|%c%.%#
" set errorformat=%.%#xmvlog:\ %\\%#E\\,%.%#(%f\\,%l\|%c):\ %m
" set makeprg=runIus\ -ed\ -do\ compile\ -t\ fcu2__a_template_test
" set makeprg=xrun\ %
" let g:ale_linters = {'systemverilog': ['verible-verilog-lint']}
" let g:ale_linters_explicit = 1
" let g:ale_linters = {
" \   'systemverilog': []
" \}
" command! Lint :term verible-verilog-lint %
