with Interfaces.C;
with Ada.Streams;

package Types with Pure is
 
   type Int32 is new Interfaces.C.int;
   type UInt16 is new Interfaces.C.unsigned_short;
   
   type Binary_Streamable is interface;
   function Binary_Size(Item : in Binary_Streamable) return Int32 is abstract with Inline;
   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Binary_Streamable) is abstract;
   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Binary_Streamable) is abstract;
   
   type UA_Builtin is interface and Binary_Streamable; -- We might add more interfaces. XML-Serializable, etc.
   function NodeId_Nr(Item : in UA_Builtin) return UInt16 is abstract with Inline;
   
   type Array_Index is range 0 .. Integer'Last;

end Types;
