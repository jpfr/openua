with Ada.Unchecked_Conversion;
package body Types.BuiltIn is
   
   ------------
   --  Guid  --
   ------------
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Guid) is
   begin
   	 Int32'Write(Stream, Item.Data1);
   	 Int16'Write(Stream, Item.Data2);
   	 Int16'Write(Stream, Item.Data3);
   	 EightBytes'Write(Stream, Item.Data4);
   end Binary_Write;

   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Guid) is
   begin
	  Item := (Int32'Input(Stream), Int16'Input(Stream), Int16'Input(Stream), EightBytes'Input(Stream));
   end Binary_Read;

   --------------
   --  NodeId  --
   --------------
   type NodeId_Identifier is record
      Identifier_Type   : NodeIdType;
      Has_Server_Index  : Standard.Boolean;
      Has_Namespace_Uri : Standard.Boolean;
   end record;
   for NodeId_Identifier use record
      Identifier_Type   at 0 range 0 .. 5;
      Has_Server_Index  at 0 range 6 .. 6;
      Has_Namespace_Uri at 0 range 7 .. 7;
   end record;
   for NodeId_Identifier'Size use 8;

   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in NodeId_Identifier);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out NodeId_Identifier);
   for NodeId_Identifier'Write use Binary_Write;
   for NodeId_Identifier'Read use Binary_Read;

   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in NodeId_Identifier) is
	  Overlay : Byte;
	  for Overlay'Address use Item'Address;
   begin
	  Byte'Write(Stream, Overlay);
   end Binary_Write;

   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out NodeId_Identifier) is
	  Overlay : Byte;
	  for Overlay'Address use Item'Address;
   begin
	  Byte'Read(Stream, Overlay);
   end Binary_Read;
   
   function Binary_Size(Item : NodeId) return Int32 is
   begin
	  case Item.NodeId_Type is
		 when TWOBYTE_NODEID => return 2;
		 when FOURBYTE_NODEID => return 4;
		 when NUMERIC_NODEID => return 2 + 8;
		 when STRING_NODEID => return 2 + Binary_Size(Item.String_Identifier);
		 when GUID_NODEID => return 2 + 8;
		 when BYTESTRING_NODEID => return 2 + Binary_Size(Item.Byte_String_Identifier);
	  end case;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in NodeId) is
   begin
	  Binary_Write(Stream, NodeId_Identifier'(Item.NodeId_Type, False, False));
	  case Item.NodeId_Type is
		 when TWOBYTE_NODEID =>
			Byte'Write(Stream, Item.Byte_Identifier);
		 when FOURBYTE_NODEID =>
			Byte'Write(Stream, Item.Byte_Namespace);
			UInt16'Write(Stream, Item.UInt16_Identifier);
		 when NUMERIC_NODEID =>
			UInt16'Write(Stream, Item.Namespace);
			UInt32'Write(Stream, Item.Numeric_Identifier);
		 when STRING_NODEID =>
			UInt16'Write(Stream, Item.Namespace);
			NotNullString'Write(Stream, Item.String_Identifier);
		 when GUID_NODEID =>
			UInt16'Write(Stream, Item.Namespace);
			Guid'Write(Stream, Item.Guid_Identifier);
		 when BYTESTRING_NODEID =>
			UInt16'Write(Stream, Item.Namespace);
			NotNullByteString'Write(Stream, Item.Byte_String_Identifier);
	  end case;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out NodeId) is
      Identifier : constant NodeId_Identifier := NodeId_Identifier'Input(Stream);
   begin
	  case Identifier.Identifier_Type is
		 when TWOBYTE_NODEID => Item := (TWOBYTE_NODEID, Byte'Input(Stream));
		 when FOURBYTE_NODEID => Item := (FOURBYTE_NODEID, Byte'Input(Stream), UInt16'Input(Stream));
		 when NUMERIC_NODEID => Item := (NUMERIC_NODEID, UInt16'Input(Stream), UInt32'Input(Stream));
		 when STRING_NODEID => Item := (STRING_NODEID, UInt16'Input(Stream), NotNullString'Input(Stream));
		 when GUID_NODEID => Item := (GUID_NODEID, UInt16'Input(Stream), Guid'Input(Stream));
		 when BYTESTRING_NODEID => Item := (BYTESTRING_NODEID, UInt16'Input(Stream), NotNullByteString'Input(Stream));
	  end case;
   end Binary_Read;
   
   function Equal(A : NodeId; B : NodeId) return Standard.Boolean is
   begin
   	  if A.NodeId_Type = B.NodeId_Type then
   		 case A.NodeId_Type is
   			when TWOBYTE_NODEID => return A.Byte_Identifier = B.Byte_Identifier;
   			when FOURBYTE_NODEID => return A.Byte_Namespace = B.Byte_Namespace and then A.UInt16_Identifier = B.UInt16_Identifier;
   			when others =>
   			   if A.Namespace /= B.Namespace then
   				  return False;
   			   end if;
   			   case A.NodeId_Type is
   				  when NUMERIC_NODEID => return A.Numeric_Identifier = B.Numeric_Identifier;
   				  when STRING_NODEID => return A.String_Identifier = B.String_Identifier;
   				  when GUID_NODEID => return A.Guid_Identifier = B.Guid_Identifier;
   				  when BYTESTRING_NODEID => return A.Byte_String_Identifier = B.Byte_String_Identifier;
   				  when others => return False;
   			   end case;
   		 end case;
   	  else
   		 declare
   			A_Numeric : NodeId(NUMERIC_NODEID);
   		 begin
   			case A.NodeId_Type is
   			   when NUMERIC_NODEID => A_Numeric := A;
   			   when TWOBYTE_NODEID => A_Numeric := (NUMERIC_NODEID, 0, Byte'Pos(A.Byte_Identifier));
   			   when FOURBYTE_NODEID => A_Numeric := (NUMERIC_NODEID, Byte'Pos(A.Byte_Namespace), UInt32(A.UInt16_Identifier));
   			   when others => return False;
   			end case;
   			case B.NodeId_Type is
   			   when NUMERIC_NODEID => return B.Namespace = A_Numeric.Namespace and then B.Numeric_Identifier = A_Numeric.Numeric_Identifier;
   			   when TWOBYTE_NODEID => return A_Numeric.Namespace = 0 and then A_Numeric.Numeric_Identifier = Byte'Pos(B.Byte_Identifier);
   			   when FOURBYTE_NODEID => return A_Numeric.Namespace = Byte'Pos(B.Byte_Namespace) and then A_Numeric.Namespace = B.UInt16_Identifier;
   			   when others => return False;
   			end case;
   		 end;
   	  end if;
   end Equal;

   ----------------------
   --  ExpandedNodeId  --
   ----------------------
   function Binary_Size (Item : ExpandedNodeId) return Int32 is
   	  Size : Int32 := 0;
   begin
   	  if not Item.Namespace_Uri.Is_Null then
   		 Size := Size + Binary_Size(Item.Namespace_Uri);
   	  end if;
   	  if not Item.Server_Index.Is_Null then
   		 Size := Size + 4;
   	  end if;
   	  case Item.NodeId_Type is
         when TWOBYTE_NODEID => Size := Size + 2;
         when FOURBYTE_NODEID => Size := Size + 4;
         when others =>
   			Size := Size + 2; -- namespace with 2 bytes
            case Item.NodeId_Type is
               when NUMERIC_NODEID => Size := Size + 4;
               when STRING_NODEID => Size := Size + Binary_Size (Item.String_Identifier);
               when GUID_NODEID => Size := Size + 8;
               when BYTESTRING_NODEID => Size := Size + Binary_Size(Item.Byte_String_Identifier);
               when others =>
                  null;
            end case;
   	  end case;
   	  return Size;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in ExpandedNodeId) is
   begin
      Binary_Write(Stream, NodeId_Identifier'(Item.NodeId_Type, not Item.Server_Index.Is_Null, not Item.Namespace_Uri.Is_Null));
      case Item.NodeId_Type is
   		 when TWOBYTE_NODEID =>
   			Byte'Write(Stream, Item.Byte_Identifier);
   		 when FOURBYTE_NODEID =>
   			Byte'Write(Stream, Item.Byte_Namespace);
   			UInt16'Write(Stream, Item.UInt16_Identifier);
   		 when NUMERIC_NODEID =>
   			UInt16'Write(Stream, Item.Namespace);
   			UInt32'Write(Stream, Item.Numeric_Identifier);
   		 when STRING_NODEID =>
   			UInt16'Write(Stream, Item.Namespace);
   			NotNullString'Write(Stream, Item.String_Identifier);
   		 when GUID_NODEID =>
   			UInt16'Write(Stream, Item.Namespace);
   		    Guid'Write(Stream, Item.Guid_Identifier);
   		 when BYTESTRING_NODEID =>
   			UInt16'Write(Stream, Item.Namespace);
   			NotNullByteString'Write(Stream, Item.Byte_String_Identifier);
      end case;
      if not Item.Namespace_Uri.Is_Null then
         String'Write(Stream, Item.Namespace_Uri);
      end if;
      if not Item.Server_Index.Is_Null then
         UInt32'Write(Stream, Item.Server_Index.Get);
      end if;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out ExpandedNodeId) is
      Identifier : constant NodeId_Identifier := NodeId_Identifier'Input(Stream);
      Namespace_Uri : String := Create(null);
      Server_Index : UInt32s.Nullable_Pointer := Uint32s.Null_Pointer;
      Base_Node : NodeId(Identifier.Identifier_Type);
   begin
      case Identifier.Identifier_Type is
   		 when TWOBYTE_NODEID => Base_Node := (TWOBYTE_NODEID, Byte'Input(Stream));
   		 when FOURBYTE_NODEID => Base_Node := (FOURBYTE_NODEID, Byte'Input(Stream), UInt16'Input(Stream));
   		 when NUMERIC_NODEID => Base_Node := (NUMERIC_NODEID, UInt16'Input(Stream), UInt32'Input(Stream));
   		 when STRING_NODEID => Base_Node := (STRING_NODEID, UInt16'Input(Stream), NotNullString'Input(Stream));
   		 when GUID_NODEID => Base_Node := (GUID_NODEID, UInt16'Input(Stream), Guid'Input(Stream));
   		 when BYTESTRING_NODEID => Base_Node := (BYTESTRING_NODEID, UInt16'Input(Stream), NotNullByteString'Input(Stream));
      end case;
      if Identifier.Has_Namespace_Uri then
   		 Namespace_Uri := String'Input(Stream);
      end if;
      if Identifier.Has_Server_Index then
         Server_Index := UInt32s.Create(new UInt32'(UInt32'Input(Stream)));
      end if;
      case Base_Node.NodeId_Type is
         when TWOBYTE_NODEID => Item := (TWOBYTE_NODEID, Base_Node.Byte_Identifier, Namespace_Uri, Server_Index);
         when FOURBYTE_NODEID => Item := (FOURBYTE_NODEID, Base_Node.Byte_Namespace, Base_Node.UInt16_Identifier, Namespace_Uri, Server_Index);
         when NUMERIC_NODEID => Item := (NUMERIC_NODEID, Base_Node.Namespace, Base_Node.Numeric_Identifier, Namespace_Uri, Server_Index);
         when STRING_NODEID => Item := (STRING_NODEID, Base_Node.Namespace, Base_Node.String_Identifier, Namespace_Uri, Server_Index);
         when GUID_NODEID => Item := (GUID_NODEID, Base_Node.Namespace, Base_Node.Guid_Identifier, Namespace_Uri, Server_Index);
         when BYTESTRING_NODEID => Item := (BYTESTRING_NODEID, Base_Node.Namespace, Base_Node.Byte_String_Identifier, Namespace_Uri, Server_Index);
      end case;
   end Binary_Read;
   
   ----------------------
   --  DiagnosticInfo  --
   ----------------------
   type DiagnosticInfo_Encoding is record
      Symbolic_Id          : Standard.Boolean;
      Namespace_Uri        : Standard.Boolean;
      Localized_Text       : Standard.Boolean;
      Locale              : Standard.Boolean;
      Additional_Info      : Standard.Boolean;
      Inner_Status_Code     : Standard.Boolean;
      Inner_Diagnostic_Info : Standard.Boolean;
   end record;
   for DiagnosticInfo_Encoding use record
      Symbolic_Id          at 0 range 0 .. 0;
      Namespace_Uri        at 0 range 1 .. 1;
      Localized_Text       at 0 range 2 .. 2;
      Locale              at 0 range 3 .. 3;
      Additional_Info      at 0 range 4 .. 4;
      Inner_Status_Code     at 0 range 5 .. 5;
      Inner_Diagnostic_Info at 0 range 6 .. 6;
   end record;
   for DiagnosticInfo_Encoding'Size use 8;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DiagnosticInfo_Encoding);
   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out DiagnosticInfo_Encoding);
   for DiagnosticInfo_Encoding'Write use Binary_Write;
   for DiagnosticInfo_Encoding'Read use Binary_Read;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DiagnosticInfo_Encoding) is
   	  Overlay : Byte;
   	  for Overlay'Address use Item'Address;
   begin
   	  Byte'Write(Stream, Overlay);
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out DiagnosticInfo_Encoding) is
   	  Overlay : Byte;
   	  for Overlay'Address use Item'Address;
   begin
   	  Byte'Read(Stream, Overlay);
   end Binary_Read;
   
   function Binary_Size(Item : DiagnosticInfo) return Int32 is
   	  Size : Int32 := 1; -- Encoding Item
   begin
   	  if not Item.Symbolic_Id.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.Namespace_Uri.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.Localized_Text.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.Locale.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.Additional_Info.Is_Null then
   	  	 Size := Size + Binary_Size(Item.Additional_Info);
   	  end if;
   	  if not Item.Inner_Status_Code.Is_Null then
   	  	 Size := Size + 8;
   	  end if;
   	  if not Item.Inner_Diagnostic_Info.Is_Null then
   	  	 Size := Size + Binary_Size(DiagnosticInfo(Item.Inner_Diagnostic_Info.Get.Data.all));
   	  end if;
   	  return Size;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DiagnosticInfo) is
      Encoding : constant DiagnosticInfo_Encoding := (not Item.Symbolic_Id.Is_Null, not Item.Namespace_Uri.Is_Null, not Item.Localized_Text.Is_Null,
                                                      not Item.Locale.Is_Null, not Item.Additional_Info.Is_Null, not Item.Inner_Status_Code.Is_Null,
                                                      not Item.Inner_Diagnostic_Info.Is_Null);
   begin
      Binary_Write(Stream, Encoding);
      if not Item.Symbolic_Id.Is_Null then
         Int32'Write(Stream, Item.Symbolic_Id.Get);
      end if;
      if not Item.Namespace_Uri.Is_Null then
         Int32'Write(Stream, Item.Namespace_Uri.Get);
      end if;
      if not Item.Localized_Text.Is_Null then
         Int32'Write(Stream, Item.Localized_Text.Get);
      end if;
      if not Item.Locale.Is_Null then
         Int32'Write(Stream, Item.Locale.Get);
      end if;
      if not Item.Additional_Info.Is_Null then
         String'Write(Stream, Item.Additional_Info);
      end if;
      if not Item.Inner_Status_Code.Is_Null then
         StatusCode'Write(Stream, Item.Inner_Status_Code.Get);
      end if;
      if not Item.Inner_Diagnostic_Info.Is_Null then
         Binary_Write(Stream, DiagnosticInfo(Item.Inner_Diagnostic_Info.Get.Data.all));
      end if;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out DiagnosticInfo) is
      Encoding : constant DiagnosticInfo_Encoding := DiagnosticInfo_Encoding'Input(Stream);
   begin
      if Encoding.Symbolic_Id then
         Item.Symbolic_Id := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.Symbolic_Id := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.Namespace_Uri then
         Item.Namespace_Uri := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.Namespace_Uri := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.Localized_Text then
         Item.Localized_Text := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.Localized_Text := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.Locale then
         Item.Locale := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.Locale := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.Additional_Info then
         Item.Additional_Info := String'Input(Stream);
   	  else
   	  	 Item.Additional_Info := Create(null);
      end if;
      
   	  if Encoding.Inner_Status_Code then
         Item.Inner_Status_Code := StatusCodes.Create(new StatusCode'(StatusCode'Input(Stream)));
   	  else
   	  	 Item.Inner_Status_Code := StatusCodes.Null_Pointer;
      end if;
	  
      if Encoding.Inner_Diagnostic_Info then
         Item.Inner_Diagnostic_Info := DiagnosticInfos.Create(new DiagnosticInfo'(DiagnosticInfo'Input(Stream)));
   	  else
   	  	 Item.Inner_Diagnostic_Info := DiagnosticInfos.Null_Pointer;
      end if;
   end Binary_Read;

   ---------------------
   --  LocalizedText  --
   ---------------------
   type LocalizedText_Encoding is record
      Locale : Standard.Boolean;
      Text   : Standard.Boolean;
   end record;
   for LocalizedText_Encoding use record
      Locale at 0 range 0 .. 0;
      Text   at 0 range 1 .. 1;
   end record;
   for LocalizedText_Encoding'Size use 8;

   function Binary_Size(Item : LocalizedText) return Int32 is
	  Size : Int32 := 1; -- with encoding
   begin
      if not Item.Locale.Is_Null then
         Size := Size + Binary_Size(Item.Locale);
      end if;
      if not Item.Text.Is_Null then
         Size := Size + Binary_Size(Item.Text);
      end if;
	  return Size;
   end Binary_Size;
   
   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in LocalizedText) is
      Encoding : constant LocalizedText_Encoding := (not Item.Locale.Is_Null, not Item.Text.Is_Null);
   begin
      LocalizedText_Encoding'Write(Stream, Encoding);
      if not Item.Locale.Is_Null then
         String'Write(Stream, Item.Locale);
      end if;
      if not Item.Text.Is_Null then
         String'Write(Stream, Item.Text);
      end if;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out LocalizedText) is
      Encoding : constant LocalizedText_Encoding := LocalizedText_Encoding'Input(Stream);
   begin
      Item := (Create(null), Create(null));
      if Encoding.Locale then
         Item.Locale := String'Input(Stream);
      end if;
      if Encoding.Text then
         Item.Text := String'Input(Stream);
      end if;
   end Binary_Read;
   
   -----------------------
   --  ExtensionObject  --
   -----------------------
   function Binary_Size(Item : ExtensionObject) return Int32 is
	  Size : Int32 := 1; -- Incl. Encoding
   begin
	  Size := Size + Binary_Size(Item.TypeId.Get);
      case Item.Encoding is
         when NO_BODY => null;
         when BYTESTRING_BODY => Size := Size + Binary_Size(Item.Byte_String_Body);
         when XMLELEMENT_BODY => Size := Size + Binary_Size(Item.Xml_Element_Body);
      end case;
	  return Size;
   end Binary_Size;
	  
   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in ExtensionObject) is
   begin
      Binary_Write(Stream, Item.TypeId.Get);
      ExtensionObject_Encoding'Write(Stream, Item.Encoding);
      case Item.Encoding is
         when NO_BODY => null;
         when BYTESTRING_BODY => NotNullByteString'Write(Stream, Item.Byte_String_Body);
         when XMLELEMENT_BODY => NotNullXmlElement'Write(Stream, Item.Xml_Element_Body);
      end case;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out ExtensionObject) is
      Type_Id : constant ExpandedNodeIds.Pointer := ExpandedNodeIds.Create(new ExpandedNodeId'(ExpandedNodeId'Input(Stream)));
      Object_Encoding : constant ExtensionObject_Encoding := ExtensionObject_Encoding'Input(Stream);
   begin
      case Object_Encoding is
         when NO_BODY => Item := ExtensionObject'(NO_BODY, Type_Id);
         when BYTESTRING_BODY => Item := ExtensionObject'(BYTESTRING_BODY, Type_Id, NotNullByteString'Input(Stream));
         when XMLELEMENT_BODY => Item := ExtensionObject'(XMLELEMENT_BODY, Type_Id, NotNullXmlElement'Input(Stream));
      end case;
   end Binary_Read;
   
   ---------------------
   --  QualifiedName  --
   ---------------------
   function Binary_Size(Item : QualifiedName) return Int32 is
   begin
	  return 2 + Binary_Size(Item.Name);
   end Binary_Size;
   
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in QualifiedName) is
   begin
	  UInt16'Write(Stream, Item.Namespace_Index);
	  NotNullString'Write(Stream, Item.Name);
   end Binary_Write;

   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out QualifiedName) is
   begin
	  Item := (Uint16'Input(Stream), NotNullString'Input(Stream));
   end Binary_Read;

   -----------------
   --  DataValue  --
   -----------------
   type DataValue_Encoding is record
      Has_Value             : Standard.Boolean;
      Has_Status            : Standard.Boolean;
      Has_Source_Timestamp   : Standard.Boolean;
      Has_Server_Timestamp   : Standard.Boolean;
      Has_Source_Picoseconds : Standard.Boolean;
      Has_Server_Picoseconds : Standard.Boolean;
   end record;
   for DataValue_Encoding use record
      Has_Value             at 0 range 0 .. 0;
      Has_Status            at 0 range 1 .. 1;
      Has_Source_Timestamp   at 0 range 2 .. 2;
      Has_Server_Timestamp   at 0 range 3 .. 3;
      Has_Source_Picoseconds at 0 range 4 .. 4;
      Has_Server_Picoseconds at 0 range 5 .. 5;
   end record;
   for DataValue_Encoding'Size use 8;

   function Binary_Size(Item : DataValue) return Int32 is
	  Size : Int32 := 1; -- with Encoding
   begin
	  if not Item.Value.Is_Null then
		 Size := Size + Binary_Size(Variant(Item.Value.Get.Data.all));
	  end if;
	  if not Item.Status.Is_Null then
		 Size := Size + 4;
	  end if;
	  if not Item.Source_Timestamp.Is_Null then
		 Size := Size + 8;
	  end if;
	  if not Item.Source_Picoseconds.Is_Null then
		 Size := Size + 2;
	  end if;
	  if not Item.Server_Timestamp.Is_Null then
		 Size := Size + 8;
	  end if;
	  if not Item.Server_Picoseconds.Is_Null then
		 Size := Size + 2;
	  end if;
	  return Size;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DataValue) is
      Encoding : constant DataValue_Encoding := (not Item.Value.Is_Null, not Item.Status.Is_Null, not Item.Source_Timestamp.Is_Null,
                                                 not Item.Source_Picoseconds.Is_Null, not Item.Server_Timestamp.Is_Null,
                                                 not Item.Server_Picoseconds.Is_Null);
   begin
      DataValue_Encoding'Write(Stream, Encoding);
      if not Item.Value.Is_Null then
		 Variant'Write(Stream, Variant(Item.Value.Get.Data.all));
      end if;
      if not Item.Status.Is_Null then
         StatusCode'Write(Stream, Item.Status.Get);
      end if;
      if not Item.Source_Timestamp.Is_Null then
         DateTime'Write(Stream, Item.Source_Timestamp.Get);
      end if;
      if not Item.Source_Picoseconds.Is_Null then
         UInt16'Write(Stream, Item.Source_Picoseconds.Get);
      end if;
      if not Item.Server_Timestamp.Is_Null then
         DateTime'Write(Stream, Item.Server_Timestamp.Get);
      end if;
      if not Item.Server_Picoseconds.Is_Null then
         UInt16'Write(Stream, Item.Server_Picoseconds.Get);
      end if;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out DataValue) is
      Encoding : constant DataValue_Encoding := DataValue_Encoding'Input(Stream);
   begin
      Item := (Variants.Create(null), StatusCodes.Create(null), DateTimes.Create(null), UInt16s.Create(null), DateTimes.Create(null), UInt16s.Create(null));
      if Encoding.Has_Value then
         Item.Value := Variants.Create(new Variant'(Variant'Input(Stream)));
      end if;
      if Encoding.Has_Status then
         Item.Status := StatusCodes.Create(new StatusCode'(StatusCode'Input(Stream)));
      end if;
      if Encoding.Has_Source_Timestamp then
         Item.Source_Timestamp := DateTimes.Create(new DateTime'(DateTime'Input(Stream)));
      end if;
      if Encoding.Has_Source_Picoseconds then
         Item.Source_Picoseconds := UInt16s.Create(new UInt16'(UInt16'Input(Stream)));
      end if;
      if Encoding.Has_Server_Timestamp then
         Item.Server_Timestamp := DateTimes.Create(new DateTime'(DateTime'Input(Stream)));
      end if;
      if Encoding.Has_Server_Picoseconds then
         Item.Server_Picoseconds := UInt16s.Create(new UInt16'(UInt16'Input(Stream)));
      end if;
   end Binary_Read;

   ---------------
   --  Variant  --
   ---------------
   function VariantType2Byte is new Ada.Unchecked_Conversion(VariantType, Byte);
   function Byte2VariantType is new Ada.Unchecked_Conversion(Byte, VariantType);

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Variant) is
	  Encoding_Byte : Byte := VariantType2Byte(Item.Variant_Type);
   begin
	  if VariantType'Pos(Item.Variant_Type) > 128 and then not Item.Array_Dimensions.Is_Null then
		 Encoding_Byte := Encoding_Byte + 64;
	  end if;
	  Byte'Write(Stream, Encoding_Byte);
	  case Item.Variant_Type is
		 when BOOLEAN_VARIANT => Boolean'Write(Stream, Item.Boolean_Value);
		 when SBYTE_VARIANT => SByte'Write(Stream, Item.SByte_Value);
		 when BYTE_VARIANT => Byte'Write(Stream, Item.Byte_Value);
		 when INT16_VARIANT => Int16'Write(Stream, Item.Int16_Value);
		 when UINT16_VARIANT => UInt16'Write(Stream, Item.UInt16_Value);
		 when INT32_VARIANT => Int32'Write(Stream, Item.Int32_Value);
		 when UINT32_VARIANT => UInt32'Write(Stream, Item.UInt32_Value);
		 when INT64_VARIANT => Int64'Write(Stream, Item.Int64_Value);
		 when UINT64_VARIANT => UInt64'Write(Stream, Item.UInt64_Value);
		 when FLOAT_VARIANT => Float'Write(Stream, Item.Float_Value);
		 when DOUBLE_VARIANT => Double'Write(Stream,Item.Double_Value);
		 when STRING_VARIANT => String'Write(Stream,Item.String_Value);
		 when DATETIME_VARIANT => DateTime'Write(Stream,Item.Date_Time_Value);
		 when GUID_VARIANT => Guid'Write(Stream,Item.Guid_Value);
		 when BYTESTRING_VARIANT => ByteString'Write(Stream,Item.Byte_String_Value);
		 when XMLELEMENT_VARIANT => XmlElement'Write(Stream,Item.Xml_Element_Value);
		 when NODEID_VARIANT => Binary_Write(Stream, Item.Node_Id_Value.Get);
		 when EXPANDEDNODEID_VARIANT => Binary_Write(Stream,Item.Expanded_Node_Id_Value.Get);
		 when STATUSCODE_VARIANT => StatusCode'Write(Stream,Item.Status_Code_Value);
		 when QUALIFIEDNAME_VARIANT => Binary_Write(Stream,Item.Qualified_Name_Value.Get);
		 when LOCALIZEDTEXT_VARIANT => Binary_Write(Stream,Item.Localized_Text_Value.Get);
		 when EXTENSIONOBJECT_VARIANT => Binary_Write(Stream,Item.Extension_Object_Value.Get);
		 when DATAVALUE_VARIANT => Binary_Write(Stream,Item.Data_Value_Value.Get);
		 when VARIANT_VARIANT => Binary_Write(Stream, Variant(Item.Variant_Value.Get.Data.all));
		 when DIAGNOSTICINFO_VARIANT => Binary_Write(Stream, DiagnosticInfo(Item.Diagnostic_Info_Value.Get.Data.all));
		 when others =>
			case Item.Variant_Type is
			   when BOOLEAN_ARRAY_VARIANT => ListOfBoolean.Pointer'Write(Stream, Item.Boolean_Values);
			   when SBYTE_ARRAY_VARIANT => ListOfSByte.Pointer'Write(Stream, Item.SByte_Values);
			   when BYTE_ARRAY_VARIANT => ListOfByte.Pointer'Write(Stream, Item.Byte_Values);
			   when INT16_ARRAY_VARIANT => ListOfInt16.Pointer'Write(Stream, Item.Int16_Values);
			   when UINT16_ARRAY_VARIANT => ListOfUInt16.Pointer'Write(Stream, Item.UInt16_Values);
			   when INT32_ARRAY_VARIANT => ListOfInt32.Pointer'Write(Stream, Item.Int32_Values);
			   when UINT32_ARRAY_VARIANT => ListOfUInt32.Pointer'Write(Stream, Item.UInt32_Values);
			   when INT64_ARRAY_VARIANT => ListOfInt64.Pointer'Write(Stream, Item.Int64_Values);
			   when UINT64_ARRAY_VARIANT => ListOfUInt64.Pointer'Write(Stream, Item.UInt64_Values);
			   when FLOAT_ARRAY_VARIANT => ListOfFloat.Pointer'Write(Stream, Item.Float_Values);
			   when DOUBLE_ARRAY_VARIANT => ListOfDouble.Pointer'Write(Stream, Item.Double_Values);
			   when STRING_ARRAY_VARIANT => ListOfString.Pointer'Write(Stream, Item.String_Values);
			   when DATETIME_ARRAY_VARIANT => ListOfDateTime.Pointer'Write(Stream, Item.Date_Time_Values);
			   when GUID_ARRAY_VARIANT => ListOfGuid.Pointer'Write(Stream, Item.Guid_Values);
			   when BYTESTRING_ARRAY_VARIANT => ListOfByteString.Pointer'Write(Stream, Item.Byte_String_Values);
			   when XMLELEMENT_ARRAY_VARIANT => ListOfXmlElement.Pointer'Write(Stream, Item.Xml_Element_Values);
			   when NODEID_ARRAY_VARIANT => ListOfNodeId.Pointer'Write(Stream, Item.Node_Id_Values);
			   when EXPANDEDNODEID_ARRAY_VARIANT => ListOfExpandedNodeId.Pointer'Write(Stream, Item.Expanded_Node_Id_Values);
			   when STATUSCODE_ARRAY_VARIANT => ListOfStatusCode.Pointer'Write(Stream, Item.Status_Code_Values);
			   when QUALIFIEDNAME_ARRAY_VARIANT => ListOfQualifiedName.Pointer'Write(Stream, Item.Qualified_Name_Values);
			   when LOCALIZEDTEXT_ARRAY_VARIANT => ListOfLocalizedText.Pointer'Write(Stream, Item.Localized_Text_Values);
			   when EXTENSIONOBJECT_ARRAY_VARIANT => ListOfExtensionObject.Pointer'Write(Stream, Item.Extension_Object_Values);
			   when DATAVALUE_ARRAY_VARIANT => ListOfDataValue.Pointer'Write(Stream, Item.Data_Value_Values);
			   when VARIANT_ARRAY_VARIANT => ListOfVariant.Pointer'Write(Stream, Item.Variant_Values);
			   when DIAGNOSTICINFO_ARRAY_VARIANT => ListOfDiagnosticInfo.Pointer'Write(Stream, Item.Diagnostic_Info_Values);
			   when others => null;
			end case;
			if not Item.Array_Dimensions.Is_Null then
			   ListOfInt32.Nullable_Pointer'Write(Stream, Item.Array_Dimensions);
			end if;
      end case;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Variant) is
      Encoding_Byte : Byte := Byte'Input(Stream);
	  With_Array_Dimensions : constant Standard.Boolean := (Encoding_Byte and 64) > 0;
   begin
	  if With_Array_Dimensions then
		 Encoding_Byte := Encoding_Byte - 64;
	  end if;
	  case Byte2VariantType(Encoding_Byte) is
		 when BOOLEAN_VARIANT => Item := Variant'(BOOLEAN_VARIANT, Boolean'Input(Stream));
		 when SBYTE_VARIANT => Item := Variant'(SBYTE_VARIANT, SByte'Input(Stream));
		 when BYTE_VARIANT => Item := Variant'(BYTE_VARIANT, Byte'Input(Stream));
		 when INT16_VARIANT => Item := Variant'(INT16_VARIANT, Int16'Input(Stream));
		 when UINT16_VARIANT => Item := Variant'(UINT16_VARIANT, UInt16'Input(Stream));
		 when INT32_VARIANT => Item := Variant'(INT32_VARIANT, Int32'Input(Stream));
		 when UINT32_VARIANT => Item := Variant'(UINT32_VARIANT, UInt32'Input(Stream));
		 when INT64_VARIANT => Item := Variant'(INT64_VARIANT, Int64'Input(Stream));
		 when UINT64_VARIANT => Item := Variant'(UINT64_VARIANT, UInt64'Input(Stream));
		 when FLOAT_VARIANT => Item := Variant'(FLOAT_VARIANT, Float'Input(Stream));
		 when DOUBLE_VARIANT => Item := Variant'(DOUBLE_VARIANT, Double'Input(Stream));
		 when STRING_VARIANT => Item := Variant'(STRING_VARIANT, String'Input(Stream));
		 when DATETIME_VARIANT => Item := Variant'(DATETIME_VARIANT, DateTime'Input(Stream));
		 when GUID_VARIANT => Item := Variant'(GUID_VARIANT, Guid'Input(Stream));
		 when BYTESTRING_VARIANT => Item := Variant'(BYTESTRING_VARIANT, ByteString'Input(Stream));
		 when XMLELEMENT_VARIANT => Item := Variant'(XMLELEMENT_VARIANT, XmlElement'Input(Stream));
		 when NODEID_VARIANT => Item := Variant'(NODEID_VARIANT, NodeIds.Create(new NodeId'(NodeId'Input(Stream))));
		 when EXPANDEDNODEID_VARIANT => Item := Variant'(EXPANDEDNODEID_VARIANT, ExpandedNodeIds.Create(new ExpandedNodeId'(ExpandedNodeId'Input(Stream))));
		 when STATUSCODE_VARIANT => Item := Variant'(STATUSCODE_VARIANT, StatusCode'Input(Stream));
		 when QUALIFIEDNAME_VARIANT => Item := Variant'(QUALIFIEDNAME_VARIANT, QualifiedNames.Create(new QualifiedName'(QualifiedName'Input(Stream))));
		 when LOCALIZEDTEXT_VARIANT => Item := Variant'(LOCALIZEDTEXT_VARIANT, LocalizedTexts.Create(new LocalizedText'(LocalizedText'Input(Stream))));
		 when EXTENSIONOBJECT_VARIANT => Item := Variant'(EXTENSIONOBJECT_VARIANT, ExtensionObjects.Create(new ExtensionObject'(ExtensionObject'Input(Stream))));
		 when DATAVALUE_VARIANT => Item := Variant'(DATAVALUE_VARIANT, DataValues.Create(new DataValue'(DataValue'Input(Stream))));
		 when VARIANT_VARIANT => Item := Variant'(VARIANT_VARIANT, Variants.Create(new Variant'(Variant'Input(Stream))));
		 when DIAGNOSTICINFO_VARIANT => Item := Variant'(DIAGNOSTICINFO_VARIANT, DiagnosticInfos.Create(new DiagnosticInfo'(DiagnosticInfo'Input(Stream))));
		 when others =>
			declare
			   Empty_Dimensions : constant ListOfInt32.Nullable_Pointer := ListOfInt32.Create(null);
			begin
			   case Byte2VariantType(Encoding_Byte) is
				  when BOOLEAN_ARRAY_VARIANT => Item := Variant'(BOOLEAN_ARRAY_VARIANT, Empty_Dimensions, ListOfBoolean.Pointer'Input(Stream));
				  when SBYTE_ARRAY_VARIANT => Item := Variant'(SBYTE_ARRAY_VARIANT, Empty_Dimensions, ListOfSByte.Pointer'Input(Stream));
				  when BYTE_ARRAY_VARIANT => Item := Variant'(BYTE_ARRAY_VARIANT, Empty_Dimensions, ListOfByte.Pointer'Input(Stream));
				  when INT16_ARRAY_VARIANT => Item := Variant'(INT16_ARRAY_VARIANT, Empty_Dimensions, ListOfInt16.Pointer'Input(Stream));
				  when UINT16_ARRAY_VARIANT => Item := Variant'(UINT16_ARRAY_VARIANT, Empty_Dimensions, ListOfUInt16.Pointer'Input(Stream));
				  when INT32_ARRAY_VARIANT => Item := Variant'(INT32_ARRAY_VARIANT, Empty_Dimensions, ListOfInt32.Pointer'Input(Stream));
				  when UINT32_ARRAY_VARIANT => Item := Variant'(UINT32_ARRAY_VARIANT, Empty_Dimensions, ListOfUInt32.Pointer'Input(Stream));
				  when INT64_ARRAY_VARIANT => Item := Variant'(INT64_ARRAY_VARIANT, Empty_Dimensions, ListOfInt64.Pointer'Input(Stream));
				  when UINT64_ARRAY_VARIANT => Item := Variant'(UINT64_ARRAY_VARIANT, Empty_Dimensions, ListOfUInt64.Pointer'Input(Stream));
				  when FLOAT_ARRAY_VARIANT => Item := Variant'(FLOAT_ARRAY_VARIANT, Empty_Dimensions, ListOfFloat.Pointer'Input(Stream));
				  when DOUBLE_ARRAY_VARIANT => Item := Variant'(DOUBLE_ARRAY_VARIANT, Empty_Dimensions, ListOfDouble.Pointer'Input(Stream));
				  when STRING_ARRAY_VARIANT => Item := Variant'(STRING_ARRAY_VARIANT, Empty_Dimensions, ListOfString.Pointer'Input(Stream));
				  when DATETIME_ARRAY_VARIANT => Item := Variant'(DATETIME_ARRAY_VARIANT, Empty_Dimensions, ListOfDateTime.Pointer'Input(Stream));
				  when GUID_ARRAY_VARIANT => Item := Variant'(GUID_ARRAY_VARIANT, Empty_Dimensions, ListOfGuid.Pointer'Input(Stream));
				  when BYTESTRING_ARRAY_VARIANT => Item := Variant'(BYTESTRING_ARRAY_VARIANT, Empty_Dimensions, ListOfByteString.Pointer'Input(Stream));
				  when XMLELEMENT_ARRAY_VARIANT => Item := Variant'(XMLELEMENT_ARRAY_VARIANT, Empty_Dimensions, ListOfXmlElement.Pointer'Input(Stream));
				  when NODEID_ARRAY_VARIANT => Item := Variant'(NODEID_ARRAY_VARIANT, Empty_Dimensions, ListOfNodeId.Pointer'Input(Stream));
				  when EXPANDEDNODEID_ARRAY_VARIANT => Item := Variant'(EXPANDEDNODEID_ARRAY_VARIANT, Empty_Dimensions, ListOfExpandedNodeId.Pointer'Input(Stream));
				  when STATUSCODE_ARRAY_VARIANT => Item := Variant'(STATUSCODE_ARRAY_VARIANT, Empty_Dimensions, ListOfStatusCode.Pointer'Input(Stream));
				  when QUALIFIEDNAME_ARRAY_VARIANT => Item := Variant'(QUALIFIEDNAME_ARRAY_VARIANT, Empty_Dimensions, ListOfQualifiedName.Pointer'Input(Stream));
				  when LOCALIZEDTEXT_ARRAY_VARIANT => Item := Variant'(LOCALIZEDTEXT_ARRAY_VARIANT, Empty_Dimensions, ListOfLocalizedText.Pointer'Input(Stream));
				  when EXTENSIONOBJECT_ARRAY_VARIANT => Item := Variant'(EXTENSIONOBJECT_ARRAY_VARIANT, Empty_Dimensions, ListOfExtensionObject.Pointer'Input(Stream));
				  when DATAVALUE_ARRAY_VARIANT => Item := Variant'(DATAVALUE_ARRAY_VARIANT, Empty_Dimensions, ListOfDataValue.Pointer'Input(Stream));
				  when VARIANT_ARRAY_VARIANT => Item := Variant'(VARIANT_ARRAY_VARIANT, Empty_Dimensions, ListOfVariant.Pointer'Input(Stream));
				  when DIAGNOSTICINFO_ARRAY_VARIANT => Item := Variant'(DIAGNOSTICINFO_ARRAY_VARIANT, Empty_Dimensions, ListOfDiagnosticInfo.Pointer'Input(Stream));
				  when others => null;
			   end case;
			   if With_Array_Dimensions then
			   	  Item.Array_Dimensions := ListOfInt32.Nullable_Pointer'(ListOfInt32.Nullable_Pointer'Input(Stream));
			   end if;
			end;
   	  end case;
   end Binary_Read;

   function Binary_Size(Item : in Variant) return Int32 is
	  Size : Int32 := 1; -- with encoding
   begin
	  case Item.Variant_Type is
		 when BOOLEAN_VARIANT | SBYTE_VARIANT | BYTE_VARIANT => Size := Size + 1;
		 when INT16_VARIANT | UINT16_VARIANT => Size := Size + 2;
		 when INT32_VARIANT | UINT32_VARIANT | FLOAT_VARIANT | STATUSCODE_VARIANT => Size := Size + 4;
		 when INT64_VARIANT | UINT64_VARIANT | DOUBLE_VARIANT | DATETIME_VARIANT => Size := Size + 8;
		 when STRING_VARIANT => Size := Size + Binary_Size(Item.String_Value);
		 when GUID_VARIANT => Size := Size + Binary_Size(Item.Guid_Value);
		 when BYTESTRING_VARIANT => Size := Size + Binary_Size(Item.Byte_String_Value);
		 when XMLELEMENT_VARIANT => Size := Size + Binary_Size(Item.Xml_Element_Value);
		 when NODEID_VARIANT => Size := Size + Item.Node_Id_Value.Binary_Size;
		 when EXPANDEDNODEID_VARIANT => Size := Size + Item.Expanded_Node_Id_Value.Binary_Size;
		 when QUALIFIEDNAME_VARIANT => Size := Size + Item.Qualified_Name_Value.Binary_Size;
		 when LOCALIZEDTEXT_VARIANT => Size := Size + Item.Localized_Text_Value.Binary_Size;
		 when EXTENSIONOBJECT_VARIANT => Size := Size + Item.Extension_Object_Value.Binary_Size;
		 when DATAVALUE_VARIANT => Size := Size + Item.Data_Value_Value.Binary_Size;
		 when VARIANT_VARIANT => Size := Size + Variant(Item.Variant_Value.Get.Data.all).Binary_Size;
		 when DIAGNOSTICINFO_VARIANT => Size := Size + DiagnosticInfo(Item.Diagnostic_Info_Value.Get.Data.all).Binary_Size;
   		 when others =>
   			case Item.Variant_Type is
   			   when BOOLEAN_ARRAY_VARIANT => Size := Size + Item.Boolean_Values.Binary_Size;
   			   when SBYTE_ARRAY_VARIANT => Size := Size + Item.SByte_Values.Binary_Size;
   			   when BYTE_ARRAY_VARIANT => Size := Size + Item.Byte_Values.Binary_Size;
   			   when INT16_ARRAY_VARIANT => Size := Size + Item.Int16_Values.Binary_Size;
   			   when UINT16_ARRAY_VARIANT => Size := Size + Item.UInt16_Values.Binary_Size;
   			   when INT32_ARRAY_VARIANT => Size := Size + Item.Int32_Values.Binary_Size;
   			   when UINT32_ARRAY_VARIANT => Size := Size + Item.UInt32_Values.Binary_Size;
   			   when INT64_ARRAY_VARIANT => Size := Size + Item.Int64_Values.Binary_Size;
   			   when UINT64_ARRAY_VARIANT => Size := Size + Item.UInt64_Values.Binary_Size;
   			   when FLOAT_ARRAY_VARIANT => Size := Size + Item.Float_Values.Binary_Size;
   			   when DOUBLE_ARRAY_VARIANT => Size := Size + Item.Double_Values.Binary_Size;
   			   when STRING_ARRAY_VARIANT => Size := Size + Item.String_Values.Binary_Size;
   			   when DATETIME_ARRAY_VARIANT => Size := Size + Item.Date_Time_Values.Binary_Size;
   			   when GUID_ARRAY_VARIANT => Size := Size + Item.Guid_Values.Binary_Size;
   			   when BYTESTRING_ARRAY_VARIANT => Size := Size + Item.Byte_String_Values.Binary_Size;
   			   when XMLELEMENT_ARRAY_VARIANT => Size := Size + Item.Xml_Element_Values.Binary_Size;
   			   when NODEID_ARRAY_VARIANT => Size := Size + Item.Node_Id_Values.Binary_Size;
   			   when EXPANDEDNODEID_ARRAY_VARIANT => Size := Size + Item.Expanded_Node_Id_Values.Binary_Size;
   			   when STATUSCODE_ARRAY_VARIANT => Size := Size + Item.Status_Code_Values.Binary_Size;
   			   when QUALIFIEDNAME_ARRAY_VARIANT => Size := Size + Item.Qualified_Name_Values.Binary_Size;
   			   when LOCALIZEDTEXT_ARRAY_VARIANT => Size := Size + Item.Localized_Text_Values.Binary_Size;
   			   when EXTENSIONOBJECT_ARRAY_VARIANT => Size := Size + Item.Extension_Object_Values.Binary_Size;
   			   when DATAVALUE_ARRAY_VARIANT => Size := Size + Item.Data_Value_Values.Binary_Size;
   			   when VARIANT_ARRAY_VARIANT => Size := Size + Item.Variant_Values.Binary_Size;
   			   when DIAGNOSTICINFO_ARRAY_VARIANT => Size := Size + Item.Diagnostic_Info_Values.Binary_Size;
			   when others => null;
   			end case;
   			if not Item.Array_Dimensions.Is_Null Then
   			   Size := Size + Item.Array_Dimensions.Binary_Size;
   			end if;
	  end case;
	  return Size;
   end Binary_Size;

end Types.Builtin;
