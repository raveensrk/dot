module ferror ();
    int fd;
    int errorno;
    string errormsg;
    initial begin
        fd = $fopen("file.log", "w");
        errorno = $ferror(fd, errormsg);
        if (errorno != 0) begin
            $fatal(2, "%m: %s: %0d", errormsg, errorno);
        end
    end
endmodule
