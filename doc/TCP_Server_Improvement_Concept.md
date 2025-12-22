# TCP Server Improvement Concept

## Overview

This document describes a concept for improving the ABB RAPID multiport TCP server by moving TCP server handling into separate routines. The improvements focus on:

1. **Error Handling** - Reduces code crashes and improves stability
2. **Modular Routines** - Enables multiple clients simultaneously
3. **Security Improvements** - Better positional and networking security

---

## Current Implementation Analysis

### Current Architecture (TcpServer_MultiPort module)

The current implementation has the following structure:

```rapid
MODULE TcpServer_MultiPort
    ! Port definitions
    VAR num testing_port := 520;
    VAR num processing_port := 530;
    VAR num handling_port := 540;
    VAR num sorting_port := 550;
    
    PROC tcpServer()
        ! Sequential initialization of all servers
        SocketCreate testing_server_socket;
        SocketBind testing_server_socket, robot_ip, testing_port;
        SocketListen testing_server_socket;
        ! ... repeat for each port
        
        WHILE TRUE DO
            ! Blocking accept - cannot handle multiple clients
            SocketAccept procesing_server_socket, processing_client_socket;
            ! Process one client at a time
        ENDWHILE
    ENDPROC
ENDMODULE
```

### Current Issues

| Issue | Impact | Severity |
|-------|--------|----------|
| Single blocking loop | Cannot handle multiple clients simultaneously | High |
| No error handling for socket operations | Server crashes on connection errors | High |
| No socket cleanup on errors | Resource leaks on failed connections | Medium |
| No client validation | Security vulnerability | High |
| Hard-coded IP addresses | Reduces portability | Low |

---

## Proposed Architecture

### 1. Separate Handler Routines

Move each TCP server handler into its own routine to enable independent operation:

```rapid
MODULE TcpServer_MultiPort
    
    !*********************************************************
    ! Error numbers for socket operations
    !*********************************************************
    CONST errnum ERR_SOCK_TIMEOUT := -1;
    CONST errnum ERR_SOCK_CLOSED := -2;
    
    !*********************************************************
    ! Configuration
    !*********************************************************
    PERS string robot_ip := "10.0.1.70";
    
    ! Testing Station
    PERS num testing_port := 520;
    PERS string testing_allowed_ip := "";  ! Empty = any IP allowed
    
    ! Processing Station
    PERS num processing_port := 530;
    PERS string processing_allowed_ip := "10.0.1.30";
    
    ! Handling Station
    PERS num handling_port := 540;
    PERS string handling_allowed_ip := "";
    
    ! Sorting Station
    PERS num sorting_port := 550;
    PERS string sorting_allowed_ip := "";
    
    !*********************************************************
    ! Socket Variables
    !*********************************************************
    ! Testing
    VAR socketdev testing_server_socket;
    VAR socketdev testing_client_socket;
    VAR string testing_receive_string;
    VAR string testing_client_ip;
    VAR bool testing_server_running := FALSE;
    
    ! Processing
    VAR socketdev processing_server_socket;
    VAR socketdev processing_client_socket;
    VAR string processing_receive_string;
    VAR string processing_client_ip;
    VAR bool processing_server_running := FALSE;
    
    ! Handling
    VAR socketdev handling_server_socket;
    VAR socketdev handling_client_socket;
    VAR string handling_receive_string;
    VAR string handling_client_ip;
    VAR bool handling_server_running := FALSE;
    
    ! Sorting
    VAR socketdev sorting_server_socket;
    VAR socketdev sorting_client_socket;
    VAR string sorting_receive_string;
    VAR string sorting_client_ip;
    VAR bool sorting_server_running := FALSE;

ENDMODULE
```

### 2. Generic Socket Initialization Routine

Create a reusable routine for safe socket initialization with error handling:

