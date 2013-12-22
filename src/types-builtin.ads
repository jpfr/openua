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
   type VariantType is (BOOLEAN_TYPE, SBYTE_TYPE, BYTE_TYPE, INT16_TYPE, UINT16_TYPE, INT32_TYPE,
						UINT32_TYPE, INT64_TYPE, UINT64_TYPE, FLOAT_TYPE, DOUBLE_TYPE, STRING_TYPE,
						DATETIME_TYPE, GUID_TYPE, BYTESTRING_TYPE, XMLELEMENT_TYPE, NODEID_TYPE,
						EXPANDEDNODEID_TYPE, STATUSCODE_TYPE, QUALIFIEDNAME_TYPE, LOCALIZEDTEXT_TYPE,
						EXTENSIONOBJECT_TYPE, DATAVALUE_TYPE, VARIANT_TYPE, DIAGNOSTICINFO_TYPE);
   for VariantType'Size use 6;
   for VariantType use
     (BOOLEAN_TYPE => 1, SBYTE_TYPE => 2, BYTE_TYPE => 3, INT16_TYPE => 4,
      UINT16_TYPE => 5, INT32_TYPE => 6, UINT32_TYPE => 7, INT64_TYPE => 8,
      UINT64_TYPE => 9, FLOAT_TYPE => 10, DOUBLE_TYPE => 11, STRING_TYPE => 12,
      DATETIME_TYPE => 13, GUID_TYPE => 14, BYTESTRING_TYPE => 15, XMLELEMENT_TYPE => 16,
      NODEID_TYPE => 17, EXPANDEDNODEID_TYPE => 18, STATUSCODE_TYPE => 19, QUALIFIEDNAME_TYPE => 20,
      LOCALIZEDTEXT_TYPE => 21, EXTENSIONOBJECT_TYPE => 22, DATAVALUE_TYPE => 23, VARIANT_TYPE => 24,
      DIAGNOSTICINFO_TYPE => 25);

   type Variant (Value_Type : VariantType; Is_Array : Standard.Boolean) is new Variant_Base and UA_Builtin with record
   	 case Is_Array is
   		when False =>
   		   case Value_Type is
   			  when BOOLEAN_TYPE => Boolean_Value : Boolean;
   			  when SBYTE_TYPE => SByte_Value : SByte;
   			  when BYTE_TYPE => Byte_Value : Byte;
   			  when INT16_TYPE => Int16_Value : Int16;
   			  when UINT16_TYPE => UInt16_Value : UInt16;
   			  when INT32_TYPE => Int32_Value : Int32;
   			  when UINT32_TYPE => UInt32_Value : UInt32;
   			  when INT64_TYPE => Int64_Value : Int64;
   			  when UINT64_TYPE => UInt64_Value : UInt64;
   			  when FLOAT_TYPE => Float_Value : Float;
   			  when DOUBLE_TYPE => Double_Value : Double;
   			  when STRING_TYPE => String_Value : String;
   			  when DATETIME_TYPE => DateTime_Value : DateTime;
   			  when GUID_TYPE => Guid_Value : Guid;
   			  when BYTESTRING_TYPE => ByteString_Value : ByteString;
   			  when XMLELEMENT_TYPE => XmlElement_Value : XmlElement;
   			  when NODEID_TYPE => NodeId_Value : NodeIds.Pointer;
   			  when EXPANDEDNODEID_TYPE => ExpandedNodeId_Value : ExpandedNodeIds.Pointer;
   			  when STATUSCODE_TYPE => StatusCode_Value : StatusCode;
   			  when QUALIFIEDNAME_TYPE => QualifiedName_Value : QualifiedNames.Pointer;
   			  when LOCALIZEDTEXT_TYPE => LocalizedText_Value : LocalizedTexts.Pointer;
   			  when EXTENSIONOBJECT_TYPE => ExtensionObject_Value : ExtensionObjects.Pointer;
   			  when DATAVALUE_TYPE => DataValue_Value : DataValues.Pointer;
   			  when VARIANT_TYPE => Variant_Value : Variants.Pointer;
   			  when DIAGNOSTICINFO_TYPE => DiagnosticInfo_Value : DiagnosticInfos.Pointer;
   		   end case;
   		when True =>
   		   ArrayDimensions : ListOfInt32.Nullable_Pointer;
   		   case Value_Type is
   			  when BOOLEAN_TYPE => Boolean_Values : ListOfBoolean.Pointer;
   			  when SBYTE_TYPE => SByte_Values : ListOfSByte.Pointer;
   			  when BYTE_TYPE => Byte_Values : ListOfByte.Pointer;
   			  when INT16_TYPE => Int16_Values : ListOfInt16.Pointer;
   			  when UINT16_TYPE => UInt16_Values : ListOfUInt16.Pointer;
   			  when INT32_TYPE => Int32_Values : ListOfInt32.Pointer;
   			  when UINT32_TYPE => UInt32_Values : ListOfUInt32.Pointer;
   			  when INT64_TYPE => Int64_Values : ListOfInt64.Pointer;
   			  when UINT64_TYPE => UInt64_Values : ListOfUInt64.Pointer;
   			  when FLOAT_TYPE => Float_Values : ListOfFloat.Pointer;
   			  when DOUBLE_TYPE => Double_Values : ListOfDouble.Pointer;
   			  when STRING_TYPE => String_Values : ListOfString.Pointer;
   			  when DATETIME_TYPE => DateTime_Values : ListOfDateTime.Pointer;
   			  when GUID_TYPE => Guid_Values : ListOfGuid.Pointer;
   			  when BYTESTRING_TYPE => ByteString_Values : ListOfByteString.Pointer;
   			  when XMLELEMENT_TYPE => XmlElement_Values : ListOfXmlElement.Pointer;
   			  when NODEID_TYPE => NodeId_Values : ListOfNodeId.Pointer;
   			  when EXPANDEDNODEID_TYPE => ExpandedNodeId_Values : ListOfExpandedNodeId.Pointer;
   			  when STATUSCODE_TYPE => StatusCode_Values : ListOfStatusCode.Pointer;
   			  when QUALIFIEDNAME_TYPE => QualifiedName_Values : ListOfQualifiedName.Pointer;
   			  when LOCALIZEDTEXT_TYPE => LocalizedText_Values : ListOfLocalizedText.Pointer;
   			  when EXTENSIONOBJECT_TYPE => ExtensionObject_Values : ListOfExtensionObject.Pointer;
   			  when DATAVALUE_TYPE => DataValue_Values : ListOfDataValue.Pointer;
   			  when VARIANT_TYPE => Variant_Values : ListOfVariant.Pointer;
   			  when DIAGNOSTICINFO_TYPE => DiagnosticInfo_Values : ListOfDiagnosticInfo.Pointer;
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
