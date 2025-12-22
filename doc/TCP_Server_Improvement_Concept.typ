// TCP Server Improvement Concept
// MPS Robot 4AHET 25/26

#set document(
  title: "TCP Server Improvement Concept",
  author: "MPS Robot Team 4AHET 25/26",
)

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  header: [
    #set text(9pt)
    #smallcaps[TCP Server Improvement Concept]
    #h(1fr)
    MPS Robot 4AHET 25/26
  ],
  footer: [
    #set text(9pt)
    #h(1fr)
    #counter(page).display("1 / 1", both: true)
  ],
)

#set heading(numbering: "1.1")
#set text(font: "Linux Libertine", size: 11pt)

// Title Page
#align(center)[
  #v(3cm)
  #text(24pt, weight: "bold")[TCP Server Improvement Concept]
  #v(1cm)
  #text(16pt)[MPS Robot 4AHET 25/26]
  #v(2cm)
  #text(12pt)[ABB RAPID Multiport TCP Server]
  #v(1cm)
  #line(length: 50%)
  #v(0.5cm)
  #text(11pt)[
    Error Handling • Modular Routines • Multi-Client Support • Security
  ]
  #v(3cm)
]

#pagebreak()

// Table of Contents
#outline(
  title: "Contents",
  indent: auto,
)

#pagebreak()

= Overview

This document describes a concept for improving the ABB RAPID multiport TCP server by moving TCP server handling into separate routines. The improvements focus on:

+ *Error Handling* - Reduces code crashes and improves stability
+ *Modular Routines* - Enables multiple clients simultaneously  
+ *Security Improvements* - Better positional and networking security

= Current Issues

#table(
  columns: (auto, 1fr, auto),
  inset: 8pt,
  align: (left, left, center),
  [*Issue*], [*Impact*], [*Severity*],
  [Single blocking loop], [Cannot handle multiple clients simultaneously], [High],
  [No error handling], [Server crashes on connection errors], [High],
  [No socket cleanup], [Resource leaks on failed connections], [Medium],
  [No client validation], [Security vulnerability], [High],
  [Hard-coded IPs], [Reduces portability], [Low],
)

= Proposed Architecture

== High-Level Design

#figure(
  box(
    stroke: 1pt,
    inset: 15pt,
    radius: 5pt,
  )[
    #align(center)[
      *tcpServer() - Main Coordinator*
      
      #v(0.5cm)
      
      #grid(
        columns: 4,
        gutter: 10pt,
        box(stroke: 0.5pt, inset: 8pt, radius: 3pt)[
          Testing\
          Handler\
          Port 520
        ],
        box(stroke: 0.5pt, inset: 8pt, radius: 3pt)[
          Processing\
          Handler\
          Port 530
        ],
        box(stroke: 0.5pt, inset: 8pt, radius: 3pt)[
          Handling\
          Handler\
          Port 540
        ],
        box(stroke: 0.5pt, inset: 8pt, radius: 3pt)[
          Sorting\
          Handler\
          Port 550
        ],
      )
      
      #v(0.5cm)
      
      #box(stroke: 0.5pt, inset: 8pt, radius: 3pt, width: 80%)[
        *Shared Utilities*\
        InitServerSocket() • ValidateClient() • CleanupAllSockets()
      ]
    ]
  ],
  caption: [Proposed modular architecture]
)

== Key Components

=== 1. Main Coordinator (`tcpServer`)

- Entry point that initializes and coordinates all handlers
- Contains global ERROR and UNDO handlers for cleanup
- Can run handlers sequentially (single-task) or in parallel (multi-task)

=== 2. Station Handlers (one per port)

Each station gets its own handler routine:
- `TestingServerHandler()` - Port 520
- `ProcessingServerHandler()` - Port 530  
- `HandlingServerHandler()` - Port 540
- `SortingServerHandler()` - Port 550

Each handler:
- Initializes its own server socket
- Runs an accept loop with timeout (non-blocking)
- Validates client IP before processing
- Has its own ERROR/UNDO handlers for recovery
- Calls station-specific command processor

=== 3. Shared Utility Routines

- `InitServerSocket()` - Reusable socket setup with error handling
- `ValidateClient()` - IP whitelist checking
- `CleanupAllSockets()` - Global cleanup on shutdown
- `LogConnection()` - Audit logging

=== 4. Command Processors (one per station)

- `ProcessTestingCommand()`
- `ProcessProcessingCommand()`
- `ProcessHandlingCommand()`
- `ProcessSortingCommand()`

