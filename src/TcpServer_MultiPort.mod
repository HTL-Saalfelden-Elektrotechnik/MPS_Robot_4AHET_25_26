MODULE TcpServer_MultiPort
    
    VAR string robot_ip := "10.0.1.70";

    ! Testing
    VAR socketdev testing_server_socket;
    VAR socketdev testing_client_socket;
    VAR string testing_receive_string;
    VAR string testing_client_ip;
    VAR num testing_port := 520;
    VAR string testing_ip := "10.0.1.20";
    
    ! Processing
    VAR socketdev procesing_server_socket;
    VAR socketdev processing_client_socket;
    VAR string precessing_receive_string;
    VAR string processing_client_ip;
    VAR num processing_port := 530;
    VAR string processing_ip := "10.0.1.30";

    ! Handling
    VAR socketdev handling_server_socket;
    VAR socketdev handling_client_socket;
    VAR string handling_receive_string;
    VAR string handling_client_ip;
    VAR num handling_port := 540;
    VAR string handling_ip := "10.0.1.30";
    
    ! Sorting
    VAR socketdev sorting_server_socket;
    VAR socketdev sorting_client_socket;
    VAR string sorting_receive_string;
    VAR string sorting_client_ip;
    VAR num sorting_port := 550;
    VAR string sorting_ip := "10.0.1.40";
    
    VAR socketdev general_in_server_socket;
    VAR socketdev general_in_client_socket;
    VAR string general_in_receive_string;
    VAR string general_in_client_ip;
    VAR num general_in_port := 530;
    VAR socketstatus general_in_state;
    VAR num general_in_time := 3600;
    
    

    PROC tcpServer()
        TPWrite "Starting TCP Server " + NumToStr(general_in_port, 0);
        SocketCreate general_in_server_socket;
        SocketBind general_in_server_socket, robot_ip, general_in_port;
        SocketListen general_in_server_socket;
        
        WHILE general_in_state < 5 DO
            SocketAccept general_in_server_socket, general_in_client_socket
            \ClientAddress := general_in_client_ip
            \Time:= general_in_time;
            SocketReceive general_in_client_socket \Str := general_in_receive_string;
            SocketSend general_in_client_socket \Str := "Hello client with ip-address " + general_in_client_ip;
            TPWrite "Hello client with ip-address " + general_in_client_ip;
            
            ! testing
            IF general_in_client_ip = testing_ip THEN
                ! Testing sent a signal
                TPWrite "testing sent a signal";
                check_take_testing;
                SocketClose general_in_client_socket;
                TPWrite "closing socket";
            ELSEIF general_in_client_ip = processing_ip THEN
                ! Processing sent a signal
                TPWrite "Processing sent a signal";
                demo;
                TPWrite "closing socket";
                SocketClose general_in_client_socket;
            ELSEIF general_in_client_ip = handling_ip THEN
                ! Handling sent a signal
                TPWrite "handling sent a signal";
                check_take_testing;
                SocketClose general_in_client_socket;
                TPWrite "closing handling socket";
            ELSEIF general_in_client_ip = sorting_ip THEN
                ! Sorting sent a signal
                TPWrite "Sorting sent a signal";
                check_take_testing;
                SocketClose general_in_client_socket;
                TPWrite "closing sorting socket";
            ELSE
                ! Who the fuck are you
                TPWrite "Someone else sent a signal";
            ENDIF
            
            general_in_state := SocketGetStatus(general_in_server_socket);
        ENDWHILE
    ENDPROC
ENDMODULE
