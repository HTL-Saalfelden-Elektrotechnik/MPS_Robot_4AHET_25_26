MODULE TCPClient
    VAR num retry_no := 0;
    VAR socketdev general_out_client_socket;
    VAR string receive_string;
    
    FUNC bool sorting_start_belt()
        SocketClose general_out_client_socket;
        SocketCreate general_out_client_socket;
        SocketConnect general_out_client_socket, sorting_ip, sorting_port;
        
        ERROR
        IF ERRNO = ERR_SOCK_TIMEOUT THEN
            IF retry_no < 5 THEN
                WaitTime 1;
                retry_no := retry_no + 1;
                RETRY;
            ELSE
                RAISE;
            ENDIF
        ENDIF
        
        SocketClose general_out_client_socket;
        
        RETURN TRUE;
    ENDFUNC
ENDMODULE