= Multi-Client Support

== Option A: Round-Robin Polling (Recommended)

For single-task systems - poll each port with short timeouts:

#box(
  stroke: 0.5pt,
  inset: 10pt,
  radius: 4pt,
  width: 100%,
)[
  *Polling Loop Pattern:*
  
  1. Initialize all 4 server sockets
  2. Main loop:
     - Poll Testing (100ms timeout) → handle if connection
     - Poll Processing (100ms timeout) → handle if connection
     - Poll Handling (100ms timeout) → handle if connection  
     - Poll Sorting (100ms timeout) → handle if connection
     - Repeat
  3. Use `SocketAccept \Time := 0.1` for non-blocking behavior
]

== Option B: Multi-Tasking (If Available)

Configure separate RAPID tasks in EIO.cfg:

#table(
  columns: (auto, 1fr),
  inset: 8pt,
  [*Task*], [*Handler*],
  [T_ROB1], [Main robot motion task],
  [T_TESTING], [TestingServerHandler()],
  [T_PROCESSING], [ProcessingServerHandler()],
  [T_HANDLING], [HandlingServerHandler()],
  [T_SORTING], [SortingServerHandler()],
)

= Error Handling Strategy

== Error Handler Pattern

Every socket operation needs three sections:

#table(
  columns: (auto, 1fr),
  inset: 8pt,
  align: (left, left),
  [*Section*], [*Purpose*],
  [Main code], [Normal socket operations],
  [ERROR], [Handle specific errors by ERRNO, use TRYNEXT/RETRY/RETURN],
  [UNDO], [Cleanup sockets when procedure exits unexpectedly],
)

== Error Recovery Actions

#table(
  columns: (auto, auto, 1fr),
  inset: 8pt,
  [*Error*], [*ERRNO*], [*Action*],
  [Timeout], [ERR_SOCK_TIMEOUT], [TRYNEXT - continue polling],
  [Disconnected], [ERR_SOCK_CLOSED], [Close socket, TRYNEXT],
  [Bind failed], [ERR_SOCK_BIND], [Log error, RETURN],
  [Other], [Any], [Log, WaitTime 1, RETRY],
)

= Security Improvements

== IP Whitelisting

- Store allowed IPs as PERS variables (configurable without recompile)
- Empty string = allow any IP
- Validate before processing commands

== Command Validation

Before executing any received command:
- Check command length (max ~100 chars)
- Validate command format (starts with uppercase letter)
- Use TEST/CASE for known commands only
- Reject unknown commands with error response

== Position Safety

Before executing movement commands from remote:
- Check robot Z height is above safe threshold
- Verify robot is not in restricted zone
- Return error if position is unsafe

== Connection Logging

Log all connection attempts via TPWrite:
- Station name
- Client IP
- Accepted/Rejected status

= Implementation Phases

== Phase 1: Error Handling (Low Risk)
*Effort: 2-4 hours*

- Add ERROR and UNDO handlers to existing `tcpServer()`
- Add `\Time` parameter to SocketAccept (timeout)
- Add TPWrite logging for connections

== Phase 2: Modular Routines (Medium Risk)
*Effort: 4-6 hours*

- Create `InitServerSocket()` utility
- Split into separate handler routines per station
- Add `ValidateClient()` function
- Create `CleanupAllSockets()` routine

== Phase 3: Multi-Client Support (Higher Risk)
*Effort: 6-10 hours*

- Implement polling loop with short timeouts
- OR configure multi-tasking (requires system config changes)
- Add position safety checks
- Add command validation

= Testing Checklist

== Functional Tests
- [ ] Each station can connect and receive response
- [ ] Multiple stations can connect in sequence
- [ ] Server recovers after client disconnects
- [ ] Server recovers after network timeout

== Security Tests
- [ ] Connections from wrong IP are rejected
- [ ] Invalid commands return error response
- [ ] Commands rejected when robot in unsafe position

== Stress Tests
- [ ] Rapid connect/disconnect cycles
- [ ] Long-running connections stay stable
- [ ] No memory/resource leaks over time

= Summary

#table(
  columns: (auto, 1fr),
  inset: 8pt,
  [*Improvement*], [*Benefit*],
  [Separate handler routines], [Clearer code, easier maintenance],
  [ERROR/UNDO handlers], [Crash recovery, no resource leaks],
  [Polling with timeouts], [Multi-client support],
  [IP validation], [Network security],
  [Position checks], [Robot safety],
  [Modular design], [Easier testing and extension],
)
