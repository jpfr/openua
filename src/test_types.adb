with  Ada.Text_IO.Text_Streams; use Ada.Text_IO; 
with Types;
with Types.Builtin; use Types.Builtin;
 
procedure Test_Types is
   TestNode : constant NodeId := (FOURBYTE_NODEID, Byte'Val(1), 5);
   TestNullString : constant Types.Builtin.String := Types.Builtin.String'(Create(null));
begin
   Binary_Write(Text_Streams.Stream (Current_Output), TestNode);
   Binary_Write(Text_Streams.Stream (Current_Output), TestNullString);
end Test_Types;