```rapid
!*********************************************************
! Safe socket initialization with error handling
! Returns TRUE on success, FALSE on failure
!*********************************************************
PROC InitServerSocket(VAR socketdev server_socket, string ip, num port, VAR bool server_running)
    server_running := FALSE;
    
    ! Create socket with error handling
    SocketCreate server_socket;
    
    ! Bind to IP and port
    SocketBind server_socket, ip, port;
    
    ! Start listening
    SocketListen server_socket;
    
    server_running := TRUE;
    TPWrite "Server started on " + ip + ":" + NumToStr(port, 0);
    
    RETURN;
    
ERROR
    ! Handle socket creation errors
    IF ERRNO = ERR_SOCK_CLOSED THEN
        TPWrite "ERROR: Socket already in use on port " + NumToStr(port, 0);
    ELSE
        TPWrite "ERROR: Failed to initialize server on port " + NumToStr(port, 0);
        TPWrite "Error code: " + NumToStr(ERRNO, 0);
    ENDIF
    
    ! Clean up on error
    SocketClose server_socket;
    server_running := FALSE;
    
UNDO
    ! Cleanup if procedure is interrupted
    SocketClose server_socket;
    server_running := FALSE;
ENDPROC
```

### 3. Client Validation Routine

Add a routine to validate connecting clients:

```rapid
!*********************************************************
! Validate client IP address
! Returns TRUE if client is allowed, FALSE otherwise
!*********************************************************
FUNC bool ValidateClient(string client_ip, string allowed_ip)
    ! If no IP restriction, allow all
    IF StrLen(allowed_ip) = 0 THEN
        RETURN TRUE;
    ENDIF
    
    ! Check if client IP matches allowed IP
    IF client_ip = allowed_ip THEN
        RETURN TRUE;
    ENDIF
    
    TPWrite "SECURITY: Rejected connection from " + client_ip;
    RETURN FALSE;
ENDFUNC
```

### 4. Individual Server Handler Routines

Create separate handler routines for each station:

```rapid
!*********************************************************
! Testing Station Handler
!*********************************************************
PROC TestingServerHandler()
    VAR bool client_valid;
    
    ! Initialize server
    InitServerSocket testing_server_socket, robot_ip, testing_port, testing_server_running;
    
    IF NOT testing_server_running THEN
        TPWrite "Testing server failed to start";
        RETURN;
    ENDIF
    
    ! Main handler loop
    WHILE testing_server_running DO
        ! Accept with timeout to allow graceful shutdown
        SocketAccept testing_server_socket, testing_client_socket 
            \ClientAddress := testing_client_ip 
            \Time := 5;
        
        ! Validate client
        client_valid := ValidateClient(testing_client_ip, testing_allowed_ip);
        
        IF client_valid THEN
            ! Handle client request
            HandleTestingClient;
        ENDIF
        
        ! Close client connection
        SocketClose testing_client_socket;
        
    ENDWHILE
    
ERROR
    IF ERRNO = ERR_SOCK_TIMEOUT THEN
        ! Timeout is normal, continue listening
        TRYNEXT;
    ELSEIF ERRNO = ERR_SOCK_CLOSED THEN
        TPWrite "Testing: Client disconnected";
        SocketClose testing_client_socket;
        TRYNEXT;
    ELSE
        TPWrite "Testing server error: " + NumToStr(ERRNO, 0);
        ! Attempt recovery
        WaitTime 1;
        RETRY;
    ENDIF
    
UNDO
    SocketClose testing_client_socket;
    SocketClose testing_server_socket;
    testing_server_running := FALSE;
ENDPROC

!*********************************************************
! Handle Testing Client Request
!*********************************************************
PROC HandleTestingClient()
    ! Receive data with timeout
    SocketReceive testing_client_socket \Str := testing_receive_string \Time := 10;
    
    ! Log connection
    TPWrite "Testing client: " + testing_client_ip;
    TPWrite "Received: " + testing_receive_string;
    
    ! Process command
    ProcessTestingCommand testing_receive_string;
    
    ! Send acknowledgment
    SocketSend testing_client_socket \Str := "ACK:" + testing_receive_string;
    
ERROR
    IF ERRNO = ERR_SOCK_TIMEOUT THEN
        TPWrite "Testing: Receive timeout";
    ELSE
        TPWrite "Testing: Communication error " + NumToStr(ERRNO, 0);
    ENDIF
ENDPROC

!*********************************************************
! Process Testing Station Commands
!*********************************************************
PROC ProcessTestingCommand(string cmd)
    TEST cmd
    CASE "TAKE_PART":
        testing_take_part;
    CASE "STATUS":
        ! Return status
        SocketSend testing_client_socket \Str := "STATUS:OK";
    CASE "DEMO":
        demo;
    DEFAULT:
        TPWrite "Unknown testing command: " + cmd;
        SocketSend testing_client_socket \Str := "ERROR:UNKNOWN_CMD";
    ENDTEST
    
ERROR
    TPWrite "Error processing testing command: " + cmd;
    SocketSend testing_client_socket \Str := "ERROR:PROCESSING_FAILED";
ENDPROC
```

