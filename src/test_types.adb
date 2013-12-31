with Ada.Text_IO.Text_Streams; use Ada.Text_IO; 
with Types.Builtin; use Types.Builtin;
 
procedure Test_Types is
   SS : constant Types.Builtin.String := Types.Builtin.String'(Create(new Bytes.A'("aa")));
   SSV : Types.Builtin.Variant := (String_VARIANT, SS);
begin
   Binary_Write(Text_Streams.Stream(Current_Output), SSV);
end Test_Types;
