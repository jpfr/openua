with Types.Smart_Pointers;
with Types.Arrays;
with Ada.Streams;
with Types.StandardNodeIds;

package Types.Builtin with Preelaborate is
   package C renames Interfaces.C;
   package SP renames Types.Smart_Pointers;
   package SID renames Types.StandardNodeIds;

   package Bytes is new Types.Arrays.Elementary_Arrays(C.char);
   use Bytes;

   -- Basetypes
   type Boolean is new Standard.Boolean;
   type SByte is new C.char;
   type Byte is new C.unsigned_Char;
   type Int16 is new C.short;
   -- type UInt16 is new C.unsigned_short;
   -- type Int32 is new C.int;
   type UInt32 is new C.unsigned;
   type Int64 is new C.long;
   type UInt64 is new C.unsigned_long;
   type Float is new C.C_float;
   type Double is new C.double;
   type String is new Bytes.Nullable_Pointer and UA_Builtin with null record;
   type DateTime is new C.long;
   type Guid;
   type ByteString is new Bytes.Nullable_Pointer and UA_Builtin with null record;
   type XmlElement is new Bytes.Nullable_Pointer and UA_Builtin with null record;
   type NodeId;
   type ExpandedNodeId;
   type StatusCode is new C.unsigned;
   type QualifiedName;
   type LocalizedText;
   type ExtensionObject;
   type DataValue;
  -- type Variant;
   type DiagnosticInfo;

   -- Extra treatment for string
   type NotNullString is new Bytes.Pointer and UA_Builtin with null record;
   type NotNullByteString is new Bytes.Pointer and UA_Builtin with null record;
   type NotNullXmlElement is new Bytes.Pointer and UA_Builtin with null record;
   function NodeId_Nr(Item : in String) return UInt16 is (SID.String_Id);
   function NodeId_Nr(Item : in NotNullString) return UInt16 is (SID.String_Id);
   function NodeId_Nr(Item : in ByteString) return UInt16 is (SID.ByteString_Id);
   function NodeId_Nr(Item : in NotNullByteString) return UInt16 is (SID.ByteString_Id);
   function NodeId_Nr(Item : in XmlElement) return UInt16 is (SID.XmlElement_Id);
   function NodeId_Nr(Item : in NotNullXmlElement) return UInt16 is (SID.XmlElement_Id);
   
   -- Elementary_Smart_Pointer Types
   package Booleans is new SP.Elementary_Smart_Pointers(Boolean);
   package SBytes is new SP.Elementary_Smart_Pointers(SByte);
   --package Bytes is new SP.Elementary_Smart_Pointers(Byte);
   package Int16s is new SP.Elementary_Smart_Pointers(Int16);
   package UInt16s is new SP.Elementary_Smart_Pointers(UInt16);
   package Int32s is new SP.Elementary_Smart_Pointers(Int32);
   package UInt32s is new SP.Elementary_Smart_Pointers(UInt32);
   package Int64s is new SP.Elementary_Smart_Pointers(Int64);
   package UInt64s is new SP.Elementary_Smart_Pointers(UInt64);
   package Floats is new SP.Elementary_Smart_Pointers(Float);
   package Doubles is new SP.Elementary_Smart_Pointers(Double);
   package DateTimes is new SP.Elementary_Smart_Pointers(DateTime);
   package StatusCodes is new SP.Elementary_Smart_Pointers(StatusCode);

   ------------
   --  Guid  --
   ------------
   type EightBytes is array (0 .. 7) of Byte;
   type Guid is new UA_Builtin with record
   	 Data1 : Int32;
   	 Data2 : Int16;
   	 Data3 : Int16;
   	 Data4 : EightBytes;
   end record;
   function NodeId_Nr(Item : in Guid) return UInt16 is (SID.Guid_Id);
   function Binary_Size(Item : Guid) return Int32 is (16);
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Guid);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Guid);
   for Guid'Write use Binary_Write;
   for Guid'Read use Binary_Read;

   --------------
   --  NodeId  --
   --------------
   type NodeIdType is (TWOBYTE_NODEID, FOURBYTE_NODEID, NUMERIC_NODEID, STRING_NODEID, GUID_NODEID, BYTESTRING_NODEID);
   for NodeIdType'Size use 6;
   for NodeIdType use (TWOBYTE_NODEID => 0, FOURBYTE_NODEID => 1, NUMERIC_NODEID => 2, STRING_NODEID => 3, GUID_NODEID => 4, BYTESTRING_NODEID => 5);

   type NodeId (NodeId_Type : NodeIdType) is new UA_Builtin with record
      case NodeId_Type is
         when TWOBYTE_NODEID =>
            Byte_Identifier : Byte;
         when FOURBYTE_NODEID =>
            Byte_Namespace    : Byte;
            UInt16_Identifier : UInt16;
         when others =>
            Namespace : UInt16;
            case NodeId_Type is
               when NUMERIC_NODEID =>
                  Numeric_Identifier : UInt32;
               when STRING_NODEID =>
                  String_Identifier : NotNullString;
               when GUID_NODEID =>
                  Guid_Identifier : Guid;
               when BYTESTRING_NODEID =>
                  ByteString_Identifier : NotNullByteString;
               when others =>
                  null;
            end case;
      end case;
   end record;

   function NodeId_Nr(Item : in NodeId) return UInt16 is (SID.NodeId_Id);
   function Binary_Size(Item : in NodeId) return Int32;
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in NodeId);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out NodeId);
   for NodeId'Write use Binary_Write;
   for NodeId'Read use Binary_Read;
   
   function Equal(A : NodeId; B : NodeId) return Standard.Boolean;
   package NodeIds is new SP.UA_Builtin_Smart_Pointers(NodeId);
   
   ----------------------
   --  ExpandedNodeId  --
   ----------------------
   type ExpandedNodeId is new NodeId with record
      NamespaceUri : String; -- String is a Nullable_Pointer
      ServerIndex  : UInt32s.Nullable_Pointer;
   end record;
   
   function Binary_Size(Item : in ExpandedNodeId) return Int32;
   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in ExpandedNodeId);
   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out ExpandedNodeId);
   for ExpandedNodeId'Write use Binary_Write;
   for ExpandedNodeId'Read use Binary_Read;
   function NodeId_Nr(Item : in ExpandedNodeId) return UInt16 is (SID.ExpandedNodeId_Id);
   package ExpandedNodeIds is new SP.UA_Builtin_Smart_Pointers(ExpandedNodeId);

   ----------------------
   --  DiagnosticInfo  --
   ----------------------
   type DiagnosticInfo_Base is abstract new UA_Builtin with null record;
   package DiagnosticInfos is new SP.UA_Builtin_Smart_Pointers(DiagnosticInfo_Base'Class);
   
   type DiagnosticInfo is new DiagnosticInfo_Base with record
      SymbolicId          : Int32s.Nullable_Pointer;
      NamespaceUri        : Int32s.Nullable_Pointer;
      LocalizedText       : Int32s.Nullable_Pointer;
      Locale              : Int32s.Nullable_Pointer;
      AdditionalInfo      : String; -- String is a Nullable_Pointer
	  InnerStatusCode     : StatusCodes.Nullable_Pointer;
      InnerDiagnosticInfo : DiagnosticInfos.Nullable_Pointer;
   end record;
   function Binary_Size(Item : in DiagnosticInfo) return Int32;
   procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DiagnosticInfo);
   procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out DiagnosticInfo);
   for DiagnosticInfo'Write use Binary_Write;
   for DiagnosticInfo'Read use Binary_Read;
   function NodeId_Nr(Item : in DiagnosticInfo) return UInt16 is (SID.DiagnosticInfo_Id);

   ---------------------
   --  QualifiedName  --
   ---------------------
   type QualifiedName is new UA_Builtin with record
      NamespaceIndex : UInt16;
      Name           : NotNullString;
   end record;
   
   function NodeId_Nr(Item : in QualifiedName) return UInt16 is (SID.QualifiedName_Id);
   function Binary_Size(Item : in QualifiedName) return Int32;
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in QualifiedName);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out QualifiedName);
   for QualifiedName'Write use Binary_Write;
   for QualifiedName'Read use Binary_Read;
   package QualifiedNames is new SP.UA_Builtin_Smart_Pointers(QualifiedName);

   ---------------------
   --  LocalizedText  --
   ---------------------
   type LocalizedText is new UA_Builtin with record
      Locale : String;
      Text   : String;
   end record;

   function NodeId_Nr(Item : in LocalizedText) return UInt16 is (SID.LocalizedText_Id);
   function Binary_Size(Item : LocalizedText) return Int32;
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in LocalizedText);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out LocalizedText);
   for LocalizedText'Write use Binary_Write;
   for LocalizedText'Read use Binary_Read;
   package LocalizedTexts is new SP.UA_Builtin_Smart_Pointers(LocalizedText);

   -----------------------
   --  ExtensionObject  --
   -----------------------
   type ExtensionObject_Encoding is (NO_BODY, BYTESTRING_BODY, XMLELEMENT_BODY);
   for ExtensionObject_Encoding'Size use 8;
   for ExtensionObject_Encoding use (NO_BODY => 0, BYTESTRING_BODY => 1, XMLELEMENT_BODY => 2);

   type ExtensionObject (Encoding : ExtensionObject_Encoding) is new UA_Builtin with record
   	 TypeId : ExpandedNodeIds.Pointer;
   	 case Encoding is
   		when NO_BODY =>
   		   null;
   		when BYTESTRING_BODY =>
   		   ByteString_Body : NotNullByteString;
   		when XMLELEMENT_BODY =>
   		   XmlElement_Body : NotNullXmlElement;
   	 end case;
   end record;

   function NodeId_Nr(Item : in ExtensionObject) return UInt16 is (SID.Undefined); -- Has no Id?????
   function Binary_Size(Item : ExtensionObject) return Int32;
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in ExtensionObject);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out ExtensionObject);
   for ExtensionObject'Write use Binary_Write;
   for ExtensionObject'Read use Binary_Read;
   package ExtensionObjects is new SP.UA_Builtin_Smart_Pointers(ExtensionObject);
   
   ---------------------------------------
   --  Variant_Base !! Internal only !! --
   ---------------------------------------
   type Variant_Base is abstract new UA_Builtin with null record;
   package Variants is new SP.UA_Builtin_Smart_Pointers(Variant_Base'Class);

   -----------------
   --  DataValue  --
   -----------------
   type DataValue is new UA_Builtin with record
      Value             : Variants.Nullable_Pointer;
      Status            : StatusCodes.Nullable_Pointer;
      SourceTimestamp   : DateTimes.Nullable_Pointer;
      SourcePicoseconds : UInt16s.Nullable_Pointer;
      ServerTimestamp   : DateTimes.Nullable_Pointer;
      ServerPicoseconds : UInt16s.Nullable_Pointer;
   end record;
   
   function NodeId_Nr(Item : in DataValue) return UInt16 is (SID.DataValue_Id);
   function Binary_Size(Item : DataValue) return Int32;
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in DataValue);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out DataValue);
   for DataValue'Write use Binary_Write;
   for DataValue'Read use Binary_Read;
   package DataValues is new SP.UA_Builtin_Smart_Pointers(DataValue);

   -------------------
   --  Array Types  --
   -------------------
   package ListOfBoolean is new Types.Arrays.Elementary_Arrays(Boolean);
   package ListOfSByte is new Types.Arrays.Elementary_Arrays(SByte);
   package ListOfByte is new Types.Arrays.Elementary_Arrays(Byte);
   package ListOfInt16 is new Types.Arrays.Elementary_Arrays(Int16);
   package ListOfUInt16 is new Types.Arrays.Elementary_Arrays(UInt16);
   package ListOfInt32 is new Types.Arrays.Elementary_Arrays(Int32);
   package ListOfUInt32 is new Types.Arrays.Elementary_Arrays(UInt32);
   package ListOfInt64 is new Types.Arrays.Elementary_Arrays(Int64);
   package ListOfUInt64 is new Types.Arrays.Elementary_Arrays(UInt64);
   package ListOfFloat is new Types.Arrays.Elementary_Arrays(Float);
   package ListOfDouble is new Types.Arrays.Elementary_Arrays(Double);
   package ListOfString is new Types.Arrays.UA_Builtin_Arrays(String);
   package ListOfDateTime is new Types.Arrays.Elementary_Arrays(DateTime);
   package ListOfGuid is new Types.Arrays.UA_Builtin_Arrays(Guid);
   package ListOfByteString is new Types.Arrays.UA_Builtin_Arrays(ByteString);
   package ListOfXmlElement is new Types.Arrays.UA_Builtin_Arrays(XmlElement);
   package ListOfNodeId is new Types.Arrays.UA_Builtin_Arrays(NodeId);
   package ListOfExpandedNodeId is new Types.Arrays.UA_Builtin_Arrays(ExpandedNodeId);
   package ListOfStatusCode is new Types.Arrays.Elementary_Arrays(StatusCode);
   package ListOfQualifiedName is new Types.Arrays.UA_Builtin_Arrays(QualifiedName);
   package ListOfLocalizedText is new Types.Arrays.UA_Builtin_Arrays(LocalizedText);
   package ListOfExtensionObject is new Types.Arrays.UA_Builtin_Arrays(ExtensionObject);
   package ListOfDataValue is new Types.Arrays.UA_Builtin_Arrays(DataValue);
   package ListOfVariant is new Types.Arrays.Elementary_Arrays(Variants.Pointer);
   package ListOfDiagnosticInfo is new Types.Arrays.UA_Builtin_Arrays(DiagnosticInfo);

   ---------------
   --  Variant  --
   ---------------
   type VariantType is (BOOLEAN_VARIANT, SBYTE_VARIANT, BYTE_VARIANT, INT16_VARIANT, UINT16_VARIANT, INT32_VARIANT,
						UINT32_VARIANT, INT64_VARIANT, UINT64_VARIANT, FLOAT_VARIANT, DOUBLE_VARIANT, STRING_VARIANT,
						DATETIME_VARIANT, GUID_VARIANT, BYTESTRING_VARIANT, XMLELEMENT_VARIANT, NODEID_VARIANT,
						EXPANDEDNODEID_VARIANT, STATUSCODE_VARIANT, QUALIFIEDNAME_VARIANT, LOCALIZEDTEXT_VARIANT,
						EXTENSIONOBJECT_VARIANT, DATAVALUE_VARIANT, VARIANT_VARIANT, DIAGNOSTICINFO_VARIANT,
						BOOLEAN_ARRAY_VARIANT, SBYTE_ARRAY_VARIANT, BYTE_ARRAY_VARIANT, INT16_ARRAY_VARIANT,
						UINT16_ARRAY_VARIANT, INT32_ARRAY_VARIANT, UINT32_ARRAY_VARIANT, INT64_ARRAY_VARIANT,
						UINT64_ARRAY_VARIANT, FLOAT_ARRAY_VARIANT, DOUBLE_ARRAY_VARIANT, STRING_ARRAY_VARIANT,
						DATETIME_ARRAY_VARIANT, GUID_ARRAY_VARIANT, BYTESTRING_ARRAY_VARIANT, XMLELEMENT_ARRAY_VARIANT,
						NODEID_ARRAY_VARIANT, EXPANDEDNODEID_ARRAY_VARIANT, STATUSCODE_ARRAY_VARIANT, QUALIFIEDNAME_ARRAY_VARIANT,
						LOCALIZEDTEXT_ARRAY_VARIANT, EXTENSIONOBJECT_ARRAY_VARIANT, DATAVALUE_ARRAY_VARIANT, VARIANT_ARRAY_VARIANT,
						DIAGNOSTICINFO_ARRAY_VARIANT);
   for VariantType'Size use 8; -- for conversion to Byte
   for VariantType use
     (BOOLEAN_VARIANT => 1, SBYTE_VARIANT => 2, BYTE_VARIANT => 3, INT16_VARIANT => 4,
      UINT16_VARIANT => 5, INT32_VARIANT => 6, UINT32_VARIANT => 7, INT64_VARIANT => 8,
      UINT64_VARIANT => 9, FLOAT_VARIANT => 10, DOUBLE_VARIANT => 11, STRING_VARIANT => 12,
      DATETIME_VARIANT => 13, GUID_VARIANT => 14, BYTESTRING_VARIANT => 15, XMLELEMENT_VARIANT => 16,
      NODEID_VARIANT => 17, EXPANDEDNODEID_VARIANT => 18, STATUSCODE_VARIANT => 19, QUALIFIEDNAME_VARIANT => 20,
      LOCALIZEDTEXT_VARIANT => 21, EXTENSIONOBJECT_VARIANT => 22, DATAVALUE_VARIANT => 23, VARIANT_VARIANT => 24,
      DIAGNOSTICINFO_VARIANT => 25,
     BOOLEAN_ARRAY_VARIANT => 129, SBYTE_ARRAY_VARIANT => 130, BYTE_ARRAY_VARIANT => 131, INT16_ARRAY_VARIANT => 132,
      UINT16_ARRAY_VARIANT => 133, INT32_ARRAY_VARIANT => 134, UINT32_ARRAY_VARIANT => 135, INT64_ARRAY_VARIANT => 136,
      UINT64_ARRAY_VARIANT => 137, FLOAT_ARRAY_VARIANT => 138, DOUBLE_ARRAY_VARIANT => 139, STRING_ARRAY_VARIANT => 140,
      DATETIME_ARRAY_VARIANT => 141, GUID_ARRAY_VARIANT => 142, BYTESTRING_ARRAY_VARIANT => 143, XMLELEMENT_ARRAY_VARIANT => 144,
      NODEID_ARRAY_VARIANT => 145, EXPANDEDNODEID_ARRAY_VARIANT => 146, STATUSCODE_ARRAY_VARIANT => 147, QUALIFIEDNAME_ARRAY_VARIANT => 148,
      LOCALIZEDTEXT_ARRAY_VARIANT => 149, EXTENSIONOBJECT_ARRAY_VARIANT => 150, DATAVALUE_ARRAY_VARIANT => 151, VARIANT_ARRAY_VARIANT => 152,
      DIAGNOSTICINFO_ARRAY_VARIANT => 153);

   type Variant (Variant_Type : VariantType) is new Variant_Base and UA_Builtin with record
	  case Variant_Type is
		 when BOOLEAN_VARIANT => Boolean_Value : Boolean;
		 when SBYTE_VARIANT => SByte_Value : SByte;
		 when BYTE_VARIANT => Byte_Value : Byte;
		 when INT16_VARIANT => Int16_Value : Int16;
		 when UINT16_VARIANT => UInt16_Value : UInt16;
		 when INT32_VARIANT => Int32_Value : Int32;
		 when UINT32_VARIANT => UInt32_Value : UInt32;
		 when INT64_VARIANT => Int64_Value : Int64;
		 when UINT64_VARIANT => UInt64_Value : UInt64;
		 when FLOAT_VARIANT => Float_Value : Float;
		 when DOUBLE_VARIANT => Double_Value : Double;
		 when STRING_VARIANT => String_Value : String;
		 when DATETIME_VARIANT => DateTime_Value : DateTime;
		 when GUID_VARIANT => Guid_Value : Guid;
		 when BYTESTRING_VARIANT => ByteString_Value : ByteString;
		 when XMLELEMENT_VARIANT => XmlElement_Value : XmlElement;
		 when NODEID_VARIANT => NodeId_Value : NodeIds.Pointer;
		 when EXPANDEDNODEID_VARIANT => ExpandedNodeId_Value : ExpandedNodeIds.Pointer;
		 when STATUSCODE_VARIANT => StatusCode_Value : StatusCode;
		 when QUALIFIEDNAME_VARIANT => QualifiedName_Value : QualifiedNames.Pointer;
		 when LOCALIZEDTEXT_VARIANT => LocalizedText_Value : LocalizedTexts.Pointer;
		 when EXTENSIONOBJECT_VARIANT => ExtensionObject_Value : ExtensionObjects.Pointer;
		 when DATAVALUE_VARIANT => DataValue_Value : DataValues.Pointer;
		 when VARIANT_VARIANT => Variant_Value : Variants.Pointer;
		 when DIAGNOSTICINFO_VARIANT => DiagnosticInfo_Value : DiagnosticInfos.Pointer;
		 when others =>
			ArrayDimensions : ListOfInt32.Nullable_Pointer;
			case Variant_Type is
			   when BOOLEAN_ARRAY_VARIANT => Boolean_Values : ListOfBoolean.Pointer;
			   when SBYTE_ARRAY_VARIANT => SByte_Values : ListOfSByte.Pointer;
			   when BYTE_ARRAY_VARIANT => Byte_Values : ListOfByte.Pointer;
			   when INT16_ARRAY_VARIANT => Int16_Values : ListOfInt16.Pointer;
			   when UINT16_ARRAY_VARIANT => UInt16_Values : ListOfUInt16.Pointer;
			   when INT32_ARRAY_VARIANT => Int32_Values : ListOfInt32.Pointer;
			   when UINT32_ARRAY_VARIANT => UInt32_Values : ListOfUInt32.Pointer;
			   when INT64_ARRAY_VARIANT => Int64_Values : ListOfInt64.Pointer;
			   when UINT64_ARRAY_VARIANT => UInt64_Values : ListOfUInt64.Pointer;
			   when FLOAT_ARRAY_VARIANT => Float_Values : ListOfFloat.Pointer;
			   when DOUBLE_ARRAY_VARIANT => Double_Values : ListOfDouble.Pointer;
			   when STRING_ARRAY_VARIANT => String_Values : ListOfString.Pointer;
			   when DATETIME_ARRAY_VARIANT => DateTime_Values : ListOfDateTime.Pointer;
			   when GUID_ARRAY_VARIANT => Guid_Values : ListOfGuid.Pointer;
			   when BYTESTRING_ARRAY_VARIANT => ByteString_Values : ListOfByteString.Pointer;
			   when XMLELEMENT_ARRAY_VARIANT => XmlElement_Values : ListOfXmlElement.Pointer;
			   when NODEID_ARRAY_VARIANT => NodeId_Values : ListOfNodeId.Pointer;
			   when EXPANDEDNODEID_ARRAY_VARIANT => ExpandedNodeId_Values : ListOfExpandedNodeId.Pointer;
			   when STATUSCODE_ARRAY_VARIANT => StatusCode_Values : ListOfStatusCode.Pointer;
			   when QUALIFIEDNAME_ARRAY_VARIANT => QualifiedName_Values : ListOfQualifiedName.Pointer;
			   when LOCALIZEDTEXT_ARRAY_VARIANT => LocalizedText_Values : ListOfLocalizedText.Pointer;
			   when EXTENSIONOBJECT_ARRAY_VARIANT => ExtensionObject_Values : ListOfExtensionObject.Pointer;
			   when DATAVALUE_ARRAY_VARIANT => DataValue_Values : ListOfDataValue.Pointer;
			   when VARIANT_ARRAY_VARIANT => Variant_Values : ListOfVariant.Pointer;
			   when DIAGNOSTICINFO_ARRAY_VARIANT => DiagnosticInfo_Values : ListOfDiagnosticInfo.Pointer;
			   when others => null;
			end case;
	  end case;
   end record;

   function NodeId_Nr(Item : in Variant) return UInt16 is (SID.Undefined);
   function Binary_Size(Item : Variant) return Int32;
   procedure Binary_Write (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Variant);
   procedure Binary_Read (Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Variant);
   for Variant'Write use Binary_Write;
   for Variant'Read use Binary_Read;

end Types.Builtin;
