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
      IdentifierType   : NodeIdType;
      Has_ServerIndex  : Standard.Boolean;
      Has_NamespaceUri : Standard.Boolean;
   end record;
   for NodeId_Identifier use record
      IdentifierType   at 0 range 0 .. 5;
      Has_ServerIndex  at 0 range 6 .. 6;
      Has_NamespaceUri at 0 range 7 .. 7;
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
		 when BYTESTRING_NODEID => return 2 + Binary_Size(Item.ByteString_Identifier);
	  end case;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in NodeId) is
   begin
	  NodeId_Identifier'Write(Stream, (Item.NodeId_Type, False, False));
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
			Binary_Write(Stream, Item.String_Identifier);
		 when GUID_NODEID =>
			UInt16'Write(Stream, Item.Namespace);
			Guid'Write(Stream, Item.Guid_Identifier);
		 when BYTESTRING_NODEID =>
			UInt16'Write(Stream, Item.Namespace);
			Binary_Write(Stream, Item.ByteString_Identifier);
	  end case;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out NodeId) is
      Identifier : constant NodeId_Identifier := NodeId_Identifier'Input(Stream);
   begin
	  case Identifier.IdentifierType is
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
   				  when BYTESTRING_NODEID => return A.ByteString_Identifier = B.ByteString_Identifier;
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
   	  if not Item.NamespaceUri.Is_Null then
   		 Size := Size + Binary_Size(Item.NamespaceUri);
   	  end if;
   	  if not Item.ServerIndex.Is_Null then
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
               when BYTESTRING_NODEID => Size := Size + Binary_Size(Item.ByteString_Identifier);
               when others =>
                  null;
            end case;
   	  end case;
   	  return Size;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in ExpandedNodeId) is
   begin
      NodeId_Identifier'Write(Stream, (Item.NodeId_Type, not Item.ServerIndex.Is_Null, not Item.NamespaceUri.Is_Null));
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
   			Binary_Write(Stream, Item.String_Identifier);
   		 when GUID_NODEID =>
   			UInt16'Write(Stream, Item.Namespace);
   		    Guid'Write(Stream, Item.Guid_Identifier);
   		 when BYTESTRING_NODEID =>
   			UInt16'Write(Stream, Item.Namespace);
   			Binary_Write(Stream, Item.ByteString_Identifier);
      end case;
      if not Item.NamespaceUri.Is_Null then
         Binary_Write(Stream, Item.NamespaceUri);
      end if;
      if not Item.ServerIndex.Is_Null then
         UInt32'Write(Stream, Item.ServerIndex.Get);
      end if;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out ExpandedNodeId) is
      Identifier : constant NodeId_Identifier := NodeId_Identifier'Input(Stream);
      NamespaceUri : String := Create(null);
      ServerIndex : UInt32s.Nullable_Pointer := Uint32s.Null_Pointer;
      Base_Node : NodeId(Identifier.IdentifierType);
   begin
      case Identifier.IdentifierType is
   		 when TWOBYTE_NODEID => Base_Node := (TWOBYTE_NODEID, Byte'Input(Stream));
   		 when FOURBYTE_NODEID => Base_Node := (FOURBYTE_NODEID, Byte'Input(Stream), UInt16'Input(Stream));
   		 when NUMERIC_NODEID => Base_Node := (NUMERIC_NODEID, UInt16'Input(Stream), UInt32'Input(Stream));
   		 when STRING_NODEID => Base_Node := (STRING_NODEID, UInt16'Input(Stream), NotNullString'Input(Stream));
   		 when GUID_NODEID => Base_Node := (GUID_NODEID, UInt16'Input(Stream), Guid'Input(Stream));
   		 when BYTESTRING_NODEID => Base_Node := (BYTESTRING_NODEID, UInt16'Input(Stream), NotNullByteString'Input(Stream));
      end case;
      if Identifier.Has_NamespaceUri then
   		 NamespaceUri := String'Input(Stream);
      end if;
      if Identifier.Has_ServerIndex then
         ServerIndex := UInt32s.Create(new UInt32'(UInt32'Input(Stream)));
      end if;
      case Base_Node.NodeId_Type is
         when TWOBYTE_NODEID => Item := (TWOBYTE_NODEID, Base_Node.Byte_Identifier, NamespaceUri, ServerIndex);
         when FOURBYTE_NODEID => Item := (FOURBYTE_NODEID, Base_Node.Byte_Namespace, Base_Node.UInt16_Identifier, NamespaceUri, ServerIndex);
         when NUMERIC_NODEID => Item := (NUMERIC_NODEID, Base_Node.Namespace, Base_Node.Numeric_Identifier, NamespaceUri, ServerIndex);
         when STRING_NODEID => Item := (STRING_NODEID, Base_Node.Namespace, Base_Node.String_Identifier, NamespaceUri, ServerIndex);
         when GUID_NODEID => Item := (GUID_NODEID, Base_Node.Namespace, Base_Node.Guid_Identifier, NamespaceUri, ServerIndex);
         when BYTESTRING_NODEID => Item := (BYTESTRING_NODEID, Base_Node.Namespace, Base_Node.ByteString_Identifier, NamespaceUri, ServerIndex);
      end case;
   end Binary_Read;
   
   ----------------------
   --  DiagnosticInfo  --
   ----------------------
   type DiagnosticInfo_Encoding is record
      SymbolicId          : Standard.Boolean;
      NamespaceUri        : Standard.Boolean;
      LocalizedText       : Standard.Boolean;
      Locale              : Standard.Boolean;
      AdditionalInfo      : Standard.Boolean;
      InnerStatusCode     : Standard.Boolean;
      InnerDiagnosticInfo : Standard.Boolean;
   end record;
   for DiagnosticInfo_Encoding use record
      SymbolicId          at 0 range 0 .. 0;
      NamespaceUri        at 0 range 1 .. 1;
      LocalizedText       at 0 range 2 .. 2;
      Locale              at 0 range 3 .. 3;
      AdditionalInfo      at 0 range 4 .. 4;
      InnerStatusCode     at 0 range 5 .. 5;
      InnerDiagnosticInfo at 0 range 6 .. 6;
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
   	  if not Item.SymbolicId.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.NamespaceUri.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.LocalizedText.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.Locale.Is_Null then
   	  	 Size := Size + 4;
   	  end if;
   	  if not Item.AdditionalInfo.Is_Null then
   	  	 Size := Size + Binary_Size(Item.AdditionalInfo);
   	  end if;
   	  if not Item.InnerStatusCode.Is_Null then
   	  	 Size := Size + 8;
   	  end if;
   	  if not Item.InnerDiagnostiCinfo.Is_Null then
   	  	 Size := Size + Binary_Size(DiagnosticInfo(Item.InnerDiagnosticInfo.Get.Data.all));
   	  end if;
   	  return Size;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DiagnosticInfo) is
      Encoding : constant DiagnosticInfo_Encoding := (not Item.SymbolicId.Is_Null, not Item.NamespaceUri.Is_Null, not Item.LocalizedText.Is_Null,
                                                      not Item.Locale.Is_Null, not Item.AdditionalInfo.Is_Null, not Item.InnerStatusCode.Is_Null,
                                                      not Item.InnerDiagnosticInfo.Is_Null);
   begin
      DiagnosticInfo_Encoding'Write(Stream, Encoding);
      if not Item.SymbolicId.Is_Null then
         Int32'Write(Stream, Item.SymbolicId.Get);
      end if;
      if not Item.NamespaceUri.Is_Null then
         Int32'Write(Stream, Item.NamespaceUri.Get);
      end if;
      if not Item.LocalizedText.Is_Null then
         Int32'Write(Stream, Item.LocalizedText.Get);
      end if;
      if not Item.Locale.Is_Null then
         Int32'Write(Stream, Item.Locale.Get);
      end if;
      if not Item.AdditionalInfo.Is_Null then
         String'Write(Stream, Item.AdditionalInfo);
      end if;
      if not Item.InnerStatusCode.Is_Null then
         StatusCode'Write(Stream, Item.InnerStatusCode.Get);
      end if;
      if not Item.InnerDiagnosticInfo.Is_Null then
         Binary_Write(Stream, DiagnosticInfo(Item.InnerDiagnosticInfo.Get.Data.all));
      end if;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out DiagnosticInfo) is
      Encoding : constant DiagnosticInfo_Encoding := DiagnosticInfo_Encoding'Input(Stream);
   begin
      if Encoding.SymbolicId then
         Item.SymbolicId := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.SymbolicId := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.NamespaceUri then
         Item.NamespaceUri := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.NamespaceUri := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.LocalizedText then
         Item.LocalizedText := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.LocalizedText := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.Locale then
         Item.Locale := Int32s.Create(new Int32'(Int32'Input(Stream)));
   	  else
   	  	 Item.Locale := Int32s.Null_Pointer;
      end if;
      
   	  if Encoding.AdditionalInfo then
         Item.AdditionalInfo := String'Input(Stream);
   	  else
   	  	 Item.AdditionalInfo := Create(null);
      end if;
      
   	  if Encoding.InnerStatusCode then
         Item.InnerStatusCode := StatusCodes.Create(new StatusCode'(StatusCode'Input(Stream)));
   	  else
   	  	 Item.InnerStatusCode := StatusCodes.Null_Pointer;
      end if;
	  
      if Encoding.InnerDiagnosticInfo then
         Item.InnerDiagnosticInfo := DiagnosticInfos.Create(new DiagnosticInfo'(DiagnosticInfo'Input(Stream)));
   	  else
   	  	 Item.InnerDiagnosticInfo := DiagnosticInfos.Null_Pointer;
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
         Binary_Write(Stream, Item.Locale);
      end if;
      if not Item.Text.Is_Null then
         Binary_Write(Stream, Item.Text);
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
         when BYTESTRING_BODY => Size := Size + Binary_Size(Item.ByteString_Body);
         when XMLELEMENT_BODY => Size := Size + Binary_Size(Item.XmlElement_Body);
      end case;
	  return Size;
   end Binary_Size;
	  
   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in ExtensionObject) is
   begin
      Binary_Write(Stream, Item.TypeId.Get);
      ExtensionObject_Encoding'Write(Stream, Item.Encoding);
      case Item.Encoding is
         when NO_BODY => null;
         when BYTESTRING_BODY => Binary_Write(Stream, Item.ByteString_Body);
         when XMLELEMENT_BODY => Binary_Write(Stream, Item.XmlElement_Body);
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
	  UInt16'Write(Stream, Item.NamespaceIndex);
	  Binary_Write(Stream, Item.Name);
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
      Has_SourceTimestamp   : Standard.Boolean;
      Has_ServerTimestamp   : Standard.Boolean;
      Has_SourcePicoseconds : Standard.Boolean;
      Has_ServerPicoseconds : Standard.Boolean;
   end record;
   for DataValue_Encoding use record
      Has_Value             at 0 range 0 .. 0;
      Has_Status            at 0 range 1 .. 1;
      Has_SourceTimestamp   at 0 range 2 .. 2;
      Has_ServerTimestamp   at 0 range 3 .. 3;
      Has_SourcePicoseconds at 0 range 4 .. 4;
      Has_ServerPicoseconds at 0 range 5 .. 5;
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
	  if not Item.SourceTimestamp.Is_Null then
		 Size := Size + 8;
	  end if;
	  if not Item.SourcePicoseconds.Is_Null then
		 Size := Size + 2;
	  end if;
	  if not Item.ServerTimestamp.Is_Null then
		 Size := Size + 8;
	  end if;
	  if not Item.ServerPicoseconds.Is_Null then
		 Size := Size + 2;
	  end if;
	  return Size;
   end Binary_Size;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DataValue) is
      Encoding : constant DataValue_Encoding := (not Item.Value.Is_Null, not Item.Status.Is_Null, not Item.SourceTimestamp.Is_Null,
                                                 not Item.SourcePicoseconds.Is_Null, not Item.ServerTimestamp.Is_Null,
                                                 not Item.ServerPicoseconds.Is_Null);
   begin
      DataValue_Encoding'Write(Stream, Encoding);
      if not Item.Value.Is_Null then
		 Variant'Write(Stream, Variant(Item.Value.Get.Data.all));
      end if;
      if not Item.Status.Is_Null then
         StatusCode'Write(Stream, Item.Status.Get);
      end if;
      if not Item.SourceTimestamp.Is_Null then
         DateTime'Write(Stream, Item.SourceTimestamp.Get);
      end if;
      if not Item.SourcePicoseconds.Is_Null then
         UInt16'Write(Stream, Item.SourcePicoseconds.Get);
      end if;
      if not Item.ServerTimestamp.Is_Null then
         DateTime'Write(Stream, Item.ServerTimestamp.Get);
      end if;
      if not Item.ServerPicoseconds.Is_Null then
         UInt16'Write(Stream, Item.ServerPicoseconds.Get);
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
      if Encoding.Has_SourceTimestamp then
         Item.SourceTimestamp := DateTimes.Create(new DateTime'(DateTime'Input(Stream)));
      end if;
      if Encoding.Has_SourcePicoseconds then
         Item.SourcePicoseconds := UInt16s.Create(new UInt16'(UInt16'Input(Stream)));
      end if;
      if Encoding.Has_ServerTimestamp then
         Item.ServerTimestamp := DateTimes.Create(new DateTime'(DateTime'Input(Stream)));
      end if;
      if Encoding.Has_ServerPicoseconds then
         Item.ServerPicoseconds := UInt16s.Create(new UInt16'(UInt16'Input(Stream)));
      end if;
   end Binary_Read;

   ---------------
   --  Variant  --
   ---------------
   type Variant_Encoding is record
      Value_Type       : VariantType;
      HasArrayDimensions : Standard.Boolean;
      IsArray            : Standard.Boolean;
   end record;
   for Variant_Encoding use record
      Value_Type          at 0 range 0 .. 5;
      HasArrayDimensions  at 0 range 6 .. 6;
      IsArray             at 0 range 7 .. 7;
   end record;
   for Variant_Encoding'Size use 8;
  
   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Variant_Encoding) is
   	  Overlay : Byte;
   	  for Overlay'Address use Item'Address;
   begin
   	  Byte'Write(Stream, Overlay);
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Variant_Encoding) is
   	  Overlay : Byte;
   	  for Overlay'Address use Item'Address;
   begin
   	  Byte'Read(Stream, Overlay);
   end Binary_Read;

   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Variant) is
      Encoding : constant Variant_Encoding := (Item.Value_Type, Item.Is_Array and then (not Item.ArrayDimensions.Is_Null), Item.Is_Array);
   begin
      Variant_Encoding'Write(Stream, Encoding);
      case Item.Is_Array is
      when False =>
         case Item.Value_Type is
			when BOOLEAN_TYPE => Boolean'Write(Stream, Item.Boolean_Value);
			when SBYTE_TYPE => SByte'Write(Stream, Item.SByte_Value);
			when BYTE_TYPE => Byte'Write(Stream, Item.Byte_Value);
			when INT16_TYPE => Int16'Write(Stream, Item.Int16_Value);
			when UINT16_TYPE => UInt16'Write(Stream, Item.UInt16_Value);
			when INT32_TYPE => Int32'Write(Stream, Item.Int32_Value);
			when UINT32_TYPE => UInt32'Write(Stream, Item.UInt32_Value);
			when INT64_TYPE => Int64'Write(Stream, Item.Int64_Value);
			when UINT64_TYPE => UInt64'Write(Stream, Item.UInt64_Value);
			when FLOAT_TYPE => Float'Write(Stream, Item.Float_Value);
			when DOUBLE_TYPE => Double'Write(Stream,Item.Double_Value);
			when STRING_TYPE => Binary_Write(Stream,Item.String_Value);
			when DATETIME_TYPE => DateTime'Write(Stream,Item.DateTime_Value);
			when GUID_TYPE => Binary_Write(Stream,Item.Guid_Value);
			when BYTESTRING_TYPE => Binary_Write(Stream,Item.ByteString_Value);
			when XMLELEMENT_TYPE => Binary_Write(Stream,Item.XmlElement_Value);
			when NODEID_TYPE => Binary_Write(Stream, Item.NodeId_Value.Get);
			when EXPANDEDNODEID_TYPE => Binary_Write(Stream,Item.ExpandedNodeId_Value.Get);
			when STATUSCODE_TYPE => StatusCode'Write(Stream,Item.StatusCode_Value);
			when QUALIFIEDNAME_TYPE => Binary_Write(Stream,Item.QualifiedName_Value.Get);
			when LOCALIZEDTEXT_TYPE => Binary_Write(Stream,Item.LocalizedText_Value.Get);
			when EXTENSIONOBJECT_TYPE => Binary_Write(Stream,Item.ExtensionObject_Value.Get);
			when DATAVALUE_TYPE => Binary_Write(Stream,Item.DataValue_Value.Get);
			when VARIANT_TYPE => Binary_Write(Stream, Variant(Item.Variant_Value.Get.Data.all));
			when DIAGNOSTICINFO_TYPE => Binary_Write(Stream, DiagnosticInfo(Item.DiagnosticInfo_Value.Get.Data.all));
         end case;
      when True =>
         case Item.Value_Type is
			when BOOLEAN_TYPE => ListOfBoolean.Pointer'Write(Stream, Item.Boolean_Values);
			when SBYTE_TYPE => ListOfSByte.Pointer'Write(Stream, Item.SByte_Values);
			when BYTE_TYPE => ListOfByte.Pointer'Write(Stream, Item.Byte_Values);
			when INT16_TYPE => ListOfInt16.Pointer'Write(Stream, Item.Int16_Values);
			when UINT16_TYPE => ListOfUInt16.Pointer'Write(Stream, Item.UInt16_Values);
			when INT32_TYPE => ListOfInt32.Pointer'Write(Stream, Item.Int32_Values);
			when UINT32_TYPE => ListOfUInt32.Pointer'Write(Stream, Item.UInt32_Values);
			when INT64_TYPE => ListOfInt64.Pointer'Write(Stream, Item.Int64_Values);
			when UINT64_TYPE => ListOfUInt64.Pointer'Write(Stream, Item.UInt64_Values);
			when FLOAT_TYPE => ListOfFloat.Pointer'Write(Stream, Item.Float_Values);
			when DOUBLE_TYPE => ListOfDouble.Pointer'Write(Stream, Item.Double_Values);
			when STRING_TYPE => ListOfString.Pointer'Write(Stream, Item.String_Values);
			when DATETIME_TYPE => ListOfDateTime.Pointer'Write(Stream, Item.DateTime_Values);
			when GUID_TYPE => ListOfGuid.Pointer'Write(Stream, Item.Guid_Values);
			when BYTESTRING_TYPE => ListOfByteString.Pointer'Write(Stream, Item.ByteString_Values);
			when XMLELEMENT_TYPE => ListOfXmlElement.Pointer'Write(Stream, Item.XmlElement_Values);
			when NODEID_TYPE => ListOfNodeId.Pointer'Write(Stream, Item.NodeId_Values);
			when EXPANDEDNODEID_TYPE => ListOfExpandedNodeId.Pointer'Write(Stream, Item.ExpandedNodeId_Values);
			when STATUSCODE_TYPE => ListOfStatusCode.Pointer'Write(Stream, Item.StatusCode_Values);
			when QUALIFIEDNAME_TYPE => ListOfQualifiedName.Pointer'Write(Stream, Item.QualifiedName_Values);
			when LOCALIZEDTEXT_TYPE => ListOfLocalizedText.Pointer'Write(Stream, Item.LocalizedText_Values);
			when EXTENSIONOBJECT_TYPE => ListOfExtensionObject.Pointer'Write(Stream, Item.ExtensionObject_Values);
			when DATAVALUE_TYPE => ListOfDataValue.Pointer'Write(Stream, Item.DataValue_Values);
			when VARIANT_TYPE => ListOfVariant.Pointer'Write(Stream, Item.Variant_Values);
			when DIAGNOSTICINFO_TYPE => ListOfDiagnosticInfo.Pointer'Write(Stream, Item.DiagnosticInfo_Values);
         end case;
         if not Item.ArrayDimensions.Is_Null then
            ListOfInt32.Nullable_Pointer'Write(Stream, Item.ArrayDimensions);
         end if;
      end case;
   end Binary_Write;

   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Variant) is
      Encoding : constant Variant_Encoding := Variant_Encoding'Input(Stream);
   begin
   	  case Encoding.IsArray is
   		 when False =>
   			case Encoding.Value_Type is
   			   when BOOLEAN_TYPE => Item := Variant'(BOOLEAN_TYPE, False, Boolean'Input(Stream));
   			   when SBYTE_TYPE => Item := Variant'(SBYTE_TYPE, False, SByte'Input(Stream));
   			   when BYTE_TYPE => Item := Variant'(BYTE_TYPE, False, Byte'Input(Stream));
   			   when INT16_TYPE => Item := Variant'(INT16_TYPE, False, Int16'Input(Stream));
   			   when UINT16_TYPE => Item := Variant'(UINT16_TYPE, False, UInt16'Input(Stream));
   			   when INT32_TYPE => Item := Variant'(INT32_TYPE, False, Int32'Input(Stream));
   			   when UINT32_TYPE => Item := Variant'(UINT32_TYPE, False, UInt32'Input(Stream));
   			   when INT64_TYPE => Item := Variant'(INT64_TYPE, False, Int64'Input(Stream));
   			   when UINT64_TYPE => Item := Variant'(UINT64_TYPE, False, UInt64'Input(Stream));
   			   when FLOAT_TYPE => Item := Variant'(FLOAT_TYPE, False, Float'Input(Stream));
   			   when DOUBLE_TYPE => Item := Variant'(DOUBLE_TYPE, False, Double'Input(Stream));
   			   when STRING_TYPE => Item := Variant'(STRING_TYPE, False, String'Input(Stream));
   			   when DATETIME_TYPE => Item := Variant'(DATETIME_TYPE, False, DateTime'Input(Stream));
   			   when GUID_TYPE => Item := Variant'(GUID_TYPE, False, Guid'Input(Stream));
   			   when BYTESTRING_TYPE => Item := Variant'(BYTESTRING_TYPE, False, ByteString'Input(Stream));
   			   when XMLELEMENT_TYPE => Item := Variant'(XMLELEMENT_TYPE, False, XmlElement'Input(Stream));
   			   when NODEID_TYPE => Item := Variant'(NODEID_TYPE, False, NodeIds.Create(new NodeId'(NodeId'Input(Stream))));
   			   when EXPANDEDNODEID_TYPE => Item := Variant'(EXPANDEDNODEID_TYPE, False, ExpandedNodeIds.Create(new ExpandedNodeId'(ExpandedNodeId'Input(Stream))));
   			   when STATUSCODE_TYPE => Item := Variant'(STATUSCODE_TYPE, False, StatusCode'Input(Stream));
   			   when QUALIFIEDNAME_TYPE => Item := Variant'(QUALIFIEDNAME_TYPE, False, QualifiedNames.Create(new QualifiedName'(QualifiedName'Input(Stream))));
   			   when LOCALIZEDTEXT_TYPE => Item := Variant'(LOCALIZEDTEXT_TYPE, False, LocalizedTexts.Create(new LocalizedText'(LocalizedText'Input(Stream))));
   			   when EXTENSIONOBJECT_TYPE => Item := Variant'(EXTENSIONOBJECT_TYPE, False, ExtensionObjects.Create(new ExtensionObject'(ExtensionObject'Input(Stream))));
   			   when DATAVALUE_TYPE => Item := Variant'(DATAVALUE_TYPE, False, DataValues.Create(new DataValue'(DataValue'Input(Stream))));
   			   when VARIANT_TYPE => Item := Variant'(VARIANT_TYPE, False, Variants.Create(new Variant'(Variant'Input(Stream))));
   			   when DIAGNOSTICINFO_TYPE => Item := Variant'(DIAGNOSTICINFO_TYPE, False, DiagnosticInfos.Create(new DiagnosticInfo'(DiagnosticInfo'Input(Stream))));
   			end case;
   		 when True =>
			declare
			   Empty_Dimensions : constant ListOfInt32.Nullable_Pointer := ListOfInt32.Create(null);
			begin
   			case Encoding.Value_Type is
   			   when BOOLEAN_TYPE => Item := Variant'(BOOLEAN_TYPE, True, Empty_Dimensions, ListOfBoolean.Pointer'Input(Stream));
   			   when SBYTE_TYPE => Item := Variant'(SBYTE_TYPE, True, Empty_Dimensions, ListOfSByte.Pointer'Input(Stream));
   			   when BYTE_TYPE => Item := Variant'(BYTE_TYPE, True, Empty_Dimensions, ListOfByte.Pointer'Input(Stream));
   			   when INT16_TYPE => Item := Variant'(INT16_TYPE, True, Empty_Dimensions, ListOfInt16.Pointer'Input(Stream));
   			   when UINT16_TYPE => Item := Variant'(UINT16_TYPE, True, Empty_Dimensions, ListOfUInt16.Pointer'Input(Stream));
   			   when INT32_TYPE => Item := Variant'(INT32_TYPE, True, Empty_Dimensions, ListOfInt32.Pointer'Input(Stream));
   			   when UINT32_TYPE => Item := Variant'(UINT32_TYPE, True, Empty_Dimensions, ListOfUInt32.Pointer'Input(Stream));
   			   when INT64_TYPE => Item := Variant'(INT64_TYPE, True, Empty_Dimensions, ListOfInt64.Pointer'Input(Stream));
   			   when UINT64_TYPE => Item := Variant'(UINT64_TYPE, True, Empty_Dimensions, ListOfUInt64.Pointer'Input(Stream));
   			   when FLOAT_TYPE => Item := Variant'(FLOAT_TYPE, True, Empty_Dimensions, ListOfFloat.Pointer'Input(Stream));
   			   when DOUBLE_TYPE => Item := Variant'(DOUBLE_TYPE, True, Empty_Dimensions, ListOfDouble.Pointer'Input(Stream));
   			   when STRING_TYPE => Item := Variant'(STRING_TYPE, True, Empty_Dimensions, ListOfString.Pointer'Input(Stream));
   			   when DATETIME_TYPE => Item := Variant'(DATETIME_TYPE, True, Empty_Dimensions, ListOfDateTime.Pointer'Input(Stream));
   			   when GUID_TYPE => Item := Variant'(GUID_TYPE, True, Empty_Dimensions, ListOfGuid.Pointer'Input(Stream));
   			   when BYTESTRING_TYPE => Item := Variant'(BYTESTRING_TYPE, True, Empty_Dimensions, ListOfByteString.Pointer'Input(Stream));
   			   when XMLELEMENT_TYPE => Item := Variant'(XMLELEMENT_TYPE, True, Empty_Dimensions, ListOfXmlElement.Pointer'Input(Stream));
   			   when NODEID_TYPE => Item := Variant'(NODEID_TYPE, True, Empty_Dimensions, ListOfNodeId.Pointer'Input(Stream));
   			   when EXPANDEDNODEID_TYPE => Item := Variant'(EXPANDEDNODEID_TYPE, True, Empty_Dimensions, ListOfExpandedNodeId.Pointer'Input(Stream));
   			   when STATUSCODE_TYPE => Item := Variant'(STATUSCODE_TYPE, True, Empty_Dimensions, ListOfStatusCode.Pointer'Input(Stream));
   			   when QUALIFIEDNAME_TYPE => Item := Variant'(QUALIFIEDNAME_TYPE, True, Empty_Dimensions, ListOfQualifiedName.Pointer'Input(Stream));
   			   when LOCALIZEDTEXT_TYPE => Item := Variant'(LOCALIZEDTEXT_TYPE, True, Empty_Dimensions, ListOfLocalizedText.Pointer'Input(Stream));
   			   when EXTENSIONOBJECT_TYPE => Item := Variant'(EXTENSIONOBJECT_TYPE, True, Empty_Dimensions, ListOfExtensionObject.Pointer'Input(Stream));
   			   when DATAVALUE_TYPE => Item := Variant'(DATAVALUE_TYPE, True, Empty_Dimensions, ListOfDataValue.Pointer'Input(Stream));
   			   when VARIANT_TYPE => Item := Variant'(VARIANT_TYPE, True, Empty_Dimensions, ListOfVariant.Pointer'Input(Stream));
   			   when DIAGNOSTICINFO_TYPE => Item := Variant'(DIAGNOSTICINFO_TYPE, True, Empty_Dimensions, ListOfDiagnosticInfo.Pointer'Input(Stream));
   			end case;
			null;
   			if Encoding.HasArrayDimensions then
   			   Item.ArrayDimensions := ListOfInt32.Nullable_Pointer'(ListOfInt32.Nullable_Pointer'Input(Stream));
   			end if;
			end;
   	  end case;
   end Binary_Read;

   function Binary_Size(Item : in Variant) return Int32 is
	  Size : Int32 := 1; -- with encoding
   begin
   	  case Item.Is_Array is
   		 when False =>
   			case Item.Value_Type is
   			   when BOOLEAN_TYPE | SBYTE_TYPE | BYTE_TYPE => Size := Size + 1;
   			   when INT16_TYPE | UINT16_TYPE => Size := Size + 2;
   			   when INT32_TYPE | UINT32_TYPE | FLOAT_TYPE | STATUSCODE_TYPE => Size := Size + 4;
   			   when INT64_TYPE | UINT64_TYPE | DOUBLE_TYPE | DATETIME_TYPE => Size := Size + 8;
   			   when STRING_TYPE => Size := Size + Binary_Size(Item.String_Value);
   			   when GUID_TYPE => Size := Size + Binary_Size(Item.Guid_Value);
   			   when BYTESTRING_TYPE => Size := Size + Binary_Size(Item.ByteString_Value);
   			   when XMLELEMENT_TYPE => Size := Size + Binary_Size(Item.XmlElement_Value);
   			   when NODEID_TYPE => Size := Size + Item.NodeId_Value.Binary_Size;
   			   when EXPANDEDNODEID_TYPE => Size := Size + Item.ExpandedNodeId_Value.Binary_Size;
   			   when QUALIFIEDNAME_TYPE => Size := Size + Item.QualifiedName_Value.Binary_Size;
   			   when LOCALIZEDTEXT_TYPE => Size := Size + Item.LocalizedText_Value.Binary_Size;
   			   when EXTENSIONOBJECT_TYPE => Size := Size + Item.ExtensionObject_Value.Binary_Size;
   			   when DATAVALUE_TYPE => Size := Size + Item.DataValue_Value.Binary_Size;
   			   when VARIANT_TYPE => Size := Size + Variant(Item.Variant_Value.Get.Data.all).Binary_Size;
   			   when DIAGNOSTICINFO_TYPE => Size := Size + DiagnosticInfo(Item.DiagnosticInfo_Value.Get.Data.all).Binary_Size;
   			end case;
   		 when True =>
   			case Item.Value_Type is
   			   when BOOLEAN_TYPE => Size := Size + Item.Boolean_Values.Binary_Size;
   			   when SBYTE_TYPE => Size := Size + Item.SByte_Values.Binary_Size;
   			   when BYTE_TYPE => Size := Size + Item.Byte_Values.Binary_Size;
   			   when INT16_TYPE => Size := Size + Item.Int16_Values.Binary_Size;
   			   when UINT16_TYPE => Size := Size + Item.UInt16_Values.Binary_Size;
   			   when INT32_TYPE => Size := Size + Item.Int32_Values.Binary_Size;
   			   when UINT32_TYPE => Size := Size + Item.UInt32_Values.Binary_Size;
   			   when INT64_TYPE => Size := Size + Item.Int64_Values.Binary_Size;
   			   when UINT64_TYPE => Size := Size + Item.UInt64_Values.Binary_Size;
   			   when FLOAT_TYPE => Size := Size + Item.Float_Values.Binary_Size;
   			   when DOUBLE_TYPE => Size := Size + Item.Double_Values.Binary_Size;
   			   when STRING_TYPE => Size := Size + Item.String_Values.Binary_Size;
   			   when DATETIME_TYPE => Size := Size + Item.DateTime_Values.Binary_Size;
   			   when GUID_TYPE => Size := Size + Item.Guid_Values.Binary_Size;
   			   when BYTESTRING_TYPE => Size := Size + Item.ByteString_Values.Binary_Size;
   			   when XMLELEMENT_TYPE => Size := Size + Item.XmlElement_Values.Binary_Size;
   			   when NODEID_TYPE => Size := Size + Item.NodeId_Values.Binary_Size;
   			   when EXPANDEDNODEID_TYPE => Size := Size + Item.ExpandedNodeId_Values.Binary_Size;
   			   when STATUSCODE_TYPE => Size := Size + Item.StatusCode_Values.Binary_Size;
   			   when QUALIFIEDNAME_TYPE => Size := Size + Item.QualifiedName_Values.Binary_Size;
   			   when LOCALIZEDTEXT_TYPE => Size := Size + Item.LocalizedText_Values.Binary_Size;
   			   when EXTENSIONOBJECT_TYPE => Size := Size + Item.ExtensionObject_Values.Binary_Size;
   			   when DATAVALUE_TYPE => Size := Size + Item.DataValue_Values.Binary_Size;
   			   when VARIANT_TYPE => Size := Size + Item.Variant_Values.Binary_Size;
   			   when DIAGNOSTICINFO_TYPE => Size := Size + Item.DiagnosticInfo_Values.Binary_Size;
   			end case;
   			if not Item.ArrayDimensions.Is_Null Then
   			   Size := Size + Item.ArrayDimensions.Binary_Size;
   			end if;
   	  end case;
	  return Size;
   end Binary_Size;

end Types.Builtin;
