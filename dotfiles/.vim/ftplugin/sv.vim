set syntax=verilog
iab abdisplay $display("None");
iab srv set_reg_value("reg", "field", 1);
iab abfor for ( int i=0; i<n; i++) begin<CR>end
iab udbs uvm_config_db#(int)::set(null, "db_name", "var_name", 1/*set value*/);
iab udbg uvm_config_db#(int)::get(null, "db_name", "var_name", get_value);
iab uerr `uvm_error(get_name(), $psprintf(""));
iab ufat `uvm_fatal(get_name(), $psprintf(""));
iab uinf `uvm_info(get_name(), $psprintf("var = %d", var), UVM_NONE);
iab abcase case(sel)<CR>	2'b00    : out = a;<CR>  2'b01    : out = b;<CR>  2'b10    : out = c;<CR>  default  : out = 0;<CR>endcase
iab abif if () begin<CR>end else begin<CR>end
iab abiftp if($test$plusargs("")) begin<CR>end else begin<CR>end
iab abifvp if(!$value$plusargs("NAME=%d", name)) name = 0;

nnoremap <leader>vdec i%<ESC>ead<ESC>
nnoremap <leader>vp :norm F"i$psprintf(<Esc>2f"a, i)<ESC>
nnoremap <leader>vtargs :norm a$test$plusargs("")<ESC>2ha
set isfname-==
