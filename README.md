openua
======

**openua** aims to become an open-source implementation of (one of the smaller profiles of) the OPC UA binary protocol.
openua is written in Ada (2012). This has the following advantages:


* Fast
* Can be linked with C-code (and interfaced to many other languages)
* Multi-plattform code (Win/Linux/Embedded, big & small-endian)
* No buffer overflows and no memory leaks (you can have those, but it is way easier to write safe code than in C)
* Built-in support for parallelism/concurrency
* Can be certified for high-risk applications (e.g. EAL)

Status
------
Currently, openua supports only reading/writing (all) data types defined in the UA standard from/to a binary stream. This includes handling of arrays and variable-size objects in a memory-safe way.

Examples
--------

**Create some UA built-in types and stream them to stdout**

    with Ada.Text_IO.Text_Streams; use Ada.Text_IO; 
    with Types.Builtin; use Types.Builtin;
 
    procedure Test_Types is
       TestNode : constant NodeId := (FOURBYTE_NODEID, Byte'Val(1), 5);
       TestNullString : constant Types.Builtin.String := Types.Builtin.String'(Create(null));
    begin
       Binary_Write(Text_Streams.Stream (Current_Output), TestNode);
       Binary_Write(Text_Streams.Stream (Current_Output), TestNullString);
    end Test_Types;