### 5. Similar Handlers for Other Stations

Create identical handler patterns for Processing, Handling, and Sorting stations:

```rapid
!*********************************************************
! Processing Station Handler
!*********************************************************
PROC ProcessingServerHandler()
    VAR bool client_valid;
    
    InitServerSocket processing_server_socket, robot_ip, processing_port, processing_server_running;
    
    IF NOT processing_server_running THEN
        TPWrite "Processing server failed to start";
        RETURN;
    ENDIF
    
    WHILE processing_server_running DO
        SocketAccept processing_server_socket, processing_client_socket 
            \ClientAddress := processing_client_ip 
            \Time := 5;
        
        client_valid := ValidateClient(processing_client_ip, processing_allowed_ip);
        
        IF client_valid THEN
            HandleProcessingClient;
        ENDIF
        
        SocketClose processing_client_socket;
        
    ENDWHILE
    
ERROR
    IF ERRNO = ERR_SOCK_TIMEOUT THEN
        TRYNEXT;
    ELSEIF ERRNO = ERR_SOCK_CLOSED THEN
        TPWrite "Processing: Client disconnected";
        SocketClose processing_client_socket;
        TRYNEXT;
    ELSE
        TPWrite "Processing server error: " + NumToStr(ERRNO, 0);
        WaitTime 1;
        RETRY;
    ENDIF
    
UNDO
    SocketClose processing_client_socket;
    SocketClose processing_server_socket;
    processing_server_running := FALSE;
ENDPROC

!*********************************************************
! Handling Station Handler
!*********************************************************
PROC HandlingServerHandler()
    ! Similar structure as TestingServerHandler
    ! ... implementation follows same pattern
ENDPROC

!*********************************************************
! Sorting Station Handler
!*********************************************************
PROC SortingServerHandler()
    ! Similar structure as TestingServerHandler
    ! ... implementation follows same pattern
ENDPROC
```

### 6. Main TCP Server Coordinator

Update the main tcpServer routine to start all handlers:

```rapid
!*********************************************************
! Main TCP Server - Coordinates all station handlers
!*********************************************************
PROC tcpServer()
    TPWrite "=== MPS Robot TCP Server Starting ===";
    TPWrite "Robot IP: " + robot_ip;
    
    ! In a single-task system, run one server at a time
    ! For multi-task system, each handler runs in parallel
    
    ! Option 1: Sequential handling (current hardware limitation)
    ! Run each handler in sequence based on priority
    ProcessingServerHandler;  ! Primary handler
    
    ! Option 2: For multi-task capable systems
    ! Use RAPID multi-tasking to run handlers in parallel
    ! This requires system configuration changes
    
ERROR
    TPWrite "Main TCP server error: " + NumToStr(ERRNO, 0);
    ! Attempt cleanup and restart
    CleanupAllSockets;
    WaitTime 5;
    RETRY;
    
UNDO
    CleanupAllSockets;
ENDPROC

!*********************************************************
! Cleanup all open sockets
!*********************************************************
PROC CleanupAllSockets()
    TPWrite "Cleaning up all sockets...";
    
    SocketClose testing_client_socket;
    SocketClose testing_server_socket;
    SocketClose processing_client_socket;
    SocketClose processing_server_socket;
    SocketClose handling_client_socket;
    SocketClose handling_server_socket;
    SocketClose sorting_client_socket;
    SocketClose sorting_server_socket;
    
    testing_server_running := FALSE;
    processing_server_running := FALSE;
    handling_server_running := FALSE;
    sorting_server_running := FALSE;
    
ERROR
    ! Ignore errors during cleanup
    TRYNEXT;
ENDPROC
```

---

## Multi-Client Support Architecture

### Option A: Round-Robin Polling (Single Task)

