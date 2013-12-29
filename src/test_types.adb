with Ada.Text_IO.Text_Streams; use Ada.Text_IO; 
with Types.Builtin; use Types.Builtin;
 
procedure Test_Types is
   TestNode : constant NodeId := (FOURBYTE_NODEID, Byte'Val(1), 5);
   SS : constant Types.Builtin.String := Types.Builtin.String'(Create(new Bytes.A'("aa")));
   INS : Types.Builtin.Variant := (INT32_ARRAY_VARIANT, ListOfInt32.Null_Pointer, ListOfInt32.Create(new ListOfInt32.A'((1,2,3))));
   QN : Types.Builtin.Variant := (LOCALIZEDTEXT_VARIANT, LocalizedTexts.Create(new LocalizedText'(Create(null), Create(null))));
   VV : Types.Builtin.Variant := (VARIANT_VARIANT, Variants.Create(new Variant'(BOOLEAN_VARIANT, True)));
   SSV : Types.Builtin.Variant := (String_VARIANT, SS);
begin
   -- Binary_Write(Text_Streams.Stream (Current_Output), TestNode);
   -- Binary_Write(Text_Streams.Stream (Current_Output), TestNullString);
   -- Binary_Write(Text_Streams.Stream (Current_Output), QN);
   -- Binary_Write(Text_Streams.Stream (Current_Output), SSV);
   Binary_Read(Text_Streams.Stream(Current_Input), SSV);
   Binary_Write(Text_Streams.Stream(Current_Output), SSV);
end Test_Types;