For systems without multi-tasking support, use non-blocking polling:

```rapid
PROC tcpServerPolling()
    VAR bool has_connection;
    
    ! Initialize all servers
    InitServerSocket testing_server_socket, robot_ip, testing_port, testing_server_running;
    InitServerSocket processing_server_socket, robot_ip, processing_port, processing_server_running;
    InitServerSocket handling_server_socket, robot_ip, handling_port, handling_server_running;
    InitServerSocket sorting_server_socket, robot_ip, sorting_port, sorting_server_running;
    
    WHILE TRUE DO
        ! Poll each server with short timeout
        
        ! Testing
        IF testing_server_running THEN
            has_connection := PollServer(testing_server_socket, testing_client_socket, 
                                         testing_client_ip, 0.1);
            IF has_connection THEN
                HandleTestingClient;
                SocketClose testing_client_socket;
            ENDIF
        ENDIF
        
        ! Processing
        IF processing_server_running THEN
            has_connection := PollServer(processing_server_socket, processing_client_socket,
                                         processing_client_ip, 0.1);
            IF has_connection THEN
                HandleProcessingClient;
                SocketClose processing_client_socket;
            ENDIF
        ENDIF
        
        ! Handling
        IF handling_server_running THEN
            has_connection := PollServer(handling_server_socket, handling_client_socket,
                                         handling_client_ip, 0.1);
            IF has_connection THEN
                HandleHandlingClient;
                SocketClose handling_client_socket;
            ENDIF
        ENDIF
        
        ! Sorting
        IF sorting_server_running THEN
            has_connection := PollServer(sorting_server_socket, sorting_client_socket,
                                         sorting_client_ip, 0.1);
            IF has_connection THEN
                HandleSortingClient;
                SocketClose sorting_client_socket;
            ENDIF
        ENDIF
        
    ENDWHILE
    
ERROR
    TPWrite "Polling server error: " + NumToStr(ERRNO, 0);
    WaitTime 1;
    RETRY;
ENDPROC

!*********************************************************
! Poll for incoming connection
! Returns TRUE if connection received, FALSE otherwise
!*********************************************************
FUNC bool PollServer(VAR socketdev server, VAR socketdev client, 
                     VAR string client_ip, num timeout)
    
    SocketAccept server, client \ClientAddress := client_ip \Time := timeout;
    RETURN TRUE;
    
ERROR
    IF ERRNO = ERR_SOCK_TIMEOUT THEN
        RETURN FALSE;
    ENDIF
    RAISE;  ! Re-raise other errors
ENDFUNC
```

### Option B: Multi-Tasking (Parallel Handlers)

For systems with multi-tasking support, configure separate tasks:

```
System Configuration (EIO.cfg):
- Task T_ROB1: Main robot task
- Task T_TESTING: Testing server handler  
- Task T_PROCESSING: Processing server handler
- Task T_HANDLING: Handling server handler
- Task T_SORTING: Sorting server handler

Each task runs its respective ServerHandler procedure independently.
```

---

## Error Handling Strategy

### Error Categories

| Error Type | ERRNO | Recovery Action |
|------------|-------|-----------------|
| Socket Timeout | ERR_SOCK_TIMEOUT | TRYNEXT (continue) |
| Socket Closed | ERR_SOCK_CLOSED | Close client, TRYNEXT |
| Socket Binding Error | ERR_SOCK_BIND | Log error, return failure |
| General Socket Error | Other | Retry with delay |

### Implementation Pattern

```rapid
PROC SafeSocketOperation()
    ! Socket operation here
    
ERROR
    TEST ERRNO
    CASE ERR_SOCK_TIMEOUT:
        ! Timeout - expected in polling mode
        TPWrite "Socket timeout (normal)";
        TRYNEXT;
        
    CASE ERR_SOCK_CLOSED:
        ! Client disconnected
        TPWrite "Client disconnected";
        SocketClose client_socket;
        TRYNEXT;
        
    CASE ERR_SOCK_BIND:
        ! Port already in use
        TPWrite "ERROR: Port binding failed";
        RETURN;
        
    DEFAULT:
        ! Unknown error - log and retry
        TPWrite "Socket error: " + NumToStr(ERRNO, 0);
        WaitTime 1;
        RETRY;
    ENDTEST
    
UNDO
    ! Always clean up on procedure exit
    SocketClose client_socket;
    SocketClose server_socket;
ENDPROC
```

---

## Security Improvements

### 1. IP Whitelisting

Only accept connections from known station IP addresses:

```rapid
PERS string testing_allowed_ip := "";        ! Empty = any IP
PERS string processing_allowed_ip := "10.0.1.30";
PERS string handling_allowed_ip := "10.0.1.40";
PERS string sorting_allowed_ip := "10.0.1.50";
```

### 2. Command Validation

Validate all received commands before execution:

```rapid
FUNC bool IsValidCommand(string cmd)
    ! Check command length
    IF StrLen(cmd) > 100 THEN
        TPWrite "SECURITY: Command too long";
        RETURN FALSE;
    ENDIF
    
    ! Check for valid command prefix
    IF StrPart(cmd, 1, 1) < "A" OR StrPart(cmd, 1, 1) > "Z" THEN
        TPWrite "SECURITY: Invalid command format";
        RETURN FALSE;
    ENDIF
    
    RETURN TRUE;
ENDFUNC
```

### 3. Connection Logging

Log all connection attempts for audit:

```rapid
PROC LogConnection(string station, string client_ip, bool accepted)
    VAR string status;
    
    IF accepted THEN
        status := "ACCEPTED";
    ELSE
        status := "REJECTED";
    ENDIF
    
    TPWrite station + " connection from " + client_ip + ": " + status;
    
    ! Optional: Write to file for persistent logging
    ! WriteConnectionLog station, client_ip, status;
ENDPROC
```

### 4. Robot Position Safety

Verify robot is in safe position before executing commands:

```rapid
FUNC bool IsRobotInSafePosition()
    VAR robjoint current_joints;
    VAR robtarget current_pos;
    
    current_joints := CJointT();
    current_pos := CRobT();
    
    ! Check if robot is within safe operational area
    IF current_pos.trans.z < 100 THEN
        TPWrite "SAFETY: Robot too low for remote command";
        RETURN FALSE;
    ENDIF
    
    RETURN TRUE;
ENDFUNC

PROC ExecuteRemoteCommand(string cmd)
    ! Safety check before command execution
    IF NOT IsRobotInSafePosition() THEN
        SocketSend current_client \Str := "ERROR:UNSAFE_POSITION";
        RETURN;
    ENDIF
    
    ! Execute command
    ProcessCommand cmd;
ENDPROC
```

---

## Implementation Phases

### Phase 1: Error Handling (Low Risk)
- Add ERROR and UNDO handlers to existing code
- Add socket timeouts to prevent blocking
- Add connection logging
- **Estimated effort**: 2-4 hours

### Phase 2: Modular Routines (Medium Risk)
- Split tcpServer into separate handler routines
- Create reusable initialization routine
- Add client validation
- **Estimated effort**: 4-6 hours

### Phase 3: Multi-Client Support (Higher Risk)
- Implement polling-based multi-client handling
- OR configure multi-tasking (requires system changes)
- Add position safety checks
- **Estimated effort**: 6-10 hours

---

## Testing Recommendations

### Unit Tests
1. Test socket initialization with valid/invalid parameters
2. Test client validation with allowed/blocked IPs
3. Test command parsing with valid/invalid commands
4. Test error recovery after simulated failures

### Integration Tests
1. Connect from each station and verify response
2. Simulate multiple simultaneous connections
3. Test behavior when station IP is incorrect
4. Test recovery after network interruption

### Safety Tests
1. Verify robot stops on communication error
2. Verify position checks before movement commands
3. Test emergency stop integration
4. Verify no uncontrolled motion on reconnection

---

## Summary

This concept provides a structured approach to improving the TCP server with:

| Improvement | Benefit |
|-------------|---------|
| Separate handler routines | Clearer code, easier maintenance |
| Error handling | Reduced crashes, automatic recovery |
| Client validation | Better security |
| Position safety | Reduced risk of uncontrolled motion |
| Modular design | Easier testing and extension |

The implementation can be done in phases, starting with low-risk error handling improvements and progressing to more significant architectural changes based on system requirements and testing results.
