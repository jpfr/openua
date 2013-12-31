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
   type Byte is new C.unsigned_char;
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
   type Variant;
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
                  Byte_String_Identifier : NotNullByteString;
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
      Namespace_Uri : String; -- String is a Nullable_Pointer
      Server_Index  : UInt32s.Nullable_Pointer;
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
      Symbolic_Id          : Int32s.Nullable_Pointer;
      Namespace_Uri        : Int32s.Nullable_Pointer;
      Localized_Text       : Int32s.Nullable_Pointer;
      Locale              : Int32s.Nullable_Pointer;
      Additional_Info      : String; -- String is a Nullable_Pointer
	  Inner_Status_Code     : StatusCodes.Nullable_Pointer;
      Inner_Diagnostic_Info : DiagnosticInfos.Nullable_Pointer;
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
      Namespace_Index : UInt16;
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
   		   Byte_String_Body : NotNullByteString;
   		when XMLELEMENT_BODY =>
   		   Xml_Element_Body : NotNullXmlElement;
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
      Source_Timestamp   : DateTimes.Nullable_Pointer;
      Source_Picoseconds : UInt16s.Nullable_Pointer;
      Server_Timestamp   : DateTimes.Nullable_Pointer;
      Server_Picoseconds : UInt16s.Nullable_Pointer;
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
		 when DATETIME_VARIANT => Date_Time_Value : DateTime;
		 when GUID_VARIANT => Guid_Value : Guid;
		 when BYTESTRING_VARIANT => Byte_String_Value : ByteString;
		 when XMLELEMENT_VARIANT => Xml_Element_Value : XmlElement;
		 when NODEID_VARIANT => Node_Id_Value : NodeIds.Pointer;
		 when EXPANDEDNODEID_VARIANT => Expanded_Node_Id_Value : ExpandedNodeIds.Pointer;
		 when STATUSCODE_VARIANT => Status_Code_Value : StatusCode;
		 when QUALIFIEDNAME_VARIANT => Qualified_Name_Value : QualifiedNames.Pointer;
		 when LOCALIZEDTEXT_VARIANT => Localized_Text_Value : LocalizedTexts.Pointer;
		 when EXTENSIONOBJECT_VARIANT => Extension_Object_Value : ExtensionObjects.Pointer;
		 when DATAVALUE_VARIANT => Data_Value_Value : DataValues.Pointer;
		 when VARIANT_VARIANT => Variant_Value : Variants.Pointer;
		 when DIAGNOSTICINFO_VARIANT => Diagnostic_Info_Value : DiagnosticInfos.Pointer;
		 when others =>
			Array_Dimensions : ListOfInt32.Nullable_Pointer;
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
			   when DATETIME_ARRAY_VARIANT => Date_Time_Values : ListOfDateTime.Pointer;
			   when GUID_ARRAY_VARIANT => Guid_Values : ListOfGuid.Pointer;
			   when BYTESTRING_ARRAY_VARIANT => Byte_String_Values : ListOfByteString.Pointer;
			   when XMLELEMENT_ARRAY_VARIANT => Xml_Element_Values : ListOfXmlElement.Pointer;
			   when NODEID_ARRAY_VARIANT => Node_Id_Values : ListOfNodeId.Pointer;
			   when EXPANDEDNODEID_ARRAY_VARIANT => Expanded_Node_Id_Values : ListOfExpandedNodeId.Pointer;
			   when STATUSCODE_ARRAY_VARIANT => Status_Code_Values : ListOfStatusCode.Pointer;
			   when QUALIFIEDNAME_ARRAY_VARIANT => Qualified_Name_Values : ListOfQualifiedName.Pointer;
			   when LOCALIZEDTEXT_ARRAY_VARIANT => Localized_Text_Values : ListOfLocalizedText.Pointer;
			   when EXTENSIONOBJECT_ARRAY_VARIANT => Extension_Object_Values : ListOfExtensionObject.Pointer;
			   when DATAVALUE_ARRAY_VARIANT => Data_Value_Values : ListOfDataValue.Pointer;
			   when VARIANT_ARRAY_VARIANT => Variant_Values : ListOfVariant.Pointer;
			   when DIAGNOSTICINFO_ARRAY_VARIANT => Diagnostic_Info_Values : ListOfDiagnosticInfo.Pointer;
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
   
   ----------------------------
   --  End of Builtin Types  --
   ----------------------------

   -- Todo for a minimal data exchange:
   -- BrowseRequest & BrowseResponse
   
   type RequestHeader is new UA_Builtin with record
	  AuthenticationToken : NodeIds.Pointer;
	  Timestamp : DateTime;
	  RequestHandle : UInt32;
	  ReturnDiagnostics : UInt32;
	  AuditEntryId : ListOfString.Pointer;
	  TimeoutHint : UInt32;
	  AdditionalHeader : ExtensionObjects.Pointer;
   end record;
   function NodeId_Nr(Item : in RequestHeader) return UInt16 is (SID.RequestHeader_Id);
   function Binary_Size(Item : RequestHeader) return Int32 is (NodeIds.Binary_Size(Item.AuthenticationToken) + 8 + 4 + 4 + ListOfString.Binary_Size(Item.AuditentryId) + 4 + ExtensionObjects.Binary_Size(Item.AdditionalHeader));
   
   type Request_Base is abstract new UA_Builtin with record
	  Request_Header : RequestHeader;
   end record;
   
   type ResponseHeader is new UA_Builtin with record
	  Timestamp : DateTime;
	  RequestHandle : UInt32;
	  ServiceResult : StatusCode;
	  ServiceDiagnostics : DiagnosticInfo;
	  StringTable : ListOfString.Pointer;
	  AdditionalHeader : ExtensionObjects.Pointer;
   end record;
   function NodeId_Nr(Item : in ResponseHeader) return UInt16 is (SID.ResponseHeader_Id);
   function Binary_Size(Item : ResponseHeader) return Int32 is (8 + 4 + 4 + Binary_Size(Item.ServiceDiagnostics) + ListOfString.Binary_Size(Item.StringTable) + ExtensionObjects.Binary_Size(Item.AdditionalHeader));
   
   type Response_Base is abstract new UA_Builtin with record
	  Response_Header : ResponseHeader;
   end record;
   
   ----------------------------
   --  Auto Generated Types  --
   ----------------------------
   
   -- MessageSecurityMode
   -- The type of security to use on a message.
   type MessageSecurityMode is (MessageSecurityMode_Invalid, MessageSecurityMode_None, MessageSecurityMode_Sign, MessageSecurityMode_SignAndEncrypt);
   for MessageSecurityMode'Size use 32;
   for MessageSecurityMode use (MessageSecurityMode_Invalid => 0,
   								MessageSecurityMode_None => 1,
   								MessageSecurityMode_Sign => 2,
   								MessageSecurityMode_SignAndEncrypt => 3);
   
   --  SecurityTokenRequestType
   --  Indicates whether a token if being created or renewed.
   type SecurityTokenRequestType is (SecurityTokenRequestType_Issue, SecurityTokenRequestType_Renew);
   for SecurityTokenRequestType'Size use 32;
   for SecurityTokenRequestType use (SecurityTokenRequestType_Issue => 0,
   									 SecurityTokenRequestType_Renew => 1);
   
   -- ChannelSecurityToken
   -- The token that identifies a set of keys for an active secure channel.
   type ChannelSecurityToken is new UA_Builtin with record
   	  Channel_Id : UInt32;
   	  Token_Id : UInt32;
   	  Created_At : DateTime;
   	  Revised_Lifetime : UInt32;
   end record;
   function NodeId_Nr(Item : in ChannelSecurityToken) return UInt16 is (SID.ChannelSecurityToken_Id);
   function Binary_Size(Item : ChannelSecurityToken) return Int32 is ( 4 + 4 + 8 + 4 );

   -- OpenSecureChannelRequest
   -- Creates a secure channel with a server.
   type OpenSecureChannelRequest is new Request_Base with record
   	  Client_Protocol_Version : UInt32;
   	  Request_Type : SecurityTokenRequestType;
   	  Security_Mode : MessageSecurityMode;
   	  Client_Nonce : ByteString;
   	  Requested_Lifetime : UInt32;
   end record;
   function NodeId_Nr(Item : in OpenSecureChannelRequest) return UInt16 is (SID.OpenSecureChannelRequest_Id);
   function Binary_Size(Item : OpenSecureChannelRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 8 + 8 + Binary_Size(Item.Client_Nonce) + 4 );
   
   -- OpenSecureChannelResponse
   -- Creates a secure channel with a server.
   type OpenSecureChannelResponse is new Response_Base with record
   	  Server_Protocol_Version : UInt32;
   	  Security_Token : ChannelSecurityToken;
   	  Server_Nonce : ByteString;
   end record;
   function NodeId_Nr(Item : in OpenSecureChannelResponse) return UInt16 is (SID.OpenSecureChannelResponse_Id);
   function Binary_Size(Item : OpenSecureChannelResponse) return Int32 is ( Binary_Size(Item.Response_Header) + 4 + Binary_Size(Item.Security_Token) + Binary_Size(Item.Server_Nonce) );

   -- ApplicationType
   -- The types of applications.
   type ApplicationType is (ApplicationType_Server, ApplicationType_Client, ApplicationType_ClientAndServer, ApplicationType_DiscoveryServer);
   for ApplicationType'Size use 32;
   for ApplicationType use (ApplicationType_Server => 0,
   							ApplicationType_Client => 1,
   							ApplicationType_ClientAndServer => 2,
   							ApplicationType_DiscoveryServer => 3);

   -- ApplicationDescription
   -- Describes an application and how to find it.
   type ApplicationDescription is new UA_Builtin with record
   	  Application_Uri : String;
   	  Product_Uri : String;
   	  Application_Name : LocalizedTexts.Pointer;
   	  Application_Type : ApplicationType;
   	  Gateway_Server_Uri : String;
   	  Discovery_Profile_Uri : String;
   	  Discovery_Urls : ListOfString.Pointer;
   end record;
   function NodeId_Nr(Item : in ApplicationDescription) return UInt16 is (SID.ApplicationDescription_Id);
   function Binary_Size(Item : ApplicationDescription) return Int32 is ( Binary_Size(Item.Application_Uri) + Binary_Size(Item.Product_Uri) + LocalizedTexts.Binary_Size(Item.Application_Name) + 8 + Binary_Size(Item.Gateway_Server_Uri) + Binary_Size(Item.Discovery_Profile_Uri) + ListOfString.Binary_Size(Item.Discovery_Urls) );
   
   package ListOfApplicationDescription is new Types.Arrays.UA_Builtin_Arrays(ApplicationDescription);

   -- UserTokenType
   -- The possible user token types.
   type UserTokenType is (UserTokenType_Anonymous, UserTokenType_UserName, UserTokenType_Certificate, UserTokenType_IssuedToken);
   for UserTokenType'Size use 32;
   for UserTokenType use (UserTokenType_Anonymous => 0,
   						  UserTokenType_UserName => 1,
   						  UserTokenType_Certificate => 2,
   						  UserTokenType_IssuedToken => 3);
   
   -- UserTokenPolicy
   -- Describes a user token that can be used with a server.
   type UserTokenPolicy is new UA_Builtin with record
   	  Policy_Id : String;
   	  Token_Type : UserTokenType;
   	  Issued_Token_Type : String;
   	  Issuer_Endpoint_Url : String;
   	  Security_Policy_Uri : String;
   end record;
   function NodeId_Nr(Item : in UserTokenPolicy) return UInt16 is (SID.UserTokenPolicy_Id);
   function Binary_Size(Item : UserTokenPolicy) return Int32 is ( Binary_Size(Item.Policy_Id) + 8 + Binary_Size(Item.Issued_Token_Type) + Binary_Size(Item.Issuer_Endpoint_Url) + Binary_Size(Item.Security_Policy_Uri) );
   
   package ListOfUserTokenPolicy is new Types.Arrays.UA_Builtin_Arrays(UserTokenPolicy);

   -- EndpointDescription
   -- The description of a endpoint that can be used to access a server.
   type EndpointDescription is new UA_Builtin with record
   	  Endpoint_Url : String;
   	  Server : ApplicationDescription;
   	  Server_Certificate : ByteString;
   	  Security_Mode : MessageSecurityMode;
   	  Security_Policy_Uri : String;
   	  User_Identity_Tokens : ListOfUserTokenPolicy.Pointer;
   	  Transport_Profile_Uri : String;
   	  Security_Level : Byte;
   end record;
   function NodeId_Nr(Item : in EndpointDescription) return UInt16 is (SID.EndpointDescription_Id);
   function Binary_Size(Item : EndpointDescription) return Int32 is ( Binary_Size(Item.Endpoint_Url) + Binary_Size(Item.Server) + Binary_Size(Item.Server_Certificate) + 8 + Binary_Size(Item.Security_Policy_Uri) + ListOfUserTokenPolicy.Binary_Size(Item.User_Identity_Tokens) + Binary_Size(Item.Transport_Profile_Uri) + 1 );
   
   package ListOfEndpointDescription is new Types.Arrays.UA_Builtin_Arrays(EndpointDescription);

   -- GetEndpointsRequest
   -- Gets the endpoints used by the server.
   type GetEndpointsRequest is new Request_Base with record
   	  Endpoint_Url : String;
   	  Locale_Ids : ListOfString.Pointer;
   	  Profile_Uris : ListOfString.Pointer;
   end record;
   function NodeId_Nr(Item : in GetEndpointsRequest) return UInt16 is (SID.GetEndpointsRequest_Id);
   function Binary_Size(Item : GetEndpointsRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.Endpoint_Url) + ListOfString.Binary_Size(Item.Locale_Ids) + ListOfString.Binary_Size(Item.Profile_Uris) );
   
   -- GetEndpointsResponse
   -- Gets the endpoints used by the server.
   type GetEndpointsResponse is new Response_Base with record
   	  Endpoints : ListOfEndpointDescription.Pointer;
   end record;
   function NodeId_Nr(Item : in GetEndpointsResponse) return UInt16 is (SID.GetEndpointsResponse_Id);
   function Binary_Size(Item : GetEndpointsResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfEndpointDescription.Binary_Size(Item.Endpoints) );
   
   -- CreateSessionRequest
   -- Creates a new session with the server.
   type CreateSessionRequest is new Request_Base with record
   	  Client_Description : ApplicationDescription;
   	  Server_Uri : String;
   	  Endpoint_Url : String;
   	  Session_Name : String;
   	  Client_Nonce : ByteString;
   	  Client_Certificate : ByteString;
   	  Requested_Session_Timeout : Double;
   	  Max_Response_Message_Size : UInt32;
   end record;
   function NodeId_Nr(Item : in CreateSessionRequest) return UInt16 is (SID.CreateSessionRequest_Id);
   function Binary_Size(Item : CreateSessionRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.Client_Description) + Binary_Size(Item.Server_Uri) + Binary_Size(Item.Endpoint_Url) + Binary_Size(Item.Session_Name) + Binary_Size(Item.Client_Nonce) + Binary_Size(Item.Client_Certificate) + 8 + 4 );

   -- SignedSoftwareCertificate
   -- A software certificate with a digital signature.
   type SignedSoftwareCertificate is new UA_Builtin with record
   	  Certificate_Data : ByteString;
   	  Signature : ByteString;
   end record;
   function NodeId_Nr(Item : in SignedSoftwareCertificate) return UInt16 is (SID.SignedSoftwareCertificate_Id);
   function Binary_Size(Item : SignedSoftwareCertificate) return Int32 is ( Binary_Size(Item.Certificate_Data) + Binary_Size(Item.Signature) );
   
   package ListOfSignedSoftwareCertificate is new Types.Arrays.UA_Builtin_Arrays(SignedSoftwareCertificate);
   
   type SessionAuthenticationToken is new Bytes.Pointer with null record;
   function NodeId_Nr(Item : in SessionAuthenticationToken) return UInt16 is (SID.SessionAuthenticationToken_Id);
   
   -- SignatureData
   -- A digital signature.
   type SignatureData is new UA_Builtin with record
   	  Algorithm : String;
   	  Signature : ByteString;
   end record;
   function NodeId_Nr(Item : in SignatureData) return UInt16 is (SID.SignatureData_Id);
   function Binary_Size(Item : SignatureData) return Int32 is ( Binary_Size(Item.Algorithm) + Binary_Size(Item.Signature) ); 
   
   -- CreateSessionResponse
   -- Creates a new session with the server.
   type CreateSessionResponse is new Response_Base with record
   	  Session_Id : NodeIds.Pointer;
   	  Authentication_Token : NodeIds.Pointer;
   	  Revised_Session_Timeout : Double;
   	  Server_Nonce : ByteString;
   	  Server_Certificate : ByteString;
   	  Server_Endpoints : ListOfEndpointDescription.Pointer;
   	  Server_Software_Certificates : ListOfSignedSoftwareCertificate.Pointer;
   	  Server_Signature : SignatureData;
   	  Max_Request_Message_Size : UInt32;
   end record;
   function NodeId_Nr(Item : in CreateSessionResponse) return UInt16 is (SID.CreateSessionResponse_Id);
   function Binary_Size(Item : CreateSessionResponse) return Int32 is ( Binary_Size(Item.Response_Header) + NodeIds.Binary_Size(Item.Session_Id) + NodeIds.Binary_Size(Item.Authentication_Token) + 8 + Binary_Size(Item.Server_Nonce) + Binary_Size(Item.Server_Certificate) + ListOfEndpointDescription.Binary_Size(Item.Server_Endpoints) + ListOfSignedSoftwareCertificate.Binary_Size(Item.Server_Software_Certificates) + Binary_Size(Item.Server_Signature) + 4 );

   -- TimestampsToReturn
   type TimestampsToReturn is (TimestampsToReturn_Source, TimestampsToReturn_Server, TimestampsToReturn_Both, TimestampsToReturn_Neither);
   for TimestampsToReturn'Size use 32;
   for TimestampsToReturn use (TimestampsToReturn_Source => 0,
   							   TimestampsToReturn_Server => 1,
   							   TimestampsToReturn_Both => 2,
   							   TimestampsToReturn_Neither => 3);
   
   -- ReadValueId
   type ReadValueId is new UA_Builtin with record
   	  Node_Id : NodeIds.Pointer;
   	  Attribute_Id : UInt32;
   	  Index_Range : String;
   	  Data_Encoding : QualifiedNames.Pointer;
   end record;
   function NodeId_Nr(Item : in ReadValueId) return UInt16 is (SID.ReadValueId_Id);
   function Binary_Size(Item : ReadValueId) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 4 + Binary_Size(Item.Index_Range) + QualifiedNames.Binary_Size(Item.Data_Encoding) );
   
   package ListOfReadValueId is new Types.Arrays.UA_Builtin_Arrays(ReadValueId); 
   
   -- ReadRequest
   type ReadRequest is new Request_Base with record
   	  Max_Age : Double;
   	  Timestamps_To_Return : TimestampsToReturn;
   	  Nodes_To_Read : ListOfReadValueId.Pointer;
   end record;
   function NodeId_Nr(Item : in ReadRequest) return UInt16 is (SID.ReadRequest_Id);
   function Binary_Size(Item : ReadRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 8 + 8 + ListOfReadValueId.Binary_Size(Item.Nodes_To_Read) );
   
   -- ReadResponse
   type ReadResponse is new Response_Base with record
   	  Results : DataValues.Pointer;
   	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   end record;
   function NodeId_Nr(Item : in ReadResponse) return UInt16 is (SID.ReadResponse_Id);
   function Binary_Size(Item : ReadResponse) return Int32 is ( Binary_Size(Item.Response_Header) + DataValues.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   type ContinuationPoint is new Bytes.Pointer with null record;
   function NodeId_Nr(Item : in ContinuationPoint) return UInt16 is (SID.ContinuationPoint_Id);
   
   -- NodeClass
   -- A mask specifying the class of the node.
   type NodeClass is (NodeClass_Unspecified, NodeClass_Object, NodeClass_Variable, NodeClass_Method, NodeClass_ObjectType,
   					  NodeClass_VariableType, NodeClass_ReferenceType, NodeClass_DataType, NodeClass_View);
   for NodeClass'Size use 32;
   for NodeClass use (NodeClass_Unspecified => 0,
   					  NodeClass_Object => 1,
   					  NodeClass_Variable => 2,
   					  NodeClass_Method => 4,
   					  NodeClass_ObjectType => 8,
   					  NodeClass_VariableType => 16,
   					  NodeClass_ReferenceType => 32,
   					  NodeClass_DataType => 64,
   					  NodeClass_View => 128);

   -- ReferenceDescription
   -- The description of a reference.
   type ReferenceDescription is new UA_Builtin with record
   	  Reference_Type_Id : NodeIds.Pointer;
   	  Is_Forward : Boolean;
   	  Node_Id : ExpandedNodeIds.Pointer;
   	  Browse_Name : QualifiedNames.Pointer;
   	  Display_Name : LocalizedTexts.Pointer;
   	  Node_Class : NodeClass;
   	  Type_Definition : ExpandedNodeIds.Pointer;
   end record;
   function NodeId_Nr(Item : in ReferenceDescription) return UInt16 is (SID.ReferenceDescription_Id);
   function Binary_Size(Item : ReferenceDescription) return Int32 is ( NodeIds.Binary_Size(Item.Reference_Type_Id) + 1 + ExpandedNodeIds.Binary_Size(Item.Node_Id) + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + 8 + ExpandedNodeIds.Binary_Size(Item.Type_Definition) );
   
   package ListOfReferenceDescription is new Types.Arrays.UA_Builtin_Arrays(ReferenceDescription);
   
   -- BrowseResult
   -- The result of a browse operation.
   type BrowseResult is new UA_Builtin with record
   	  Status_Code : StatusCode;
   	  Continuation_Point : ByteString;
   	  References : ListOfReferenceDescription.Pointer;
   end record;
   function NodeId_Nr(Item : in BrowseResult) return UInt16 is (SID.BrowseResult_Id);
   function Binary_Size(Item : BrowseResult) return Int32 is ( 4 + Binary_Size(Item.Continuation_Point) + ListOfReferenceDescription.Binary_Size(Item.References) );
   
   package ListOfBrowseResult is new Types.Arrays.UA_Builtin_Arrays(BrowseResult);

   -- ViewDescription
   -- The view to browse.
   type ViewDescription is new UA_Builtin with record
   	  View_Id : NodeIds.Pointer;
   	  Timestamp : DateTime;
   	  View_Version : UInt32;
   end record;
   function NodeId_Nr(Item : in ViewDescription) return UInt16 is (SID.ViewDescription_Id);
   function Binary_Size(Item : ViewDescription) return Int32 is ( NodeIds.Binary_Size(Item.View_Id) + 8 + 4 );

   -- BrowseDirection
   -- The directions of the references to return.
   type BrowseDirection is (BrowseDirection_Forward, BrowseDirection_Inverse, BrowseDirection_Both);
   for BrowseDirection'Size use 32;
   for BrowseDirection use (BrowseDirection_Forward => 0,
   							BrowseDirection_Inverse => 1,
   							BrowseDirection_Both => 2);
   
   -- BrowseDescription
   -- A request to browse the the references from a node.
   type BrowseDescription is new UA_Builtin with record
   	  Node_Id : NodeIds.Pointer;
   	  Browse_Direction : BrowseDirection;
   	  Reference_Type_Id : NodeIds.Pointer;
   	  Include_Subtypes : Boolean;
   	  Node_Class_Mask : UInt32;
   	  Result_Mask : UInt32;
   end record;
   function NodeId_Nr(Item : in BrowseDescription) return UInt16 is (SID.BrowseDescription_Id);
   function Binary_Size(Item : BrowseDescription) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8 + NodeIds.Binary_Size(Item.Reference_Type_Id) + 1 + 4 + 4 );
   
   package ListOfBrowseDescription is new Types.Arrays.UA_Builtin_Arrays(BrowseDescription);
   
   -- BrowseRequest
   -- Browse the references for one or more nodes from the server address space.
   type BrowseRequest is new Request_Base with record
   	  View : ViewDescription;
   	  Requested_Max_References_Per_Node : UInt32;
   	  Nodes_To_Browse : ListOfBrowseDescription.Pointer;
   end record;
   function NodeId_Nr(Item : in BrowseRequest) return UInt16 is (SID.BrowseRequest_Id);
   function Binary_Size(Item : BrowseRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.View) + 4 + ListOfBrowseDescription.Binary_Size(Item.Nodes_To_Browse) );
   
   -- BrowseResponse
   -- Browse the references for one or more nodes from the server address space.
   type BrowseResponse is new Response_Base with record
   	  Results : ListOfBrowseResult.Pointer;
   	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   end record;
   function NodeId_Nr(Item : in BrowseResponse) return UInt16 is (SID.BrowseResponse_Id);
   function Binary_Size(Item : BrowseResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfBrowseResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   -- BrowseNextRequest
   -- Continues one or more browse operations.
   type BrowseNextRequest is new Request_Base with record
   	  Release_Continuation_Points : Boolean;
   	  Continuation_Points : ListOfByteString.Pointer;
   end record;
   function NodeId_Nr(Item : in BrowseNextRequest) return UInt16 is (SID.BrowseNextRequest_Id);
   function Binary_Size(Item : BrowseNextRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 1 + ListOfByteString.Binary_Size(Item.Continuation_Points) );
   
   -- BrowseNextResponse
   -- Continues one or more browse operations.
   type BrowseNextResponse is new Response_Base with record
   	  Results : ListOfBrowseResult.Pointer;
   	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   end record;
   function NodeId_Nr(Item : in BrowseNextResponse) return UInt16 is (SID.BrowseNextResponse_Id);
   function Binary_Size(Item : BrowseNextResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfBrowseResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );

   --  type ImageBMP is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in ImageBMP) return UInt16 is (SID.ImageBMP_Id);
   
   --  type ImageGIF is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in ImageGIF) return UInt16 is (SID.ImageGIF_Id);
   
   --  type ImageJPG is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in ImageJPG) return UInt16 is (SID.ImageJPG_Id);
   
   --  type ImagePNG is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in ImagePNG) return UInt16 is (SID.ImagePNG_Id);
   
   --  type BitFieldMaskDataType is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in BitFieldMaskDataType) return UInt16 is (SID.BitFieldMaskDataType_Id);
   
   --  -- OpenFileMode
   --  type OpenFileMode is (OpenFileMode_Read,
   --  						 OpenFileMode_Write,
   --  						 OpenFileMode_EraseExisiting,
   --  						 OpenFileMode_Append);
   --  for OpenFileMode'Size use 32;
   --  for OpenFileMode use (OpenFileMode_Read => 1,
   --  						 OpenFileMode_Write => 2,
   --  						 OpenFileMode_EraseExisiting => 4,
   --  						 OpenFileMode_Append => 8);
   
   --  -- IdType
   --  -- The type of identifier used in a node id.
   --  type IdType is (IdType_Numeric,
   --  				   IdType_String,
   --  				   IdType_Guid,
   --  				   IdType_Opaque);
   --  for IdType'Size use 32;
   --  for IdType use (IdType_Numeric => 0,
   --  				   IdType_String => 1,
   --  				   IdType_Guid => 2,
   --  				   IdType_Opaque => 3);
   
   --  -- ReferenceNode
   --  -- Specifies a reference which belongs to a node.
   --  type ReferenceNode is new UA_Builtin with record
   --  	  Reference_Type_Id : NodeIds.Pointer;
   --  	  Is_Inverse : Boolean;
   --  	  Target_Id : ExpandedNodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ReferenceNode) return UInt16 is (SID.ReferenceNode_Id);
   --  function Binary_Size(Item : ReferenceNode) return Int32 is ( NodeIds.Binary_Size(Item.Reference_Type_Id) + 1 + ExpandedNodeIds.Binary_Size(Item.Target_Id) );
   
   --  package ListOfReferenceNode is new Types.Arrays.UA_Builtin_Arrays(ReferenceNode);
   
   --  -- Argument
   --  -- An argument for a method.
   --  type Argument is new UA_Builtin with record
   --  	  Name : String;
   --  	  Data_Type : NodeIds.Pointer;
   --  	  Value_Rank : Int32;
   --  	  Array_Dimensions : ListOfUInt32.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in Argument) return UInt16 is (SID.Argument_Id);
   --  function Binary_Size(Item : Argument) return Int32 is ( Binary_Size(Item.Name) + NodeIds.Binary_Size(Item.Data_Type) + 4 + ListOfUInt32.Binary_Size(Item.Array_Dimensions) + LocalizedTexts.Binary_Size(Item.Description) );
   
   --  package ListOfArgument is new Types.Arrays.UA_Builtin_Arrays(Argument);
   
   --  -- EnumValueType
   --  -- A mapping between a value of an enumerated type and a name and description.
   --  type EnumValueType is new UA_Builtin with record
   --  	  Value : Int64;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in EnumValueType) return UInt16 is (SID.EnumValueType_Id);
   --  function Binary_Size(Item : EnumValueType) return Int32 is ( 8 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) );
   
   --  type Duration is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in Duration) return UInt16 is (SID.Duration_Id);
   
   --  type UtcTime is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in UtcTime) return UInt16 is (SID.UtcTime_Id);
   
   --  type LocaleId is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in LocaleId) return UInt16 is (SID.LocaleId_Id);
   
   --  -- TimeZoneDataType
   --  type TimeZoneDataType is new UA_Builtin with record
   --  	  Offset : Int16;
   --  	  Daylight_Saving_In_Offset : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in TimeZoneDataType) return UInt16 is (SID.TimeZoneDataType_Id);
   --  function Binary_Size(Item : TimeZoneDataType) return Int32 is ( 2 + 1 );
   
   --  type IntegerId is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in IntegerId) return UInt16 is (SID.IntegerId_Id);
    
   --  -- ServiceFault
   --  -- The response returned by all services when there is a service level error.
   --  type ServiceFault is new UA_Builtin with  null record;
   --  function NodeId_Nr(Item : in ServiceFault) return UInt16 is (SID.ServiceFault_Id);
   --  function Binary_Size(Item : ServiceFault) return Int32 is ( 0 );
   
   --  -- FindServersRequest
   --  -- Finds the servers known to the discovery server.
   --  type FindServersRequest is new Request_Base with record
   --  	  Endpoint_Url : String;
   --  	  Locale_Ids : ListOfString.Pointer;
   --  	  Server_Uris : ListOfString.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in FindServersRequest) return UInt16 is (SID.FindServersRequest_Id);
   --  function Binary_Size(Item : FindServersRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.Endpoint_Url) + ListOfString.Binary_Size(Item.Locale_Ids) + ListOfString.Binary_Size(Item.Server_Uris) );
   
   --  -- FindServersResponse
   --  -- Finds the servers known to the discovery server.
   --  type FindServersResponse is new Response_Base with record
   --  	  Servers : ListOfApplicationDescription.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in FindServersResponse) return UInt16 is (SID.FindServersResponse_Id);
   --  function Binary_Size(Item : FindServersResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfApplicationDescription.Binary_Size(Item.Servers) );
   
   --  type ApplicationInstanceCertificate is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in ApplicationInstanceCertificate) return UInt16 is (SID.ApplicationInstanceCertificate_Id);
   
   --  -- RegisteredServer
   --  -- The information required to register a server with a discovery server.
   --  type RegisteredServer is new UA_Builtin with record
   --  	  Server_Uri : String;
   --  	  Product_Uri : String;
   --  	  Server_Names : LocalizedTexts.Pointer;
   --  	  Server_Type : ApplicationType;
   --  	  Gateway_Server_Uri : String;
   --  	  Discovery_Urls : ListOfString.Pointer;
   --  	  Semaphore_File_Path : String;
   --  	  Is_Online : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in RegisteredServer) return UInt16 is (SID.RegisteredServer_Id);
   --  function Binary_Size(Item : RegisteredServer) return Int32 is ( Binary_Size(Item.Server_Uri) + Binary_Size(Item.Product_Uri) + LocalizedTexts.Binary_Size(Item.Server_Names) + 8
   --  																	 + Binary_Size(Item.Gateway_Server_Uri) + ListOfString.Binary_Size(Item.Discovery_Urls) + Binary_Size(Item.Semaphore_File_Path) + 1 );
   
   --  -- RegisterServerRequest
   --  -- Registers a server with the discovery server.
   --  type RegisterServerRequest is new Request_Base with record
   --  	  Server : RegisteredServer;
   --  end record;
   --  function NodeId_Nr(Item : in RegisterServerRequest) return UInt16 is (SID.RegisterServerRequest_Id);
   --  function Binary_Size(Item : RegisterServerRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.Server) );
   
   --  -- RegisterServerResponse
   --  -- Registers a server with the discovery server.
   --  type RegisterServerResponse is new Response_Base with  null record;
   --  function NodeId_Nr(Item : in RegisterServerResponse) return UInt16 is (SID.RegisterServerResponse_Id);
   --  function Binary_Size(Item : RegisterServerResponse) return Int32 is ( Binary_Size(Item.Response_Header) );
    
   --  -- CloseSecureChannelRequest
   --  -- Closes a secure channel.
   --  type CloseSecureChannelRequest is new Request_Base with  null record;
   --  function NodeId_Nr(Item : in CloseSecureChannelRequest) return UInt16 is (SID.CloseSecureChannelRequest_Id);
   --  function Binary_Size(Item : CloseSecureChannelRequest) return Int32 is ( Binary_Size(Item.Request_Header) );
   
   --  -- CloseSecureChannelResponse
   --  -- Closes a secure channel.
   --  type CloseSecureChannelResponse is new Response_Base with  null record;
   --  function NodeId_Nr(Item : in CloseSecureChannelResponse) return UInt16 is (SID.CloseSecureChannelResponse_Id);
   --  function Binary_Size(Item : CloseSecureChannelResponse) return Int32 is ( Binary_Size(Item.Response_Header) );
    
   --  -- UserIdentityToken
   --  -- A base type for a user identity token.
   --  type UserIdentityToken is new UA_Builtin with record
   --  	  Policy_Id : String;
   --  end record;
   --  function NodeId_Nr(Item : in UserIdentityToken) return UInt16 is (SID.UserIdentityToken_Id);
   --  function Binary_Size(Item : UserIdentityToken) return Int32 is ( Binary_Size(Item.Policy_Id) );
   
   --  -- AnonymousIdentityToken
   --  -- A token representing an anonymous user.
   --  type AnonymousIdentityToken is new UA_Builtin with record
   --  	  Policy_Id : String;
   --  end record;
   --  function NodeId_Nr(Item : in AnonymousIdentityToken) return UInt16 is (SID.AnonymousIdentityToken_Id);
   --  function Binary_Size(Item : AnonymousIdentityToken) return Int32 is ( Binary_Size(Item.Policy_Id) );
   
   --  -- UserNameIdentityToken
   --  -- A token representing a user identified by a user name and password.
   --  type UserNameIdentityToken is new UA_Builtin with record
   --  	  Policy_Id : String;
   --  	  User_Name : String;
   --  	  Password : ByteString;
   --  	  Encryption_Algorithm : String;
   --  end record;
   --  function NodeId_Nr(Item : in UserNameIdentityToken) return UInt16 is (SID.UserNameIdentityToken_Id);
   --  function Binary_Size(Item : UserNameIdentityToken) return Int32 is ( Binary_Size(Item.Policy_Id) + Binary_Size(Item.User_Name) + Binary_Size(Item.Password) + Binary_Size(Item.Encryption_Algorithm) );
   
   --  -- X509IdentityToken
   --  -- A token representing a user identified by an X509 certificate.
   --  type X509IdentityToken is new UA_Builtin with record
   --  	  Policy_Id : String;
   --  	  Certificate_Data : ByteString;
   --  end record;
   --  function NodeId_Nr(Item : in X509IdentityToken) return UInt16 is (SID.X509IdentityToken_Id);
   --  function Binary_Size(Item : X509IdentityToken) return Int32 is ( Binary_Size(Item.Policy_Id) + Binary_Size(Item.Certificate_Data) );
   
   --  -- IssuedIdentityToken
   --  -- A token representing a user identified by a WS-Security XML token.
   --  type IssuedIdentityToken is new UA_Builtin with record
   --  	  Policy_Id : String;
   --  	  Token_Data : ByteString;
   --  	  Encryption_Algorithm : String;
   --  end record;
   --  function NodeId_Nr(Item : in IssuedIdentityToken) return UInt16 is (SID.IssuedIdentityToken_Id);
   --  function Binary_Size(Item : IssuedIdentityToken) return Int32 is ( Binary_Size(Item.Policy_Id) + Binary_Size(Item.Token_Data) + Binary_Size(Item.Encryption_Algorithm) );
   
   --  -- ActivateSessionRequest
   --  -- Activates a session with the server.
   --  type ActivateSessionRequest is new Request_Base with record
   --  	  Client_Signature : SignatureData;
   --  	  Client_Software_Certificates : ListOfSignedSoftwareCertificate.Pointer;
   --  	  Locale_Ids : ListOfString.Pointer;
   --  	  User_Identity_Token : ExtensionObjects.Pointer;
   --  	  User_Token_Signature : SignatureData;
   --  end record;
   --  function NodeId_Nr(Item : in ActivateSessionRequest) return UInt16 is (SID.ActivateSessionRequest_Id);
   --  function Binary_Size(Item : ActivateSessionRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.Client_Signature) + ListOfSignedSoftwareCertificate.Binary_Size(Item.Client_Software_Certificates) + ListOfString.Binary_Size(Item.Locale_Ids) + ExtensionObjects.Binary_Size(Item.User_Identity_Token) + Binary_Size(Item.User_Token_Signature) );
   
   --  -- ActivateSessionResponse
   --  -- Activates a session with the server.
   --  type ActivateSessionResponse is new Response_Base with record
   --  	  Server_Nonce : ByteString;
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ActivateSessionResponse) return UInt16 is (SID.ActivateSessionResponse_Id);
   --  function Binary_Size(Item : ActivateSessionResponse) return Int32 is ( Binary_Size(Item.Response_Header) + Binary_Size(Item.Server_Nonce) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- CloseSessionRequest
   --  -- Closes a session with the server.
   --  type CloseSessionRequest is new Request_Base with record
   --  	  Delete_Subscriptions : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in CloseSessionRequest) return UInt16 is (SID.CloseSessionRequest_Id);
   --  function Binary_Size(Item : CloseSessionRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 1 );
   
   --  -- CloseSessionResponse
   --  -- Closes a session with the server.
   --  type CloseSessionResponse is new Response_Base with  null record;
   --  function NodeId_Nr(Item : in CloseSessionResponse) return UInt16 is (SID.CloseSessionResponse_Id);
   --  function Binary_Size(Item : CloseSessionResponse) return Int32 is ( Binary_Size(Item.Response_Header) );
   
   --  -- CancelRequest
   --  -- Cancels an outstanding request.
   --  type CancelRequest is new Request_Base with record
   --  	  Request_Handle : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in CancelRequest) return UInt16 is (SID.CancelRequest_Id);
   --  function Binary_Size(Item : CancelRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 );
   
   --  -- CancelResponse
   --  -- Cancels an outstanding request.
   --  type CancelResponse is new Response_Base with record
   --  	  Cancel_Count : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in CancelResponse) return UInt16 is (SID.CancelResponse_Id);
   --  function Binary_Size(Item : CancelResponse) return Int32 is ( Binary_Size(Item.Response_Header) + 4 );
   
   --  -- NodeAttributesMask
   --  -- The bits used to specify default attributes for a new node.
   --  type NodeAttributesMask is (NodeAttributesMask_None,
   --  							   NodeAttributesMask_AccessLevel,
   --  							   NodeAttributesMask_ArrayDimensions,
   --  							   NodeAttributesMask_BrowseName,
   --  							   NodeAttributesMask_ContainsNoLoops,
   --  							   NodeAttributesMask_DataType,
   --  							   NodeAttributesMask_Description,
   --  							   NodeAttributesMask_DisplayName,
   --  							   NodeAttributesMask_EventNotifier,
   --  							   NodeAttributesMask_Executable,
   --  							   NodeAttributesMask_Historizing,
   --  							   NodeAttributesMask_InverseName,
   --  							   NodeAttributesMask_IsAbstract,
   --  							   NodeAttributesMask_MinimumSamplingInterval,
   --  							   NodeAttributesMask_NodeClass,
   --  							   NodeAttributesMask_NodeId,
   --  							   NodeAttributesMask_Symmetric,
   --  							   NodeAttributesMask_UserAccessLevel,
   --  							   NodeAttributesMask_UserExecutable,
   --  							   NodeAttributesMask_UserWriteMask,
   --  							   NodeAttributesMask_ValueRank,
   --  							   NodeAttributesMask_WriteMask,
   --  							   NodeAttributesMask_BaseNode,
   --  							   NodeAttributesMask_Object,
   --  							   NodeAttributesMask_View,
   --  							   NodeAttributesMask_ObjectTypeOrDataType,
   --  							   NodeAttributesMask_ReferenceType,
   --  							   NodeAttributesMask_Method,
   --  							   NodeAttributesMask_Value,
   --  							   NodeAttributesMask_VariableType,
   --  							   NodeAttributesMask_Variable,
   --  							   NodeAttributesMask_All);
   --  for NodeAttributesMask'Size use 32;
   --  for NodeAttributesMask use (NodeAttributesMask_None => 0,
   --  							   NodeAttributesMask_AccessLevel => 1,
   --  							   NodeAttributesMask_ArrayDimensions => 2,
   --  							   NodeAttributesMask_BrowseName => 4,
   --  							   NodeAttributesMask_ContainsNoLoops => 8,
   --  							   NodeAttributesMask_DataType => 16,
   --  							   NodeAttributesMask_Description => 32,
   --  							   NodeAttributesMask_DisplayName => 64,
   --  							   NodeAttributesMask_EventNotifier => 128,
   --  							   NodeAttributesMask_Executable => 256,
   --  							   NodeAttributesMask_Historizing => 512,
   --  							   NodeAttributesMask_InverseName => 1024,
   --  							   NodeAttributesMask_IsAbstract => 2048,
   --  							   NodeAttributesMask_MinimumSamplingInterval => 4096,
   --  							   NodeAttributesMask_NodeClass => 8192,
   --  							   NodeAttributesMask_NodeId => 16384,
   --  							   NodeAttributesMask_Symmetric => 32768,
   --  							   NodeAttributesMask_UserAccessLevel => 65536,
   --  							   NodeAttributesMask_UserExecutable => 131072,
   --  							   NodeAttributesMask_UserWriteMask => 262144,
   --  							   NodeAttributesMask_ValueRank => 524288,
   --  							   NodeAttributesMask_WriteMask => 1048576,
   --  							   NodeAttributesMask_BaseNode => 1335396,
   --  							   NodeAttributesMask_Object => 1335524,
   --  							   NodeAttributesMask_View => 1335532,
   --  							   NodeAttributesMask_ObjectTypeOrDataType => 1337444,
   --  							   NodeAttributesMask_ReferenceType => 1371236,
   --  							   NodeAttributesMask_Method => 1466724,
   --  							   NodeAttributesMask_Value => 2097152,
   --  							   NodeAttributesMask_VariableType => 3958902,
   --  							   NodeAttributesMask_Variable => 4026999,
   --  							   NodeAttributesMask_All => 4194303);
   
   --  -- NodeAttributes
   --  -- The base attributes for all nodes.
   --  type NodeAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in NodeAttributes) return UInt16 is (SID.NodeAttributes_Id);
   --  function Binary_Size(Item : NodeAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 );
   
   --  -- ObjectAttributes
   --  -- The attributes for an object node.
   --  type ObjectAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Event_Notifier : Byte;
   --  end record;
   --  function NodeId_Nr(Item : in ObjectAttributes) return UInt16 is (SID.ObjectAttributes_Id);
   --  function Binary_Size(Item : ObjectAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + 1 );
   
   --  -- VariableAttributes
   --  -- The attributes for a variable node.
   --  type VariableAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Value : Variants.Pointer;
   --  	  Data_Type : NodeIds.Pointer;
   --  	  Value_Rank : Int32;
   --  	  Array_Dimensions : ListOfUInt32.Pointer;
   --  	  Access_Level : Byte;
   --  	  User_Access_Level : Byte;
   --  	  Minimum_Sampling_Interval : Double;
   --  	  Historizing : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in VariableAttributes) return UInt16 is (SID.VariableAttributes_Id);
   --  function Binary_Size(Item : VariableAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + Variants.Binary_Size(Item.Value) + NodeIds.Binary_Size(Item.Data_Type) + 4 + ListOfUInt32.Binary_Size(Item.Array_Dimensions) + 1 + 1 + 8 + 1 );
   
   --  -- MethodAttributes
   --  -- The attributes for a method node.
   --  type MethodAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Executable : Boolean;
   --  	  User_Executable : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in MethodAttributes) return UInt16 is (SID.MethodAttributes_Id);
   --  function Binary_Size(Item : MethodAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + 1 + 1 );
   
   --  -- ObjectTypeAttributes
   --  -- The attributes for an object type node.
   --  type ObjectTypeAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Is_Abstract : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in ObjectTypeAttributes) return UInt16 is (SID.ObjectTypeAttributes_Id);
   --  function Binary_Size(Item : ObjectTypeAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + 1 );
   
   --  -- VariableTypeAttributes
   --  -- The attributes for a variable type node.
   --  type VariableTypeAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Value : Variants.Pointer;
   --  	  Data_Type : NodeIds.Pointer;
   --  	  Value_Rank : Int32;
   --  	  Array_Dimensions : ListOfUInt32.Pointer;
   --  	  Is_Abstract : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in VariableTypeAttributes) return UInt16 is (SID.VariableTypeAttributes_Id);
   --  function Binary_Size(Item : VariableTypeAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + Variants.Binary_Size(Item.Value) + NodeIds.Binary_Size(Item.Data_Type) + 4 + ListOfUInt32.Binary_Size(Item.Array_Dimensions) + 1 );
   
   --  -- ReferenceTypeAttributes
   --  -- The attributes for a reference type node.
   --  type ReferenceTypeAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Is_Abstract : Boolean;
   --  	  Symmetric : Boolean;
   --  	  Inverse_Name : LocalizedTexts.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ReferenceTypeAttributes) return UInt16 is (SID.ReferenceTypeAttributes_Id);
   --  function Binary_Size(Item : ReferenceTypeAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + 1 + 1 + LocalizedTexts.Binary_Size(Item.Inverse_Name) );
   
   --  -- DataTypeAttributes
   --  -- The attributes for a data type node.
   --  type DataTypeAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Is_Abstract : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in DataTypeAttributes) return UInt16 is (SID.DataTypeAttributes_Id);
   --  function Binary_Size(Item : DataTypeAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + 1 );
   
   --  -- ViewAttributes
   --  -- The attributes for a view node.
   --  type ViewAttributes is new UA_Builtin with record
   --  	  Specified_Attributes : UInt32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  Contains_No_Loops : Boolean;
   --  	  Event_Notifier : Byte;
   --  end record;
   --  function NodeId_Nr(Item : in ViewAttributes) return UInt16 is (SID.ViewAttributes_Id);
   --  function Binary_Size(Item : ViewAttributes) return Int32 is ( 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + 1 + 1 );
   
   --  -- AddNodesItem
   --  -- A request to add a node to the server address space.
   --  type AddNodesItem is new UA_Builtin with record
   --  	  Parent_Node_Id : ExpandedNodeIds.Pointer;
   --  	  Reference_Type_Id : NodeIds.Pointer;
   --  	  Requested_New_Node_Id : ExpandedNodeIds.Pointer;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Node_Attributes : ExtensionObjects.Pointer;
   --  	  Type_Definition : ExpandedNodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in AddNodesItem) return UInt16 is (SID.AddNodesItem_Id);
   --  function Binary_Size(Item : AddNodesItem) return Int32 is ( ExpandedNodeIds.Binary_Size(Item.Parent_Node_Id) + NodeIds.Binary_Size(Item.Reference_Type_Id) + ExpandedNodeIds.Binary_Size(Item.Requested_New_Node_Id) + QualifiedNames.Binary_Size(Item.Browse_Name) + 8
   --  																 + ExtensionObjects.Binary_Size(Item.Node_Attributes) + ExpandedNodeIds.Binary_Size(Item.Type_Definition) );
   
   --  package ListOfAddNodesItem is new Types.Arrays.UA_Builtin_Arrays(AddNodesItem);
   
   --  -- AddNodesResult
   --  -- A result of an add node operation.
   --  type AddNodesResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Added_Node_Id : NodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in AddNodesResult) return UInt16 is (SID.AddNodesResult_Id);
   --  function Binary_Size(Item : AddNodesResult) return Int32 is ( 4 + NodeIds.Binary_Size(Item.Added_Node_Id) );
   
   --  package ListOfAddNodesResult is new Types.Arrays.UA_Builtin_Arrays(AddNodesResult);
   
   --  -- AddNodesRequest
   --  -- Adds one or more nodes to the server address space.
   --  type AddNodesRequest is new Request_Base with record
   --  	  Nodes_To_Add : ListOfAddNodesItem.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in AddNodesRequest) return UInt16 is (SID.AddNodesRequest_Id);
   --  function Binary_Size(Item : AddNodesRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfAddNodesItem.Binary_Size(Item.Nodes_To_Add) );
   
   --  -- AddNodesResponse
   --  -- Adds one or more nodes to the server address space.
   --  type AddNodesResponse is new Response_Base with record
   --  	  Results : ListOfAddNodesResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in AddNodesResponse) return UInt16 is (SID.AddNodesResponse_Id);
   --  function Binary_Size(Item : AddNodesResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfAddNodesResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- AddReferencesItem
   --  -- A request to add a reference to the server address space.
   --  type AddReferencesItem is new UA_Builtin with record
   --  	  Source_Node_Id : NodeIds.Pointer;
   --  	  Reference_Type_Id : NodeIds.Pointer;
   --  	  Is_Forward : Boolean;
   --  	  Target_Server_Uri : String;
   --  	  Target_Node_Id : ExpandedNodeIds.Pointer;
   --  	  Target_Node_Class : NodeClass;
   --  end record;
   --  function NodeId_Nr(Item : in AddReferencesItem) return UInt16 is (SID.AddReferencesItem_Id);
   --  function Binary_Size(Item : AddReferencesItem) return Int32 is ( NodeIds.Binary_Size(Item.Source_Node_Id) + NodeIds.Binary_Size(Item.Reference_Type_Id) + 1 + Binary_Size(Item.Target_Server_Uri) + ExpandedNodeIds.Binary_Size(Item.Target_Node_Id) + 8
   --  																  );
   
   --  package ListOfAddReferencesItem is new Types.Arrays.UA_Builtin_Arrays(AddReferencesItem);
   
   --  -- AddReferencesRequest
   --  -- Adds one or more references to the server address space.
   --  type AddReferencesRequest is new Request_Base with record
   --  	  References_To_Add : ListOfAddReferencesItem.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in AddReferencesRequest) return UInt16 is (SID.AddReferencesRequest_Id);
   --  function Binary_Size(Item : AddReferencesRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfAddReferencesItem.Binary_Size(Item.References_To_Add) );
   
   --  -- AddReferencesResponse
   --  -- Adds one or more references to the server address space.
   --  type AddReferencesResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in AddReferencesResponse) return UInt16 is (SID.AddReferencesResponse_Id);
   --  function Binary_Size(Item : AddReferencesResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- DeleteNodesItem
   --  -- A request to delete a node to the server address space.
   --  type DeleteNodesItem is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Delete_Target_References : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteNodesItem) return UInt16 is (SID.DeleteNodesItem_Id);
   --  function Binary_Size(Item : DeleteNodesItem) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 1 );
   
   --  package ListOfDeleteNodesItem is new Types.Arrays.UA_Builtin_Arrays(DeleteNodesItem);
   
   --  -- DeleteNodesRequest
   --  -- Delete one or more nodes from the server address space.
   --  type DeleteNodesRequest is new Request_Base with record
   --  	  Nodes_To_Delete : ListOfDeleteNodesItem.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteNodesRequest) return UInt16 is (SID.DeleteNodesRequest_Id);
   --  function Binary_Size(Item : DeleteNodesRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfDeleteNodesItem.Binary_Size(Item.Nodes_To_Delete) );
   
   --  -- DeleteNodesResponse
   --  -- Delete one or more nodes from the server address space.
   --  type DeleteNodesResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteNodesResponse) return UInt16 is (SID.DeleteNodesResponse_Id);
   --  function Binary_Size(Item : DeleteNodesResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- DeleteReferencesItem
   --  -- A request to delete a node from the server address space.
   --  type DeleteReferencesItem is new UA_Builtin with record
   --  	  Source_Node_Id : NodeIds.Pointer;
   --  	  Reference_Type_Id : NodeIds.Pointer;
   --  	  Is_Forward : Boolean;
   --  	  Target_Node_Id : ExpandedNodeIds.Pointer;
   --  	  Delete_Bidirectional : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteReferencesItem) return UInt16 is (SID.DeleteReferencesItem_Id);
   --  function Binary_Size(Item : DeleteReferencesItem) return Int32 is ( NodeIds.Binary_Size(Item.Source_Node_Id) + NodeIds.Binary_Size(Item.Reference_Type_Id) + 1 + ExpandedNodeIds.Binary_Size(Item.Target_Node_Id) + 1 );
   
   --  package ListOfDeleteReferencesItem is new Types.Arrays.UA_Builtin_Arrays(DeleteReferencesItem);
   
   --  -- DeleteReferencesRequest
   --  -- Delete one or more references from the server address space.
   --  type DeleteReferencesRequest is new Request_Base with record
   --  	  References_To_Delete : ListOfDeleteReferencesItem.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteReferencesRequest) return UInt16 is (SID.DeleteReferencesRequest_Id);
   --  function Binary_Size(Item : DeleteReferencesRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfDeleteReferencesItem.Binary_Size(Item.References_To_Delete) );
   
   --  -- DeleteReferencesResponse
   --  -- Delete one or more references from the server address space.
   --  type DeleteReferencesResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteReferencesResponse) return UInt16 is (SID.DeleteReferencesResponse_Id);
   --  function Binary_Size(Item : DeleteReferencesResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- AttributeWriteMask
   --  -- Define bits used to indicate which attributes are writeable.
   --  type AttributeWriteMask is (AttributeWriteMask_None,
   --  							   AttributeWriteMask_AccessLevel,
   --  							   AttributeWriteMask_ArrayDimensions,
   --  							   AttributeWriteMask_BrowseName,
   --  							   AttributeWriteMask_ContainsNoLoops,
   --  							   AttributeWriteMask_DataType,
   --  							   AttributeWriteMask_Description,
   --  							   AttributeWriteMask_DisplayName,
   --  							   AttributeWriteMask_EventNotifier,
   --  							   AttributeWriteMask_Executable,
   --  							   AttributeWriteMask_Historizing,
   --  							   AttributeWriteMask_InverseName,
   --  							   AttributeWriteMask_IsAbstract,
   --  							   AttributeWriteMask_MinimumSamplingInterval,
   --  							   AttributeWriteMask_NodeClass,
   --  							   AttributeWriteMask_NodeId,
   --  							   AttributeWriteMask_Symmetric,
   --  							   AttributeWriteMask_UserAccessLevel,
   --  							   AttributeWriteMask_UserExecutable,
   --  							   AttributeWriteMask_UserWriteMask,
   --  							   AttributeWriteMask_ValueRank,
   --  							   AttributeWriteMask_WriteMask,
   --  							   AttributeWriteMask_ValueForVariableType);
   --  for AttributeWriteMask'Size use 32;
   --  for AttributeWriteMask use (AttributeWriteMask_None => 0,
   --  							   AttributeWriteMask_AccessLevel => 1,
   --  							   AttributeWriteMask_ArrayDimensions => 2,
   --  							   AttributeWriteMask_BrowseName => 4,
   --  							   AttributeWriteMask_ContainsNoLoops => 8,
   --  							   AttributeWriteMask_DataType => 16,
   --  							   AttributeWriteMask_Description => 32,
   --  							   AttributeWriteMask_DisplayName => 64,
   --  							   AttributeWriteMask_EventNotifier => 128,
   --  							   AttributeWriteMask_Executable => 256,
   --  							   AttributeWriteMask_Historizing => 512,
   --  							   AttributeWriteMask_InverseName => 1024,
   --  							   AttributeWriteMask_IsAbstract => 2048,
   --  							   AttributeWriteMask_MinimumSamplingInterval => 4096,
   --  							   AttributeWriteMask_NodeClass => 8192,
   --  							   AttributeWriteMask_NodeId => 16384,
   --  							   AttributeWriteMask_Symmetric => 32768,
   --  							   AttributeWriteMask_UserAccessLevel => 65536,
   --  							   AttributeWriteMask_UserExecutable => 131072,
   --  							   AttributeWriteMask_UserWriteMask => 262144,
   --  							   AttributeWriteMask_ValueRank => 524288,
   --  							   AttributeWriteMask_WriteMask => 1048576,
   --  							   AttributeWriteMask_ValueForVariableType => 2097152);
   
   --  -- BrowseResultMask
   --  -- A bit mask which specifies what should be returned in a browse response.
   --  type BrowseResultMask is (BrowseResultMask_None,
   --  							 BrowseResultMask_ReferenceTypeId,
   --  							 BrowseResultMask_IsForward,
   --  							 BrowseResultMask_ReferenceTypeInfo,
   --  							 BrowseResultMask_NodeClass,
   --  							 BrowseResultMask_BrowseName,
   --  							 BrowseResultMask_DisplayName,
   --  							 BrowseResultMask_TypeDefinition,
   --  							 BrowseResultMask_TargetInfo,
   --  							 BrowseResultMask_All);
   --  for BrowseResultMask'Size use 32;
   --  for BrowseResultMask use (BrowseResultMask_None => 0,
   --  							 BrowseResultMask_ReferenceTypeId => 1,
   --  							 BrowseResultMask_IsForward => 2,
   --  							 BrowseResultMask_ReferenceTypeInfo => 3,
   --  							 BrowseResultMask_NodeClass => 4,
   --  							 BrowseResultMask_BrowseName => 8,
   --  							 BrowseResultMask_DisplayName => 16,
   --  							 BrowseResultMask_TypeDefinition => 32,
   --  							 BrowseResultMask_TargetInfo => 60,
   --  							 BrowseResultMask_All => 63);
   
   --  -- RelativePathElement
   --  -- An element in a relative path.
   --  type RelativePathElement is new UA_Builtin with record
   --  	  Reference_Type_Id : NodeIds.Pointer;
   --  	  Is_Inverse : Boolean;
   --  	  Include_Subtypes : Boolean;
   --  	  Target_Name : QualifiedNames.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in RelativePathElement) return UInt16 is (SID.RelativePathElement_Id);
   --  function Binary_Size(Item : RelativePathElement) return Int32 is ( NodeIds.Binary_Size(Item.Reference_Type_Id) + 1 + 1 + QualifiedNames.Binary_Size(Item.Target_Name) );
   
   --  package ListOfRelativePathElement is new Types.Arrays.UA_Builtin_Arrays(RelativePathElement);
   
   --  -- RelativePath
   --  -- A relative path constructed from reference types and browse names.
   --  type RelativePath is new UA_Builtin with record
   --  	  Elements : ListOfRelativePathElement.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in RelativePath) return UInt16 is (SID.RelativePath_Id);
   --  function Binary_Size(Item : RelativePath) return Int32 is ( ListOfRelativePathElement.Binary_Size(Item.Elements) );
   
   --  -- BrowsePath
   --  -- A request to translate a path into a node id.
   --  type BrowsePath is new UA_Builtin with record
   --  	  Starting_Node : NodeIds.Pointer;
   --  	  Relative_Path : RelativePath;
   --  end record;
   --  function NodeId_Nr(Item : in BrowsePath) return UInt16 is (SID.BrowsePath_Id);
   --  function Binary_Size(Item : BrowsePath) return Int32 is ( NodeIds.Binary_Size(Item.Starting_Node) + Binary_Size(Item.Relative_Path) );
   
   --  package ListOfBrowsePath is new Types.Arrays.UA_Builtin_Arrays(BrowsePath);
   
   --  -- BrowsePathTarget
   --  -- The target of the translated path.
   --  type BrowsePathTarget is new UA_Builtin with record
   --  	  Target_Id : ExpandedNodeIds.Pointer;
   --  	  Remaining_Path_Index : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in BrowsePathTarget) return UInt16 is (SID.BrowsePathTarget_Id);
   --  function Binary_Size(Item : BrowsePathTarget) return Int32 is ( ExpandedNodeIds.Binary_Size(Item.Target_Id) + 4 );
   
   --  package ListOfBrowsePathTarget is new Types.Arrays.UA_Builtin_Arrays(BrowsePathTarget);
   
   --  -- BrowsePathResult
   --  -- The result of a translate opearation.
   --  type BrowsePathResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Targets : ListOfBrowsePathTarget.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in BrowsePathResult) return UInt16 is (SID.BrowsePathResult_Id);
   --  function Binary_Size(Item : BrowsePathResult) return Int32 is ( 4 + ListOfBrowsePathTarget.Binary_Size(Item.Targets) );
   
   --  package ListOfBrowsePathResult is new Types.Arrays.UA_Builtin_Arrays(BrowsePathResult);
   
   --  -- TranslateBrowsePathsToNodeIdsRequest
   --  -- Translates one or more paths in the server address space.
   --  type TranslateBrowsePathsToNodeIdsRequest is new Request_Base with record
   --  	  Browse_Paths : ListOfBrowsePath.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in TranslateBrowsePathsToNodeIdsRequest) return UInt16 is (SID.TranslateBrowsePathsToNodeIdsRequest_Id);
   --  function Binary_Size(Item : TranslateBrowsePathsToNodeIdsRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfBrowsePath.Binary_Size(Item.Browse_Paths) );
   
   --  -- TranslateBrowsePathsToNodeIdsResponse
   --  -- Translates one or more paths in the server address space.
   --  type TranslateBrowsePathsToNodeIdsResponse is new Response_Base with record
   --  	  Results : ListOfBrowsePathResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in TranslateBrowsePathsToNodeIdsResponse) return UInt16 is (SID.TranslateBrowsePathsToNodeIdsResponse_Id);
   --  function Binary_Size(Item : TranslateBrowsePathsToNodeIdsResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfBrowsePathResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- RegisterNodesRequest
   --  -- Registers one or more nodes for repeated use within a session.
   --  type RegisterNodesRequest is new Request_Base with record
   --  	  Nodes_To_Register : NodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in RegisterNodesRequest) return UInt16 is (SID.RegisterNodesRequest_Id);
   --  function Binary_Size(Item : RegisterNodesRequest) return Int32 is ( Binary_Size(Item.Request_Header) + NodeIds.Binary_Size(Item.Nodes_To_Register) );
   
   --  -- RegisterNodesResponse
   --  -- Registers one or more nodes for repeated use within a session.
   --  type RegisterNodesResponse is new Response_Base with record
   --  	  Registered_Node_Ids : NodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in RegisterNodesResponse) return UInt16 is (SID.RegisterNodesResponse_Id);
   --  function Binary_Size(Item : RegisterNodesResponse) return Int32 is ( Binary_Size(Item.Response_Header) + NodeIds.Binary_Size(Item.Registered_Node_Ids) );
   
   --  -- UnregisterNodesRequest
   --  -- Unregisters one or more previously registered nodes.
   --  type UnregisterNodesRequest is new Request_Base with record
   --  	  Nodes_To_Unregister : NodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in UnregisterNodesRequest) return UInt16 is (SID.UnregisterNodesRequest_Id);
   --  function Binary_Size(Item : UnregisterNodesRequest) return Int32 is ( Binary_Size(Item.Request_Header) + NodeIds.Binary_Size(Item.Nodes_To_Unregister) );
   
   --  -- UnregisterNodesResponse
   --  -- Unregisters one or more previously registered nodes.
   --  type UnregisterNodesResponse is new Response_Base with  null record;
   --  function NodeId_Nr(Item : in UnregisterNodesResponse) return UInt16 is (SID.UnregisterNodesResponse_Id);
   --  function Binary_Size(Item : UnregisterNodesResponse) return Int32 is ( Binary_Size(Item.Response_Header) );
   
   --  type Counter is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in Counter) return UInt16 is (SID.Counter_Id);
   
   --  type NumericRange is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in NumericRange) return UInt16 is (SID.NumericRange_Id);
   
   --  type Time is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in Time) return UInt16 is (SID.Time_Id);
   
   --  type Date is new Bytes.Pointer with null record;
   --  function NodeId_Nr(Item : in Date) return UInt16 is (SID.Date_Id);
   
   --  -- EndpointConfiguration
   --  type EndpointConfiguration is new UA_Builtin with record
   --  	  Operation_Timeout : Int32;
   --  	  Use_Binary_Encoding : Boolean;
   --  	  Max_String_Length : Int32;
   --  	  Max_Byte_String_Length : Int32;
   --  	  Max_Array_Length : Int32;
   --  	  Max_Message_Size : Int32;
   --  	  Max_Buffer_Size : Int32;
   --  	  Channel_Lifetime : Int32;
   --  	  Security_Token_Lifetime : Int32;
   --  end record;
   --  function NodeId_Nr(Item : in EndpointConfiguration) return UInt16 is (SID.EndpointConfiguration_Id);
   --  function Binary_Size(Item : EndpointConfiguration) return Int32 is ( 4 + 1 + 4 + 4 + 4 + 4 + 4 + 4 + 4 );
   
   --  -- ComplianceLevel
   --  type ComplianceLevel is (ComplianceLevel_Untested,
   --  							ComplianceLevel_Partial,
   --  							ComplianceLevel_SelfTested,
   --  							ComplianceLevel_Certified);
   --  for ComplianceLevel'Size use 32;
   --  for ComplianceLevel use (ComplianceLevel_Untested => 0,
   --  							ComplianceLevel_Partial => 1,
   --  							ComplianceLevel_SelfTested => 2,
   --  							ComplianceLevel_Certified => 3);
   
   --  -- SupportedProfile
   --  type SupportedProfile is new UA_Builtin with record
   --  	  Organization_Uri : String;
   --  	  Profile_Id : String;
   --  	  Compliance_Tool : String;
   --  	  Compliance_Date : DateTime;
   --  	  Compliance_Level : ComplianceLevel;
   --  	  Unsupported_Unit_Ids : ListOfString.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SupportedProfile) return UInt16 is (SID.SupportedProfile_Id);
   --  function Binary_Size(Item : SupportedProfile) return Int32 is ( Binary_Size(Item.Organization_Uri) + Binary_Size(Item.Profile_Id) + Binary_Size(Item.Compliance_Tool) + 8 + 8
   --  																	 + ListOfString.Binary_Size(Item.Unsupported_Unit_Ids) );
   
   --  package ListOfSupportedProfile is new Types.Arrays.UA_Builtin_Arrays(SupportedProfile);
   
   --  -- SoftwareCertificate
   --  type SoftwareCertificate is new UA_Builtin with record
   --  	  Product_Name : String;
   --  	  Product_Uri : String;
   --  	  Vendor_Name : String;
   --  	  Vendor_Product_Certificate : ByteString;
   --  	  Software_Version : String;
   --  	  Build_Number : String;
   --  	  Build_Date : DateTime;
   --  	  Issued_By : String;
   --  	  Issue_Date : DateTime;
   --  	  Supported_Profiles : ListOfSupportedProfile.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SoftwareCertificate) return UInt16 is (SID.SoftwareCertificate_Id);
   --  function Binary_Size(Item : SoftwareCertificate) return Int32 is ( Binary_Size(Item.Product_Name) + Binary_Size(Item.Product_Uri) + Binary_Size(Item.Vendor_Name) + Binary_Size(Item.Vendor_Product_Certificate) + Binary_Size(Item.Software_Version) + Binary_Size(Item.Build_Number) + 8 + Binary_Size(Item.Issued_By) + 8 + ListOfSupportedProfile.Binary_Size(Item.Supported_Profiles) );
   
   --  -- QueryDataDescription
   --  type QueryDataDescription is new UA_Builtin with record
   --  	  Relative_Path : RelativePath;
   --  	  Attribute_Id : UInt32;
   --  	  Index_Range : String;
   --  end record;
   --  function NodeId_Nr(Item : in QueryDataDescription) return UInt16 is (SID.QueryDataDescription_Id);
   --  function Binary_Size(Item : QueryDataDescription) return Int32 is ( Binary_Size(Item.Relative_Path) + 4 + Binary_Size(Item.Index_Range) );
   
   --  package ListOfQueryDataDescription is new Types.Arrays.UA_Builtin_Arrays(QueryDataDescription);
   
   --  -- NodeTypeDescription
   --  type NodeTypeDescription is new UA_Builtin with record
   --  	  Type_Definition_Node : ExpandedNodeIds.Pointer;
   --  	  Include_Sub_Types : Boolean;
   --  	  Data_To_Return : ListOfQueryDataDescription.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in NodeTypeDescription) return UInt16 is (SID.NodeTypeDescription_Id);
   --  function Binary_Size(Item : NodeTypeDescription) return Int32 is ( ExpandedNodeIds.Binary_Size(Item.Type_Definition_Node) + 1 + ListOfQueryDataDescription.Binary_Size(Item.Data_To_Return) );
   
   --  package ListOfNodeTypeDescription is new Types.Arrays.UA_Builtin_Arrays(NodeTypeDescription);
   
   --  -- FilterOperator
   --  type FilterOperator is (FilterOperator_Equals,
   --  						   FilterOperator_IsNull,
   --  						   FilterOperator_GreaterThan,
   --  						   FilterOperator_LessThan,
   --  						   FilterOperator_GreaterThanOrEqual,
   --  						   FilterOperator_LessThanOrEqual,
   --  						   FilterOperator_Like,
   --  						   FilterOperator_Not,
   --  						   FilterOperator_Between,
   --  						   FilterOperator_InList,
   --  						   FilterOperator_And,
   --  						   FilterOperator_Or,
   --  						   FilterOperator_Cast,
   --  						   FilterOperator_InView,
   --  						   FilterOperator_OfType,
   --  						   FilterOperator_RelatedTo,
   --  						   FilterOperator_BitwiseAnd,
   --  						   FilterOperator_BitwiseOr);
   --  for FilterOperator'Size use 32;
   --  for FilterOperator use (FilterOperator_Equals => 0,
   --  						   FilterOperator_IsNull => 1,
   --  						   FilterOperator_GreaterThan => 2,
   --  						   FilterOperator_LessThan => 3,
   --  						   FilterOperator_GreaterThanOrEqual => 4,
   --  						   FilterOperator_LessThanOrEqual => 5,
   --  						   FilterOperator_Like => 6,
   --  						   FilterOperator_Not => 7,
   --  						   FilterOperator_Between => 8,
   --  						   FilterOperator_InList => 9,
   --  						   FilterOperator_And => 10,
   --  						   FilterOperator_Or => 11,
   --  						   FilterOperator_Cast => 12,
   --  						   FilterOperator_InView => 13,
   --  						   FilterOperator_OfType => 14,
   --  						   FilterOperator_RelatedTo => 15,
   --  						   FilterOperator_BitwiseAnd => 16,
   --  						   FilterOperator_BitwiseOr => 17);
   
   --  -- QueryDataSet
   --  type QueryDataSet is new UA_Builtin with record
   --  	  Node_Id : ExpandedNodeIds.Pointer;
   --  	  Type_Definition_Node : ExpandedNodeIds.Pointer;
   --  	  Values : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in QueryDataSet) return UInt16 is (SID.QueryDataSet_Id);
   --  function Binary_Size(Item : QueryDataSet) return Int32 is ( ExpandedNodeIds.Binary_Size(Item.Node_Id) + ExpandedNodeIds.Binary_Size(Item.Type_Definition_Node) + Variants.Binary_Size(Item.Values) );
   
   --  package ListOfQueryDataSet is new Types.Arrays.UA_Builtin_Arrays(QueryDataSet);
   
   --  -- NodeReference
   --  type NodeReference is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Reference_Type_Id : NodeIds.Pointer;
   --  	  Is_Forward : Boolean;
   --  	  Referenced_Node_Ids : NodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in NodeReference) return UInt16 is (SID.NodeReference_Id);
   --  function Binary_Size(Item : NodeReference) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + NodeIds.Binary_Size(Item.Reference_Type_Id) + 1 + NodeIds.Binary_Size(Item.Referenced_Node_Ids) );
   
   --  -- ContentFilterElement
   --  type ContentFilterElement is new UA_Builtin with record
   --  	  Filter_Operator : FilterOperator;
   --  	  Filter_Operands : ExtensionObjects.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ContentFilterElement) return UInt16 is (SID.ContentFilterElement_Id);
   --  function Binary_Size(Item : ContentFilterElement) return Int32 is ( 8
   --  																		 + ExtensionObjects.Binary_Size(Item.Filter_Operands) );
   
   --  package ListOfContentFilterElement is new Types.Arrays.UA_Builtin_Arrays(ContentFilterElement);
   
   --  -- ContentFilter
   --  type ContentFilter is new UA_Builtin with record
   --  	  Elements : ListOfContentFilterElement.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ContentFilter) return UInt16 is (SID.ContentFilter_Id);
   --  function Binary_Size(Item : ContentFilter) return Int32 is ( ListOfContentFilterElement.Binary_Size(Item.Elements) );
   
   --  -- FilterOperand
   --  type FilterOperand is new UA_Builtin with  null record;
   --  function NodeId_Nr(Item : in FilterOperand) return UInt16 is (SID.FilterOperand_Id);
   --  function Binary_Size(Item : FilterOperand) return Int32 is ( 0 );
   
   --  -- ElementOperand
   --  type ElementOperand is new UA_Builtin with record
   --  	  Index : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in ElementOperand) return UInt16 is (SID.ElementOperand_Id);
   --  function Binary_Size(Item : ElementOperand) return Int32 is ( 4 );
   
   --  -- LiteralOperand
   --  type LiteralOperand is new UA_Builtin with record
   --  	  Value : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in LiteralOperand) return UInt16 is (SID.LiteralOperand_Id);
   --  function Binary_Size(Item : LiteralOperand) return Int32 is ( Variants.Binary_Size(Item.Value) );
   
   --  -- AttributeOperand
   --  type AttributeOperand is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Alias : String;
   --  	  Browse_Path : RelativePath;
   --  	  Attribute_Id : UInt32;
   --  	  Index_Range : String;
   --  end record;
   --  function NodeId_Nr(Item : in AttributeOperand) return UInt16 is (SID.AttributeOperand_Id);
   --  function Binary_Size(Item : AttributeOperand) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + Binary_Size(Item.Alias) + Binary_Size(Item.Browse_Path) + 4 + Binary_Size(Item.Index_Range) );
   
   --  -- SimpleAttributeOperand
   --  type SimpleAttributeOperand is new UA_Builtin with record
   --  	  Type_Definition_Id : NodeIds.Pointer;
   --  	  Browse_Path : QualifiedNames.Pointer;
   --  	  Attribute_Id : UInt32;
   --  	  Index_Range : String;
   --  end record;
   --  function NodeId_Nr(Item : in SimpleAttributeOperand) return UInt16 is (SID.SimpleAttributeOperand_Id);
   --  function Binary_Size(Item : SimpleAttributeOperand) return Int32 is ( NodeIds.Binary_Size(Item.Type_Definition_Id) + QualifiedNames.Binary_Size(Item.Browse_Path) + 4 + Binary_Size(Item.Index_Range) );
   
   --  package ListOfSimpleAttributeOperand is new Types.Arrays.UA_Builtin_Arrays(SimpleAttributeOperand);
   
   --  -- ContentFilterElementResult
   --  type ContentFilterElementResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Operand_Status_Codes : ListOfStatusCode.Pointer;
   --  	  Operand_Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ContentFilterElementResult) return UInt16 is (SID.ContentFilterElementResult_Id);
   --  function Binary_Size(Item : ContentFilterElementResult) return Int32 is ( 4 + ListOfStatusCode.Binary_Size(Item.Operand_Status_Codes) + DiagnosticInfos.Binary_Size(Item.Operand_Diagnostic_Infos) );
   
   --  package ListOfContentFilterElementResult is new Types.Arrays.UA_Builtin_Arrays(ContentFilterElementResult);
   
   --  -- ContentFilterResult
   --  type ContentFilterResult is new UA_Builtin with record
   --  	  Element_Results : ListOfContentFilterElementResult.Pointer;
   --  	  Element_Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ContentFilterResult) return UInt16 is (SID.ContentFilterResult_Id);
   --  function Binary_Size(Item : ContentFilterResult) return Int32 is ( ListOfContentFilterElementResult.Binary_Size(Item.Element_Results) + DiagnosticInfos.Binary_Size(Item.Element_Diagnostic_Infos) );
   
   --  -- ParsingResult
   --  type ParsingResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Data_Status_Codes : ListOfStatusCode.Pointer;
   --  	  Data_Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ParsingResult) return UInt16 is (SID.ParsingResult_Id);
   --  function Binary_Size(Item : ParsingResult) return Int32 is ( 4 + ListOfStatusCode.Binary_Size(Item.Data_Status_Codes) + DiagnosticInfos.Binary_Size(Item.Data_Diagnostic_Infos) );
   
   --  package ListOfParsingResult is new Types.Arrays.UA_Builtin_Arrays(ParsingResult);
   
   --  -- QueryFirstRequest
   --  type QueryFirstRequest is new Request_Base with record
   --  	  View : ViewDescription;
   --  	  Node_Types : ListOfNodeTypeDescription.Pointer;
   --  	  Filter : ContentFilter;
   --  	  Max_Data_Sets_To_Return : UInt32;
   --  	  Max_References_To_Return : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in QueryFirstRequest) return UInt16 is (SID.QueryFirstRequest_Id);
   --  function Binary_Size(Item : QueryFirstRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.View) + ListOfNodeTypeDescription.Binary_Size(Item.Node_Types) + Binary_Size(Item.Filter) + 4 + 4 );
   
   --  -- QueryFirstResponse
   --  type QueryFirstResponse is new Response_Base with record
   --  	  Query_Data_Sets : ListOfQueryDataSet.Pointer;
   --  	  Continuation_Point : ByteString;
   --  	  Parsing_Results : ListOfParsingResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  	  Filter_Result : ContentFilterResult;
   --  end record;
   --  function NodeId_Nr(Item : in QueryFirstResponse) return UInt16 is (SID.QueryFirstResponse_Id);
   --  function Binary_Size(Item : QueryFirstResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfQueryDataSet.Binary_Size(Item.Query_Data_Sets) + Binary_Size(Item.Continuation_Point) + ListOfParsingResult.Binary_Size(Item.Parsing_Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) + Binary_Size(Item.Filter_Result) );
   
   --  -- QueryNextRequest
   --  type QueryNextRequest is new Request_Base with record
   --  	  Release_Continuation_Point : Boolean;
   --  	  Continuation_Point : ByteString;
   --  end record;
   --  function NodeId_Nr(Item : in QueryNextRequest) return UInt16 is (SID.QueryNextRequest_Id);
   --  function Binary_Size(Item : QueryNextRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 1 + Binary_Size(Item.Continuation_Point) );
   
   --  -- QueryNextResponse
   --  type QueryNextResponse is new Response_Base with record
   --  	  Query_Data_Sets : ListOfQueryDataSet.Pointer;
   --  	  Revised_Continuation_Point : ByteString;
   --  end record;
   --  function NodeId_Nr(Item : in QueryNextResponse) return UInt16 is (SID.QueryNextResponse_Id);
   --  function Binary_Size(Item : QueryNextResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfQueryDataSet.Binary_Size(Item.Query_Data_Sets) + Binary_Size(Item.Revised_Continuation_Point) );
   
   --  -- HistoryReadValueId
   --  type HistoryReadValueId is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Index_Range : String;
   --  	  Data_Encoding : QualifiedNames.Pointer;
   --  	  Continuation_Point : ByteString;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryReadValueId) return UInt16 is (SID.HistoryReadValueId_Id);
   --  function Binary_Size(Item : HistoryReadValueId) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + Binary_Size(Item.Index_Range) + QualifiedNames.Binary_Size(Item.Data_Encoding) + Binary_Size(Item.Continuation_Point) );
   
   --  package ListOfHistoryReadValueId is new Types.Arrays.UA_Builtin_Arrays(HistoryReadValueId);
   
   --  -- HistoryReadResult
   --  type HistoryReadResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Continuation_Point : ByteString;
   --  	  History_Data : ExtensionObjects.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryReadResult) return UInt16 is (SID.HistoryReadResult_Id);
   --  function Binary_Size(Item : HistoryReadResult) return Int32 is ( 4 + Binary_Size(Item.Continuation_Point) + ExtensionObjects.Binary_Size(Item.History_Data) );
   
   --  package ListOfHistoryReadResult is new Types.Arrays.UA_Builtin_Arrays(HistoryReadResult);
   
   --  -- HistoryReadDetails
   --  type HistoryReadDetails is new UA_Builtin with  null record;
   --  function NodeId_Nr(Item : in HistoryReadDetails) return UInt16 is (SID.HistoryReadDetails_Id);
   --  function Binary_Size(Item : HistoryReadDetails) return Int32 is ( 0 );
   
   --  -- ReadRawModifiedDetails
   --  type ReadRawModifiedDetails is new UA_Builtin with record
   --  	  Is_Read_Modified : Boolean;
   --  	  Start_Time : DateTime;
   --  	  End_Time : DateTime;
   --  	  Num_Values_Per_Node : UInt32;
   --  	  Return_Bounds : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in ReadRawModifiedDetails) return UInt16 is (SID.ReadRawModifiedDetails_Id);
   --  function Binary_Size(Item : ReadRawModifiedDetails) return Int32 is ( 1 + 8 + 8 + 4 + 1 );
   
   --  -- ReadAtTimeDetails
   --  type ReadAtTimeDetails is new UA_Builtin with record
   --  	  Req_Times : ListOfDateTime.Pointer;
   --  	  Use_Simple_Bounds : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in ReadAtTimeDetails) return UInt16 is (SID.ReadAtTimeDetails_Id);
   --  function Binary_Size(Item : ReadAtTimeDetails) return Int32 is ( ListOfDateTime.Binary_Size(Item.Req_Times) + 1 );
   
   --  -- HistoryData
   --  type HistoryData is new UA_Builtin with record
   --  	  Data_Values : DataValues.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryData) return UInt16 is (SID.HistoryData_Id);
   --  function Binary_Size(Item : HistoryData) return Int32 is ( DataValues.Binary_Size(Item.Data_Values) );
   
   --  -- HistoryReadRequest
   --  type HistoryReadRequest is new Request_Base with record
   --  	  History_Read_Details : ExtensionObjects.Pointer;
   --  	  Timestamps_To_Return : TimestampsToReturn;
   --  	  Release_Continuation_Points : Boolean;
   --  	  Nodes_To_Read : ListOfHistoryReadValueId.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryReadRequest) return UInt16 is (SID.HistoryReadRequest_Id);
   --  function Binary_Size(Item : HistoryReadRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ExtensionObjects.Binary_Size(Item.History_Read_Details) + 8
   --  																	   + 1 + ListOfHistoryReadValueId.Binary_Size(Item.Nodes_To_Read) );
   
   --  -- HistoryReadResponse
   --  type HistoryReadResponse is new Response_Base with record
   --  	  Results : ListOfHistoryReadResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryReadResponse) return UInt16 is (SID.HistoryReadResponse_Id);
   --  function Binary_Size(Item : HistoryReadResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfHistoryReadResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- WriteValue
   --  type WriteValue is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Attribute_Id : UInt32;
   --  	  Index_Range : String;
   --  	  Value : DataValues.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in WriteValue) return UInt16 is (SID.WriteValue_Id);
   --  function Binary_Size(Item : WriteValue) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 4 + Binary_Size(Item.Index_Range) + DataValues.Binary_Size(Item.Value) );
   
   --  package ListOfWriteValue is new Types.Arrays.UA_Builtin_Arrays(WriteValue);
   
   --  -- WriteRequest
   --  type WriteRequest is new Request_Base with record
   --  	  Nodes_To_Write : ListOfWriteValue.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in WriteRequest) return UInt16 is (SID.WriteRequest_Id);
   --  function Binary_Size(Item : WriteRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfWriteValue.Binary_Size(Item.Nodes_To_Write) );
   
   --  -- WriteResponse
   --  type WriteResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in WriteResponse) return UInt16 is (SID.WriteResponse_Id);
   --  function Binary_Size(Item : WriteResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- HistoryUpdateDetails
   --  type HistoryUpdateDetails is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryUpdateDetails) return UInt16 is (SID.HistoryUpdateDetails_Id);
   --  function Binary_Size(Item : HistoryUpdateDetails) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) );
   
   --  -- HistoryUpdateType
   --  type HistoryUpdateType is (HistoryUpdateType_Insert,
   --  							  HistoryUpdateType_Replace,
   --  							  HistoryUpdateType_Update,
   --  							  HistoryUpdateType_Delete);
   --  for HistoryUpdateType'Size use 32;
   --  for HistoryUpdateType use (HistoryUpdateType_Insert => 1,
   --  							  HistoryUpdateType_Replace => 2,
   --  							  HistoryUpdateType_Update => 3,
   --  							  HistoryUpdateType_Delete => 4);
   
   --  -- PerformUpdateType
   --  type PerformUpdateType is (PerformUpdateType_Insert,
   --  							  PerformUpdateType_Replace,
   --  							  PerformUpdateType_Update,
   --  							  PerformUpdateType_Remove);
   --  for PerformUpdateType'Size use 32;
   --  for PerformUpdateType use (PerformUpdateType_Insert => 1,
   --  							  PerformUpdateType_Replace => 2,
   --  							  PerformUpdateType_Update => 3,
   --  							  PerformUpdateType_Remove => 4);
   
   --  -- UpdateDataDetails
   --  type UpdateDataDetails is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Perform_Insert_Replace : PerformUpdateType;
   --  	  Update_Values : DataValues.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in UpdateDataDetails) return UInt16 is (SID.UpdateDataDetails_Id);
   --  function Binary_Size(Item : UpdateDataDetails) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																	  + DataValues.Binary_Size(Item.Update_Values) );
   
   --  -- UpdateStructureDataDetails
   --  type UpdateStructureDataDetails is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Perform_Insert_Replace : PerformUpdateType;
   --  	  Update_Values : DataValues.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in UpdateStructureDataDetails) return UInt16 is (SID.UpdateStructureDataDetails_Id);
   --  function Binary_Size(Item : UpdateStructureDataDetails) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																			   + DataValues.Binary_Size(Item.Update_Values) );
   
   --  -- DeleteRawModifiedDetails
   --  type DeleteRawModifiedDetails is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Is_Delete_Modified : Boolean;
   --  	  Start_Time : DateTime;
   --  	  End_Time : DateTime;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteRawModifiedDetails) return UInt16 is (SID.DeleteRawModifiedDetails_Id);
   --  function Binary_Size(Item : DeleteRawModifiedDetails) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 1 + 8 + 8 );
   
   --  -- DeleteAtTimeDetails
   --  type DeleteAtTimeDetails is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Req_Times : ListOfDateTime.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteAtTimeDetails) return UInt16 is (SID.DeleteAtTimeDetails_Id);
   --  function Binary_Size(Item : DeleteAtTimeDetails) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + ListOfDateTime.Binary_Size(Item.Req_Times) );
   
   --  -- DeleteEventDetails
   --  type DeleteEventDetails is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Event_Ids : ListOfByteString.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteEventDetails) return UInt16 is (SID.DeleteEventDetails_Id);
   --  function Binary_Size(Item : DeleteEventDetails) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + ListOfByteString.Binary_Size(Item.Event_Ids) );
   
   --  -- HistoryUpdateResult
   --  type HistoryUpdateResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Operation_Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryUpdateResult) return UInt16 is (SID.HistoryUpdateResult_Id);
   --  function Binary_Size(Item : HistoryUpdateResult) return Int32 is ( 4 + ListOfStatusCode.Binary_Size(Item.Operation_Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  package ListOfHistoryUpdateResult is new Types.Arrays.UA_Builtin_Arrays(HistoryUpdateResult);
   
   --  -- HistoryUpdateRequest
   --  type HistoryUpdateRequest is new Request_Base with record
   --  	  History_Update_Details : ExtensionObjects.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryUpdateRequest) return UInt16 is (SID.HistoryUpdateRequest_Id);
   --  function Binary_Size(Item : HistoryUpdateRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ExtensionObjects.Binary_Size(Item.History_Update_Details) );
   
   --  -- HistoryUpdateResponse
   --  type HistoryUpdateResponse is new Response_Base with record
   --  	  Results : ListOfHistoryUpdateResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryUpdateResponse) return UInt16 is (SID.HistoryUpdateResponse_Id);
   --  function Binary_Size(Item : HistoryUpdateResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfHistoryUpdateResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- CallMethodRequest
   --  type CallMethodRequest is new Request_Base with record
   --  	  Object_Id : NodeIds.Pointer;
   --  	  Method_Id : NodeIds.Pointer;
   --  	  Input_Arguments : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in CallMethodRequest) return UInt16 is (SID.CallMethodRequest_Id);
   --  function Binary_Size(Item : CallMethodRequest) return Int32 is ( Binary_Size(Item.Request_Header) + NodeIds.Binary_Size(Item.Object_Id) + NodeIds.Binary_Size(Item.Method_Id) + Variants.Binary_Size(Item.Input_Arguments) );
   
   --  package ListOfCallMethodRequest is new Types.Arrays.UA_Builtin_Arrays(CallMethodRequest);
   
   --  -- CallMethodResult
   --  type CallMethodResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Input_Argument_Results : ListOfStatusCode.Pointer;
   --  	  Input_Argument_Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  	  Output_Arguments : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in CallMethodResult) return UInt16 is (SID.CallMethodResult_Id);
   --  function Binary_Size(Item : CallMethodResult) return Int32 is ( 4 + ListOfStatusCode.Binary_Size(Item.Input_Argument_Results) + DiagnosticInfos.Binary_Size(Item.Input_Argument_Diagnostic_Infos) + Variants.Binary_Size(Item.Output_Arguments) );
   
   --  package ListOfCallMethodResult is new Types.Arrays.UA_Builtin_Arrays(CallMethodResult);
   
   --  -- CallRequest
   --  type CallRequest is new Request_Base with record
   --  	  Methods_To_Call : ListOfCallMethodRequest.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in CallRequest) return UInt16 is (SID.CallRequest_Id);
   --  function Binary_Size(Item : CallRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfCallMethodRequest.Binary_Size(Item.Methods_To_Call) );
   
   --  -- CallResponse
   --  type CallResponse is new Response_Base with record
   --  	  Results : ListOfCallMethodResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in CallResponse) return UInt16 is (SID.CallResponse_Id);
   --  function Binary_Size(Item : CallResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfCallMethodResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- MonitoringMode
   --  type MonitoringMode is (MonitoringMode_Disabled,
   --  						   MonitoringMode_Sampling,
   --  						   MonitoringMode_Reporting);
   --  for MonitoringMode'Size use 32;
   --  for MonitoringMode use (MonitoringMode_Disabled => 0,
   --  						   MonitoringMode_Sampling => 1,
   --  						   MonitoringMode_Reporting => 2);
   
   --  -- DataChangeTrigger
   --  type DataChangeTrigger is (DataChangeTrigger_Status,
   --  							  DataChangeTrigger_StatusValue,
   --  							  DataChangeTrigger_StatusValueTimestamp);
   --  for DataChangeTrigger'Size use 32;
   --  for DataChangeTrigger use (DataChangeTrigger_Status => 0,
   --  							  DataChangeTrigger_StatusValue => 1,
   --  							  DataChangeTrigger_StatusValueTimestamp => 2);
   
   --  -- DeadbandType
   --  type DeadbandType is (DeadbandType_None,
   --  						 DeadbandType_Absolute,
   --  						 DeadbandType_Percent);
   --  for DeadbandType'Size use 32;
   --  for DeadbandType use (DeadbandType_None => 0,
   --  						 DeadbandType_Absolute => 1,
   --  						 DeadbandType_Percent => 2);
   
   --  -- MonitoringFilter
   --  type MonitoringFilter is new UA_Builtin with  null record;
   --  function NodeId_Nr(Item : in MonitoringFilter) return UInt16 is (SID.MonitoringFilter_Id);
   --  function Binary_Size(Item : MonitoringFilter) return Int32 is ( 0 );
   
   --  -- DataChangeFilter
   --  type DataChangeFilter is new UA_Builtin with record
   --  	  Trigger : DataChangeTrigger;
   --  	  Deadband_Type : UInt32;
   --  	  Deadband_Value : Double;
   --  end record;
   --  function NodeId_Nr(Item : in DataChangeFilter) return UInt16 is (SID.DataChangeFilter_Id);
   --  function Binary_Size(Item : DataChangeFilter) return Int32 is ( 8
   --  																	 + 4 + 8 );
   
   --  -- EventFilter
   --  type EventFilter is new UA_Builtin with record
   --  	  Select_Clauses : ListOfSimpleAttributeOperand.Pointer;
   --  	  Where_Clause : ContentFilter;
   --  end record;
   --  function NodeId_Nr(Item : in EventFilter) return UInt16 is (SID.EventFilter_Id);
   --  function Binary_Size(Item : EventFilter) return Int32 is ( ListOfSimpleAttributeOperand.Binary_Size(Item.Select_Clauses) + Binary_Size(Item.Where_Clause) );
   
   --  -- AggregateConfiguration
   --  type AggregateConfiguration is new UA_Builtin with record
   --  	  Use_Server_Capabilities_Defaults : Boolean;
   --  	  Treat_Uncertain_As_Bad : Boolean;
   --  	  Percent_Data_Bad : Byte;
   --  	  Percent_Data_Good : Byte;
   --  	  Use_Sloped_Extrapolation : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in AggregateConfiguration) return UInt16 is (SID.AggregateConfiguration_Id);
   --  function Binary_Size(Item : AggregateConfiguration) return Int32 is ( 1 + 1 + 1 + 1 + 1 );
   
   --  -- AggregateFilter
   --  type AggregateFilter is new UA_Builtin with record
   --  	  Start_Time : DateTime;
   --  	  Aggregate_Type : NodeIds.Pointer;
   --  	  Processing_Interval : Double;
   --  	  Aggregate_Configuration : AggregateConfiguration;
   --  end record;
   --  function NodeId_Nr(Item : in AggregateFilter) return UInt16 is (SID.AggregateFilter_Id);
   --  function Binary_Size(Item : AggregateFilter) return Int32 is ( 8 + NodeIds.Binary_Size(Item.Aggregate_Type) + 8 + Binary_Size(Item.Aggregate_Configuration) );
   
   --  -- MonitoringFilterResult
   --  type MonitoringFilterResult is new UA_Builtin with  null record;
   --  function NodeId_Nr(Item : in MonitoringFilterResult) return UInt16 is (SID.MonitoringFilterResult_Id);
   --  function Binary_Size(Item : MonitoringFilterResult) return Int32 is ( 0 );
   
   --  -- EventFilterResult
   --  type EventFilterResult is new UA_Builtin with record
   --  	  Select_Clause_Results : ListOfStatusCode.Pointer;
   --  	  Select_Clause_Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  	  Where_Clause_Result : ContentFilterResult;
   --  end record;
   --  function NodeId_Nr(Item : in EventFilterResult) return UInt16 is (SID.EventFilterResult_Id);
   --  function Binary_Size(Item : EventFilterResult) return Int32 is ( ListOfStatusCode.Binary_Size(Item.Select_Clause_Results) + DiagnosticInfos.Binary_Size(Item.Select_Clause_Diagnostic_Infos) + Binary_Size(Item.Where_Clause_Result) );
   
   --  -- AggregateFilterResult
   --  type AggregateFilterResult is new UA_Builtin with record
   --  	  Revised_Start_Time : DateTime;
   --  	  Revised_Processing_Interval : Double;
   --  	  Revised_Aggregate_Configuration : AggregateConfiguration;
   --  end record;
   --  function NodeId_Nr(Item : in AggregateFilterResult) return UInt16 is (SID.AggregateFilterResult_Id);
   --  function Binary_Size(Item : AggregateFilterResult) return Int32 is ( 8 + 8 + Binary_Size(Item.Revised_Aggregate_Configuration) );
   
   --  -- MonitoringParameters
   --  type MonitoringParameters is new UA_Builtin with record
   --  	  Client_Handle : UInt32;
   --  	  Sampling_Interval : Double;
   --  	  Filter : ExtensionObjects.Pointer;
   --  	  Queue_Size : UInt32;
   --  	  Discard_Oldest : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in MonitoringParameters) return UInt16 is (SID.MonitoringParameters_Id);
   --  function Binary_Size(Item : MonitoringParameters) return Int32 is ( 4 + 8 + ExtensionObjects.Binary_Size(Item.Filter) + 4 + 1 );
   
   --  -- MonitoredItemCreateRequest
   --  type MonitoredItemCreateRequest is new Request_Base with record
   --  	  Item_To_Monitor : ReadValueId;
   --  	  Monitoring_Mode : MonitoringMode;
   --  	  Requested_Parameters : MonitoringParameters;
   --  end record;
   --  function NodeId_Nr(Item : in MonitoredItemCreateRequest) return UInt16 is (SID.MonitoredItemCreateRequest_Id);
   --  function Binary_Size(Item : MonitoredItemCreateRequest) return Int32 is ( Binary_Size(Item.Request_Header) + Binary_Size(Item.Item_To_Monitor) + 8
   --  																			   + Binary_Size(Item.Requested_Parameters) );
   
   --  package ListOfMonitoredItemCreateRequest is new Types.Arrays.UA_Builtin_Arrays(MonitoredItemCreateRequest);
   
   --  -- MonitoredItemCreateResult
   --  type MonitoredItemCreateResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Monitored_Item_Id : UInt32;
   --  	  Revised_Sampling_Interval : Double;
   --  	  Revised_Queue_Size : UInt32;
   --  	  Filter_Result : ExtensionObjects.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in MonitoredItemCreateResult) return UInt16 is (SID.MonitoredItemCreateResult_Id);
   --  function Binary_Size(Item : MonitoredItemCreateResult) return Int32 is ( 4 + 4 + 8 + 4 + ExtensionObjects.Binary_Size(Item.Filter_Result) );
   
   --  package ListOfMonitoredItemCreateResult is new Types.Arrays.UA_Builtin_Arrays(MonitoredItemCreateResult);
   
   --  -- CreateMonitoredItemsRequest
   --  type CreateMonitoredItemsRequest is new Request_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Timestamps_To_Return : TimestampsToReturn;
   --  	  Items_To_Create : ListOfMonitoredItemCreateRequest.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in CreateMonitoredItemsRequest) return UInt16 is (SID.CreateMonitoredItemsRequest_Id);
   --  function Binary_Size(Item : CreateMonitoredItemsRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 8
   --  																				+ ListOfMonitoredItemCreateRequest.Binary_Size(Item.Items_To_Create) );
   
   --  -- CreateMonitoredItemsResponse
   --  type CreateMonitoredItemsResponse is new Response_Base with record
   --  	  Results : ListOfMonitoredItemCreateResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in CreateMonitoredItemsResponse) return UInt16 is (SID.CreateMonitoredItemsResponse_Id);
   --  function Binary_Size(Item : CreateMonitoredItemsResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfMonitoredItemCreateResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- MonitoredItemModifyRequest
   --  type MonitoredItemModifyRequest is new Request_Base with record
   --  	  Monitored_Item_Id : UInt32;
   --  	  Requested_Parameters : MonitoringParameters;
   --  end record;
   --  function NodeId_Nr(Item : in MonitoredItemModifyRequest) return UInt16 is (SID.MonitoredItemModifyRequest_Id);
   --  function Binary_Size(Item : MonitoredItemModifyRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + Binary_Size(Item.Requested_Parameters) );
   
   --  package ListOfMonitoredItemModifyRequest is new Types.Arrays.UA_Builtin_Arrays(MonitoredItemModifyRequest);
   
   --  -- MonitoredItemModifyResult
   --  type MonitoredItemModifyResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Revised_Sampling_Interval : Double;
   --  	  Revised_Queue_Size : UInt32;
   --  	  Filter_Result : ExtensionObjects.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in MonitoredItemModifyResult) return UInt16 is (SID.MonitoredItemModifyResult_Id);
   --  function Binary_Size(Item : MonitoredItemModifyResult) return Int32 is ( 4 + 8 + 4 + ExtensionObjects.Binary_Size(Item.Filter_Result) );
   
   --  package ListOfMonitoredItemModifyResult is new Types.Arrays.UA_Builtin_Arrays(MonitoredItemModifyResult);
   
   --  -- ModifyMonitoredItemsRequest
   --  type ModifyMonitoredItemsRequest is new Request_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Timestamps_To_Return : TimestampsToReturn;
   --  	  Items_To_Modify : ListOfMonitoredItemModifyRequest.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ModifyMonitoredItemsRequest) return UInt16 is (SID.ModifyMonitoredItemsRequest_Id);
   --  function Binary_Size(Item : ModifyMonitoredItemsRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 8
   --  																				+ ListOfMonitoredItemModifyRequest.Binary_Size(Item.Items_To_Modify) );
   
   --  -- ModifyMonitoredItemsResponse
   --  type ModifyMonitoredItemsResponse is new Response_Base with record
   --  	  Results : ListOfMonitoredItemModifyResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ModifyMonitoredItemsResponse) return UInt16 is (SID.ModifyMonitoredItemsResponse_Id);
   --  function Binary_Size(Item : ModifyMonitoredItemsResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfMonitoredItemModifyResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- SetMonitoringModeRequest
   --  type SetMonitoringModeRequest is new Request_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Monitoring_Mode : MonitoringMode;
   --  	  Monitored_Item_Ids : ListOfUInt32.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SetMonitoringModeRequest) return UInt16 is (SID.SetMonitoringModeRequest_Id);
   --  function Binary_Size(Item : SetMonitoringModeRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 8
   --  																			 + ListOfUInt32.Binary_Size(Item.Monitored_Item_Ids) );
   
   --  -- SetMonitoringModeResponse
   --  type SetMonitoringModeResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SetMonitoringModeResponse) return UInt16 is (SID.SetMonitoringModeResponse_Id);
   --  function Binary_Size(Item : SetMonitoringModeResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- SetTriggeringRequest
   --  type SetTriggeringRequest is new Request_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Triggering_Item_Id : UInt32;
   --  	  Links_To_Add : ListOfUInt32.Pointer;
   --  	  Links_To_Remove : ListOfUInt32.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SetTriggeringRequest) return UInt16 is (SID.SetTriggeringRequest_Id);
   --  function Binary_Size(Item : SetTriggeringRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 4 + ListOfUInt32.Binary_Size(Item.Links_To_Add) + ListOfUInt32.Binary_Size(Item.Links_To_Remove) );
   
   --  -- SetTriggeringResponse
   --  type SetTriggeringResponse is new Response_Base with record
   --  	  Add_Results : ListOfStatusCode.Pointer;
   --  	  Add_Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  	  Remove_Results : ListOfStatusCode.Pointer;
   --  	  Remove_Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SetTriggeringResponse) return UInt16 is (SID.SetTriggeringResponse_Id);
   --  function Binary_Size(Item : SetTriggeringResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Add_Results) + DiagnosticInfos.Binary_Size(Item.Add_Diagnostic_Infos) + ListOfStatusCode.Binary_Size(Item.Remove_Results) + DiagnosticInfos.Binary_Size(Item.Remove_Diagnostic_Infos) );
   
   --  -- DeleteMonitoredItemsRequest
   --  type DeleteMonitoredItemsRequest is new Request_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Monitored_Item_Ids : ListOfUInt32.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteMonitoredItemsRequest) return UInt16 is (SID.DeleteMonitoredItemsRequest_Id);
   --  function Binary_Size(Item : DeleteMonitoredItemsRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + ListOfUInt32.Binary_Size(Item.Monitored_Item_Ids) );
   
   --  -- DeleteMonitoredItemsResponse
   --  type DeleteMonitoredItemsResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteMonitoredItemsResponse) return UInt16 is (SID.DeleteMonitoredItemsResponse_Id);
   --  function Binary_Size(Item : DeleteMonitoredItemsResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- CreateSubscriptionRequest
   --  type CreateSubscriptionRequest is new Request_Base with record
   --  	  Requested_Publishing_Interval : Double;
   --  	  Requested_Lifetime_Count : UInt32;
   --  	  Requested_Max_Keep_Alive_Count : UInt32;
   --  	  Max_Notifications_Per_Publish : UInt32;
   --  	  Publishing_Enabled : Boolean;
   --  	  Priority : Byte;
   --  end record;
   --  function NodeId_Nr(Item : in CreateSubscriptionRequest) return UInt16 is (SID.CreateSubscriptionRequest_Id);
   --  function Binary_Size(Item : CreateSubscriptionRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 8 + 4 + 4 + 4 + 1 + 1 );
   
   --  -- CreateSubscriptionResponse
   --  type CreateSubscriptionResponse is new Response_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Revised_Publishing_Interval : Double;
   --  	  Revised_Lifetime_Count : UInt32;
   --  	  Revised_Max_Keep_Alive_Count : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in CreateSubscriptionResponse) return UInt16 is (SID.CreateSubscriptionResponse_Id);
   --  function Binary_Size(Item : CreateSubscriptionResponse) return Int32 is ( Binary_Size(Item.Response_Header) + 4 + 8 + 4 + 4 );
   
   --  -- ModifySubscriptionRequest
   --  type ModifySubscriptionRequest is new Request_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Requested_Publishing_Interval : Double;
   --  	  Requested_Lifetime_Count : UInt32;
   --  	  Requested_Max_Keep_Alive_Count : UInt32;
   --  	  Max_Notifications_Per_Publish : UInt32;
   --  	  Priority : Byte;
   --  end record;
   --  function NodeId_Nr(Item : in ModifySubscriptionRequest) return UInt16 is (SID.ModifySubscriptionRequest_Id);
   --  function Binary_Size(Item : ModifySubscriptionRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 8 + 4 + 4 + 4 + 1 );
   
   --  -- ModifySubscriptionResponse
   --  type ModifySubscriptionResponse is new Response_Base with record
   --  	  Revised_Publishing_Interval : Double;
   --  	  Revised_Lifetime_Count : UInt32;
   --  	  Revised_Max_Keep_Alive_Count : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in ModifySubscriptionResponse) return UInt16 is (SID.ModifySubscriptionResponse_Id);
   --  function Binary_Size(Item : ModifySubscriptionResponse) return Int32 is ( Binary_Size(Item.Response_Header) + 8 + 4 + 4 );
   
   --  -- SetPublishingModeRequest
   --  type SetPublishingModeRequest is new Request_Base with record
   --  	  Publishing_Enabled : Boolean;
   --  	  Subscription_Ids : ListOfUInt32.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SetPublishingModeRequest) return UInt16 is (SID.SetPublishingModeRequest_Id);
   --  function Binary_Size(Item : SetPublishingModeRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 1 + ListOfUInt32.Binary_Size(Item.Subscription_Ids) );
   
   --  -- SetPublishingModeResponse
   --  type SetPublishingModeResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SetPublishingModeResponse) return UInt16 is (SID.SetPublishingModeResponse_Id);
   --  function Binary_Size(Item : SetPublishingModeResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- NotificationMessage
   --  type NotificationMessage is new UA_Builtin with record
   --  	  Sequence_Number : UInt32;
   --  	  Publish_Time : DateTime;
   --  	  Notification_Data : ExtensionObjects.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in NotificationMessage) return UInt16 is (SID.NotificationMessage_Id);
   --  function Binary_Size(Item : NotificationMessage) return Int32 is ( 4 + 8 + ExtensionObjects.Binary_Size(Item.Notification_Data) );
   
   --  -- NotificationData
   --  type NotificationData is new UA_Builtin with  null record;
   --  function NodeId_Nr(Item : in NotificationData) return UInt16 is (SID.NotificationData_Id);
   --  function Binary_Size(Item : NotificationData) return Int32 is ( 0 );
   
   --  -- MonitoredItemNotification
   --  type MonitoredItemNotification is new UA_Builtin with record
   --  	  Client_Handle : UInt32;
   --  	  Value : DataValues.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in MonitoredItemNotification) return UInt16 is (SID.MonitoredItemNotification_Id);
   --  function Binary_Size(Item : MonitoredItemNotification) return Int32 is ( 4 + DataValues.Binary_Size(Item.Value) );
   
   --  package ListOfMonitoredItemNotification is new Types.Arrays.UA_Builtin_Arrays(MonitoredItemNotification);
   
   --  -- EventFieldList
   --  type EventFieldList is new UA_Builtin with record
   --  	  Client_Handle : UInt32;
   --  	  Event_Fields : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in EventFieldList) return UInt16 is (SID.EventFieldList_Id);
   --  function Binary_Size(Item : EventFieldList) return Int32 is ( 4 + Variants.Binary_Size(Item.Event_Fields) );
   
   --  package ListOfEventFieldList is new Types.Arrays.UA_Builtin_Arrays(EventFieldList);
   
   --  -- HistoryEventFieldList
   --  type HistoryEventFieldList is new UA_Builtin with record
   --  	  Event_Fields : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryEventFieldList) return UInt16 is (SID.HistoryEventFieldList_Id);
   --  function Binary_Size(Item : HistoryEventFieldList) return Int32 is ( Variants.Binary_Size(Item.Event_Fields) );
   
   --  package ListOfHistoryEventFieldList is new Types.Arrays.UA_Builtin_Arrays(HistoryEventFieldList);
   
   --  -- StatusChangeNotification
   --  type StatusChangeNotification is new UA_Builtin with record
   --  	  Status : StatusCode;
   --  	  Diagnostic_Info : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in StatusChangeNotification) return UInt16 is (SID.StatusChangeNotification_Id);
   --  function Binary_Size(Item : StatusChangeNotification) return Int32 is ( 4 + DiagnosticInfos.Binary_Size(Item.Diagnostic_Info) );
   
   --  -- SubscriptionAcknowledgement
   --  type SubscriptionAcknowledgement is new UA_Builtin with record
   --  	  Subscription_Id : UInt32;
   --  	  Sequence_Number : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in SubscriptionAcknowledgement) return UInt16 is (SID.SubscriptionAcknowledgement_Id);
   --  function Binary_Size(Item : SubscriptionAcknowledgement) return Int32 is ( 4 + 4 );
   
   --  package ListOfSubscriptionAcknowledgement is new Types.Arrays.UA_Builtin_Arrays(SubscriptionAcknowledgement);
   
   --  -- PublishRequest
   --  type PublishRequest is new Request_Base with record
   --  	  Subscription_Acknowledgements : ListOfSubscriptionAcknowledgement.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in PublishRequest) return UInt16 is (SID.PublishRequest_Id);
   --  function Binary_Size(Item : PublishRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfSubscriptionAcknowledgement.Binary_Size(Item.Subscription_Acknowledgements) );
   
   --  -- PublishResponse
   --  type PublishResponse is new Response_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Available_Sequence_Numbers : ListOfUInt32.Pointer;
   --  	  More_Notifications : Boolean;
   --  	  Notification_Message : NotificationMessage;
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in PublishResponse) return UInt16 is (SID.PublishResponse_Id);
   --  function Binary_Size(Item : PublishResponse) return Int32 is ( Binary_Size(Item.Response_Header) + 4 + ListOfUInt32.Binary_Size(Item.Available_Sequence_Numbers) + 1 + Binary_Size(Item.Notification_Message) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- RepublishRequest
   --  type RepublishRequest is new Request_Base with record
   --  	  Subscription_Id : UInt32;
   --  	  Retransmit_Sequence_Number : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in RepublishRequest) return UInt16 is (SID.RepublishRequest_Id);
   --  function Binary_Size(Item : RepublishRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 4 );
   
   --  -- RepublishResponse
   --  type RepublishResponse is new Response_Base with record
   --  	  Notification_Message : NotificationMessage;
   --  end record;
   --  function NodeId_Nr(Item : in RepublishResponse) return UInt16 is (SID.RepublishResponse_Id);
   --  function Binary_Size(Item : RepublishResponse) return Int32 is ( Binary_Size(Item.Response_Header) + Binary_Size(Item.Notification_Message) );
   
   --  -- TransferResult
   --  type TransferResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Available_Sequence_Numbers : ListOfUInt32.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in TransferResult) return UInt16 is (SID.TransferResult_Id);
   --  function Binary_Size(Item : TransferResult) return Int32 is ( 4 + ListOfUInt32.Binary_Size(Item.Available_Sequence_Numbers) );
   
   --  package ListOfTransferResult is new Types.Arrays.UA_Builtin_Arrays(TransferResult);
   
   --  -- TransferSubscriptionsRequest
   --  type TransferSubscriptionsRequest is new Request_Base with record
   --  	  Subscription_Ids : ListOfUInt32.Pointer;
   --  	  Send_Initial_Values : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in TransferSubscriptionsRequest) return UInt16 is (SID.TransferSubscriptionsRequest_Id);
   --  function Binary_Size(Item : TransferSubscriptionsRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfUInt32.Binary_Size(Item.Subscription_Ids) + 1 );
   
   --  -- TransferSubscriptionsResponse
   --  type TransferSubscriptionsResponse is new Response_Base with record
   --  	  Results : ListOfTransferResult.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in TransferSubscriptionsResponse) return UInt16 is (SID.TransferSubscriptionsResponse_Id);
   --  function Binary_Size(Item : TransferSubscriptionsResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfTransferResult.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- DeleteSubscriptionsRequest
   --  type DeleteSubscriptionsRequest is new Request_Base with record
   --  	  Subscription_Ids : ListOfUInt32.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteSubscriptionsRequest) return UInt16 is (SID.DeleteSubscriptionsRequest_Id);
   --  function Binary_Size(Item : DeleteSubscriptionsRequest) return Int32 is ( Binary_Size(Item.Request_Header) + ListOfUInt32.Binary_Size(Item.Subscription_Ids) );
   
   --  -- DeleteSubscriptionsResponse
   --  type DeleteSubscriptionsResponse is new Response_Base with record
   --  	  Results : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DeleteSubscriptionsResponse) return UInt16 is (SID.DeleteSubscriptionsResponse_Id);
   --  function Binary_Size(Item : DeleteSubscriptionsResponse) return Int32 is ( Binary_Size(Item.Response_Header) + ListOfStatusCode.Binary_Size(Item.Results) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- EnumeratedTestType
   --  -- A simple enumerated type used for testing.
   --  type EnumeratedTestType is (EnumeratedTestType_Red,
   --  							   EnumeratedTestType_Yellow,
   --  							   EnumeratedTestType_Green);
   --  for EnumeratedTestType'Size use 32;
   --  for EnumeratedTestType use (EnumeratedTestType_Red => 1,
   --  							   EnumeratedTestType_Yellow => 4,
   --  							   EnumeratedTestType_Green => 5);
   
   --  package ListOfEnumeratedTestType is new Types.Arrays.Elementary_Arrays(EnumeratedTestType);
   
   --  -- ScalarTestType
   --  -- A complex type containing all possible scalar types used for testing.
   --  type ScalarTestType is new UA_Builtin with record
   --  	  Boolean_Value : Boolean;
   --  	  SByte_Value : SByte;
   --  	  Byte_Value : Byte;
   --  	  Int16_Value : Int16;
   --  	  UInt16_Value : UInt16;
   --  	  Int32_Value : Int32;
   --  	  UInt32_Value : UInt32;
   --  	  Int64_Value : Int64;
   --  	  UInt64_Value : UInt64;
   --  	  Float_Value : Float;
   --  	  Double_Value : Double;
   --  	  String_Value : String;
   --  	  Date_Time : DateTime;
   --  	  Guid_Value : Guid;
   --  	  Byte_String : ByteString;
   --  	  Xml_Element : XmlElement;
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Expanded_Node_Id : ExpandedNodeIds.Pointer;
   --  	  Status_Code : StatusCode;
   --  	  Diagnostic_Info : DiagnosticInfos.Pointer;
   --  	  Qualified_Name : QualifiedNames.Pointer;
   --  	  Localized_Text : LocalizedTexts.Pointer;
   --  	  Extension_Object : ExtensionObjects.Pointer;
   --  	  Data_Value : DataValues.Pointer;
   --  	  Enumerated_Value : EnumeratedTestType;
   --  end record;
   --  function NodeId_Nr(Item : in ScalarTestType) return UInt16 is (SID.ScalarTestType_Id);
   --  function Binary_Size(Item : ScalarTestType) return Int32 is ( 1 + 1 + 1 + 2 + 2 + 4 + 4 + 8 + 8 + 4 + 8 + Binary_Size(Item.String_Value) + 8 + Binary_Size(Item.Guid_Value) + Binary_Size(Item.Byte_String) + Binary_Size(Item.Xml_Element) + NodeIds.Binary_Size(Item.Node_Id) + ExpandedNodeIds.Binary_Size(Item.Expanded_Node_Id) + 4 + DiagnosticInfos.Binary_Size(Item.Diagnostic_Info) + QualifiedNames.Binary_Size(Item.Qualified_Name) + LocalizedTexts.Binary_Size(Item.Localized_Text) + ExtensionObjects.Binary_Size(Item.Extension_Object) + DataValues.Binary_Size(Item.Data_Value) + 8
   --  															   );
   
   --  -- ArrayTestType
   --  -- A complex type containing all possible array types used for testing.
   --  type ArrayTestType is new UA_Builtin with record
   --  	  Booleans : ListOfBoolean.Pointer;
   --  	  SBytes : ListOfSByte.Pointer;
   --  	  Int16s : ListOfInt16.Pointer;
   --  	  UInt16s : ListOfUInt16.Pointer;
   --  	  Int32s : ListOfInt32.Pointer;
   --  	  UInt32s : ListOfUInt32.Pointer;
   --  	  Int64s : ListOfInt64.Pointer;
   --  	  UInt64s : ListOfUInt64.Pointer;
   --  	  Floats : ListOfFloat.Pointer;
   --  	  Doubles : ListOfDouble.Pointer;
   --  	  Strings : ListOfString.Pointer;
   --  	  Date_Times : ListOfDateTime.Pointer;
   --  	  Guids : ListOfGuid.Pointer;
   --  	  Byte_Strings : ListOfByteString.Pointer;
   --  	  Xml_Elements : ListOfXmlElement.Pointer;
   --  	  Node_Ids : NodeIds.Pointer;
   --  	  Expanded_Node_Ids : ExpandedNodeIds.Pointer;
   --  	  Status_Codes : ListOfStatusCode.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  	  Qualified_Names : QualifiedNames.Pointer;
   --  	  Localized_Texts : LocalizedTexts.Pointer;
   --  	  Extension_Objects : ExtensionObjects.Pointer;
   --  	  Data_Values : DataValues.Pointer;
   --  	  Variants_Value : Variants.Pointer;
   --  	  Enumerated_Values : ListOfEnumeratedTestType.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ArrayTestType) return UInt16 is (SID.ArrayTestType_Id);
   --  function Binary_Size(Item : ArrayTestType) return Int32 is ( ListOfBoolean.Binary_Size(Item.Booleans) + ListOfSByte.Binary_Size(Item.SBytes) + ListOfInt16.Binary_Size(Item.Int16s) + ListOfUInt16.Binary_Size(Item.UInt16s) + ListOfInt32.Binary_Size(Item.Int32s) + ListOfUInt32.Binary_Size(Item.UInt32s) + ListOfInt64.Binary_Size(Item.Int64s) + ListOfUInt64.Binary_Size(Item.UInt64s) + ListOfFloat.Binary_Size(Item.Floats) + ListOfDouble.Binary_Size(Item.Doubles) + ListOfString.Binary_Size(Item.Strings) + ListOfDateTime.Binary_Size(Item.Date_Times) + ListOfGuid.Binary_Size(Item.Guids) + ListOfByteString.Binary_Size(Item.Byte_Strings) + ListOfXmlElement.Binary_Size(Item.Xml_Elements) + NodeIds.Binary_Size(Item.Node_Ids) + ExpandedNodeIds.Binary_Size(Item.Expanded_Node_Ids) + ListOfStatusCode.Binary_Size(Item.Status_Codes) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) + QualifiedNames.Binary_Size(Item.Qualified_Names) + LocalizedTexts.Binary_Size(Item.Localized_Texts) + ExtensionObjects.Binary_Size(Item.Extension_Objects) + DataValues.Binary_Size(Item.Data_Values) + Variants.Binary_Size(Item.Variants_Value) + ListOfEnumeratedTestType.Binary_Size(Item.Enumerated_Values) );
   
   --  -- CompositeTestType
   --  type CompositeTestType is new UA_Builtin with record
   --  	  Field1 : ScalarTestType;
   --  	  Field2 : ArrayTestType;
   --  end record;
   --  function NodeId_Nr(Item : in CompositeTestType) return UInt16 is (SID.CompositeTestType_Id);
   --  function Binary_Size(Item : CompositeTestType) return Int32 is ( Binary_Size(Item.Field1) + Binary_Size(Item.Field2) );
   
   --  -- TestStackRequest
   --  type TestStackRequest is new Request_Base with record
   --  	  Test_Id : UInt32;
   --  	  Iteration : Int32;
   --  	  Input : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in TestStackRequest) return UInt16 is (SID.TestStackRequest_Id);
   --  function Binary_Size(Item : TestStackRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 4 + Variants.Binary_Size(Item.Input) );
   
   --  -- TestStackResponse
   --  type TestStackResponse is new Response_Base with record
   --  	  Output : Variants.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in TestStackResponse) return UInt16 is (SID.TestStackResponse_Id);
   --  function Binary_Size(Item : TestStackResponse) return Int32 is ( Binary_Size(Item.Response_Header) + Variants.Binary_Size(Item.Output) );
   
   --  -- TestStackExRequest
   --  type TestStackExRequest is new Request_Base with record
   --  	  Test_Id : UInt32;
   --  	  Iteration : Int32;
   --  	  Input : CompositeTestType;
   --  end record;
   --  function NodeId_Nr(Item : in TestStackExRequest) return UInt16 is (SID.TestStackExRequest_Id);
   --  function Binary_Size(Item : TestStackExRequest) return Int32 is ( Binary_Size(Item.Request_Header) + 4 + 4 + Binary_Size(Item.Input) );
   
   --  -- TestStackExResponse
   --  type TestStackExResponse is new Response_Base with record
   --  	  Output : CompositeTestType;
   --  end record;
   --  function NodeId_Nr(Item : in TestStackExResponse) return UInt16 is (SID.TestStackExResponse_Id);
   --  function Binary_Size(Item : TestStackExResponse) return Int32 is ( Binary_Size(Item.Response_Header) + Binary_Size(Item.Output) );
   
   --  -- BuildInfo
   --  type BuildInfo is new UA_Builtin with record
   --  	  Product_Uri : String;
   --  	  Manufacturer_Name : String;
   --  	  Product_Name : String;
   --  	  Software_Version : String;
   --  	  Build_Number : String;
   --  	  Build_Date : DateTime;
   --  end record;
   --  function NodeId_Nr(Item : in BuildInfo) return UInt16 is (SID.BuildInfo_Id);
   --  function Binary_Size(Item : BuildInfo) return Int32 is ( Binary_Size(Item.Product_Uri) + Binary_Size(Item.Manufacturer_Name) + Binary_Size(Item.Product_Name) + Binary_Size(Item.Software_Version) + Binary_Size(Item.Build_Number) + 8 );
   
   --  -- RedundancySupport
   --  type RedundancySupport is (RedundancySupport_None,
   --  							  RedundancySupport_Cold,
   --  							  RedundancySupport_Warm,
   --  							  RedundancySupport_Hot,
   --  							  RedundancySupport_Transparent,
   --  							  RedundancySupport_HotAndMirrored);
   --  for RedundancySupport'Size use 32;
   --  for RedundancySupport use (RedundancySupport_None => 0,
   --  							  RedundancySupport_Cold => 1,
   --  							  RedundancySupport_Warm => 2,
   --  							  RedundancySupport_Hot => 3,
   --  							  RedundancySupport_Transparent => 4,
   --  							  RedundancySupport_HotAndMirrored => 5);
   
   --  -- ServerState
   --  type ServerState is (ServerState_Running,
   --  						ServerState_Failed,
   --  						ServerState_NoConfiguration,
   --  						ServerState_Suspended,
   --  						ServerState_Shutdown,
   --  						ServerState_Test,
   --  						ServerState_CommunicationFault,
   --  						ServerState_Unknown);
   --  for ServerState'Size use 32;
   --  for ServerState use (ServerState_Running => 0,
   --  						ServerState_Failed => 1,
   --  						ServerState_NoConfiguration => 2,
   --  						ServerState_Suspended => 3,
   --  						ServerState_Shutdown => 4,
   --  						ServerState_Test => 5,
   --  						ServerState_CommunicationFault => 6,
   --  						ServerState_Unknown => 7);
   
   --  -- RedundantServerDataType
   --  type RedundantServerDataType is new UA_Builtin with record
   --  	  Server_Id : String;
   --  	  Service_Level : Byte;
   --  	  Server_State : ServerState;
   --  end record;
   --  function NodeId_Nr(Item : in RedundantServerDataType) return UInt16 is (SID.RedundantServerDataType_Id);
   --  function Binary_Size(Item : RedundantServerDataType) return Int32 is ( Binary_Size(Item.Server_Id) + 1 + 8
   --  																		);
   
   --  -- EndpointUrlListDataType
   --  type EndpointUrlListDataType is new UA_Builtin with record
   --  	  Endpoint_Url_List : ListOfString.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in EndpointUrlListDataType) return UInt16 is (SID.EndpointUrlListDataType_Id);
   --  function Binary_Size(Item : EndpointUrlListDataType) return Int32 is ( ListOfString.Binary_Size(Item.Endpoint_Url_List) );
   
   --  package ListOfEndpointUrlListDataType is new Types.Arrays.UA_Builtin_Arrays(EndpointUrlListDataType);
   
   --  -- NetworkGroupDataType
   --  type NetworkGroupDataType is new UA_Builtin with record
   --  	  Server_Uri : String;
   --  	  Network_Paths : ListOfEndpointUrlListDataType.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in NetworkGroupDataType) return UInt16 is (SID.NetworkGroupDataType_Id);
   --  function Binary_Size(Item : NetworkGroupDataType) return Int32 is ( Binary_Size(Item.Server_Uri) + ListOfEndpointUrlListDataType.Binary_Size(Item.Network_Paths) );
   
   --  -- SamplingIntervalDiagnosticsDataType
   --  type SamplingIntervalDiagnosticsDataType is new UA_Builtin with record
   --  	  Sampling_Interval : Double;
   --  	  Monitored_Item_Count : UInt32;
   --  	  Max_Monitored_Item_Count : UInt32;
   --  	  Disabled_Monitored_Item_Count : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in SamplingIntervalDiagnosticsDataType) return UInt16 is (SID.SamplingIntervalDiagnosticsDataType_Id);
   --  function Binary_Size(Item : SamplingIntervalDiagnosticsDataType) return Int32 is ( 8 + 4 + 4 + 4 );
   
   --  -- ServerDiagnosticsSummaryDataType
   --  type ServerDiagnosticsSummaryDataType is new UA_Builtin with record
   --  	  Server_View_Count : UInt32;
   --  	  Current_Session_Count : UInt32;
   --  	  Cumulated_Session_Count : UInt32;
   --  	  Security_Rejected_Session_Count : UInt32;
   --  	  Rejected_Session_Count : UInt32;
   --  	  Session_Timeout_Count : UInt32;
   --  	  Session_Abort_Count : UInt32;
   --  	  Current_Subscription_Count : UInt32;
   --  	  Cumulated_Subscription_Count : UInt32;
   --  	  Publishing_Interval_Count : UInt32;
   --  	  Security_Rejected_Requests_Count : UInt32;
   --  	  Rejected_Requests_Count : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in ServerDiagnosticsSummaryDataType) return UInt16 is (SID.ServerDiagnosticsSummaryDataType_Id);
   --  function Binary_Size(Item : ServerDiagnosticsSummaryDataType) return Int32 is ( 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 );
   
   --  -- ServerStatusDataType
   --  type ServerStatusDataType is new UA_Builtin with record
   --  	  Start_Time : DateTime;
   --  	  Current_Time : DateTime;
   --  	  State : ServerState;
   --  	  Build_Info : BuildInfo;
   --  	  Seconds_Till_Shutdown : UInt32;
   --  	  Shutdown_Reason : LocalizedTexts.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ServerStatusDataType) return UInt16 is (SID.ServerStatusDataType_Id);
   --  function Binary_Size(Item : ServerStatusDataType) return Int32 is ( 8 + 8 + 8
   --  																		 + Binary_Size(Item.Build_Info) + 4 + LocalizedTexts.Binary_Size(Item.Shutdown_Reason) );
   
   --  -- SessionSecurityDiagnosticsDataType
   --  type SessionSecurityDiagnosticsDataType is new UA_Builtin with record
   --  	  Session_Id : NodeIds.Pointer;
   --  	  Client_User_Id_Of_Session : String;
   --  	  Client_User_Id_History : ListOfString.Pointer;
   --  	  Authentication_Mechanism : String;
   --  	  Encoding : String;
   --  	  Transport_Protocol : String;
   --  	  Security_Mode : MessageSecurityMode;
   --  	  Security_Policy_Uri : String;
   --  	  Client_Certificate : ByteString;
   --  end record;
   --  function NodeId_Nr(Item : in SessionSecurityDiagnosticsDataType) return UInt16 is (SID.SessionSecurityDiagnosticsDataType_Id);
   --  function Binary_Size(Item : SessionSecurityDiagnosticsDataType) return Int32 is ( NodeIds.Binary_Size(Item.Session_Id) + Binary_Size(Item.Client_User_Id_Of_Session) + ListOfString.Binary_Size(Item.Client_User_Id_History) + Binary_Size(Item.Authentication_Mechanism) + Binary_Size(Item.Encoding) + Binary_Size(Item.Transport_Protocol) + 8
   --  																					   + Binary_Size(Item.Security_Policy_Uri) + Binary_Size(Item.Client_Certificate) );
   
   --  -- ServiceCounterDataType
   --  type ServiceCounterDataType is new UA_Builtin with record
   --  	  Total_Count : UInt32;
   --  	  Error_Count : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in ServiceCounterDataType) return UInt16 is (SID.ServiceCounterDataType_Id);
   --  function Binary_Size(Item : ServiceCounterDataType) return Int32 is ( 4 + 4 );
   
   --  -- StatusResult
   --  type StatusResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Diagnostic_Info : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in StatusResult) return UInt16 is (SID.StatusResult_Id);
   --  function Binary_Size(Item : StatusResult) return Int32 is ( 4 + DiagnosticInfos.Binary_Size(Item.Diagnostic_Info) );
   
   --  -- SubscriptionDiagnosticsDataType
   --  type SubscriptionDiagnosticsDataType is new UA_Builtin with record
   --  	  Session_Id : NodeIds.Pointer;
   --  	  Subscription_Id : UInt32;
   --  	  Priority : Byte;
   --  	  Publishing_Interval : Double;
   --  	  Max_Keep_Alive_Count : UInt32;
   --  	  Max_Lifetime_Count : UInt32;
   --  	  Max_Notifications_Per_Publish : UInt32;
   --  	  Publishing_Enabled : Boolean;
   --  	  Modify_Count : UInt32;
   --  	  Enable_Count : UInt32;
   --  	  Disable_Count : UInt32;
   --  	  Republish_Request_Count : UInt32;
   --  	  Republish_Message_Request_Count : UInt32;
   --  	  Republish_Message_Count : UInt32;
   --  	  Transfer_Request_Count : UInt32;
   --  	  Transferred_To_Alt_Client_Count : UInt32;
   --  	  Transferred_To_Same_Client_Count : UInt32;
   --  	  Publish_Request_Count : UInt32;
   --  	  Data_Change_Notifications_Count : UInt32;
   --  	  Event_Notifications_Count : UInt32;
   --  	  Notifications_Count : UInt32;
   --  	  Late_Publish_Request_Count : UInt32;
   --  	  Current_Keep_Alive_Count : UInt32;
   --  	  Current_Lifetime_Count : UInt32;
   --  	  Unacknowledged_Message_Count : UInt32;
   --  	  Discarded_Message_Count : UInt32;
   --  	  Monitored_Item_Count : UInt32;
   --  	  Disabled_Monitored_Item_Count : UInt32;
   --  	  Monitoring_Queue_Overflow_Count : UInt32;
   --  	  Next_Sequence_Number : UInt32;
   --  	  Event_Queue_Over_Flow_Count : UInt32;
   --  end record;
   --  function NodeId_Nr(Item : in SubscriptionDiagnosticsDataType) return UInt16 is (SID.SubscriptionDiagnosticsDataType_Id);
   --  function Binary_Size(Item : SubscriptionDiagnosticsDataType) return Int32 is ( NodeIds.Binary_Size(Item.Session_Id) + 4 + 1 + 8 + 4 + 4 + 4 + 1 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 + 4 );
   
   --  -- ModelChangeStructureVerbMask
   --  type ModelChangeStructureVerbMask is (ModelChangeStructureVerbMask_NodeAdded,
   --  										 ModelChangeStructureVerbMask_NodeDeleted,
   --  										 ModelChangeStructureVerbMask_ReferenceAdded,
   --  										 ModelChangeStructureVerbMask_ReferenceDeleted,
   --  										 ModelChangeStructureVerbMask_DataTypeChanged);
   --  for ModelChangeStructureVerbMask'Size use 32;
   --  for ModelChangeStructureVerbMask use (ModelChangeStructureVerbMask_NodeAdded => 1,
   --  										 ModelChangeStructureVerbMask_NodeDeleted => 2,
   --  										 ModelChangeStructureVerbMask_ReferenceAdded => 4,
   --  										 ModelChangeStructureVerbMask_ReferenceDeleted => 8,
   --  										 ModelChangeStructureVerbMask_DataTypeChanged => 16);
   
   --  -- ModelChangeStructureDataType
   --  type ModelChangeStructureDataType is new UA_Builtin with record
   --  	  Affected : NodeIds.Pointer;
   --  	  Affected_Type : NodeIds.Pointer;
   --  	  Verb : Byte;
   --  end record;
   --  function NodeId_Nr(Item : in ModelChangeStructureDataType) return UInt16 is (SID.ModelChangeStructureDataType_Id);
   --  function Binary_Size(Item : ModelChangeStructureDataType) return Int32 is ( NodeIds.Binary_Size(Item.Affected) + NodeIds.Binary_Size(Item.Affected_Type) + 1 );
   
   --  -- SemanticChangeStructureDataType
   --  type SemanticChangeStructureDataType is new UA_Builtin with record
   --  	  Affected : NodeIds.Pointer;
   --  	  Affected_Type : NodeIds.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in SemanticChangeStructureDataType) return UInt16 is (SID.SemanticChangeStructureDataType_Id);
   --  function Binary_Size(Item : SemanticChangeStructureDataType) return Int32 is ( NodeIds.Binary_Size(Item.Affected) + NodeIds.Binary_Size(Item.Affected_Type) );
   
   --  -- Range
   --  type RangeType is new UA_Builtin with record
   --  	  Low : Double;
   --  	  High : Double;
   --  end record;
   --  function NodeId_Nr(Item : in RangeType) return UInt16 is (SID.Range_Id);
   --  function Binary_Size(Item : RangeType) return Int32 is ( 8 + 8 );
   
   --  -- EUInformation
   --  type EUInformation is new UA_Builtin with record
   --  	  Namespace_Uri : String;
   --  	  Unit_Id : Int32;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in EUInformation) return UInt16 is (SID.EUInformation_Id);
   --  function Binary_Size(Item : EUInformation) return Int32 is ( Binary_Size(Item.Namespace_Uri) + 4 + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) );
   
   --  -- AxisScaleEnumeration
   --  type AxisScaleEnumeration is (AxisScaleEnumeration_Linear,
   --  								 AxisScaleEnumeration_Log,
   --  								 AxisScaleEnumeration_Ln);
   --  for AxisScaleEnumeration'Size use 32;
   --  for AxisScaleEnumeration use (AxisScaleEnumeration_Linear => 0,
   --  								 AxisScaleEnumeration_Log => 1,
   --  								 AxisScaleEnumeration_Ln => 2);
   
   --  -- ComplexNumberType
   --  type ComplexNumberType is new UA_Builtin with record
   --  	  Real : Float;
   --  	  Imaginary : Float;
   --  end record;
   --  function NodeId_Nr(Item : in ComplexNumberType) return UInt16 is (SID.ComplexNumberType_Id);
   --  function Binary_Size(Item : ComplexNumberType) return Int32 is ( 4 + 4 );
   
   --  -- DoubleComplexNumberType
   --  type DoubleComplexNumberType is new UA_Builtin with record
   --  	  Real : Double;
   --  	  Imaginary : Double;
   --  end record;
   --  function NodeId_Nr(Item : in DoubleComplexNumberType) return UInt16 is (SID.DoubleComplexNumberType_Id);
   --  function Binary_Size(Item : DoubleComplexNumberType) return Int32 is ( 8 + 8 );
   
   --  -- AxisInformation
   --  type AxisInformation is new UA_Builtin with record
   --  	  Engineering_Units : EUInformation;
   --  	  EURange : RangeType;
   --  	  Title : LocalizedTexts.Pointer;
   --  	  Axis_Scale_Type : AxisScaleEnumeration;
   --  	  Axis_Steps : ListOfDouble.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in AxisInformation) return UInt16 is (SID.AxisInformation_Id);
   --  function Binary_Size(Item : AxisInformation) return Int32 is ( Binary_Size(Item.Engineering_Units) + Binary_Size(Item.EURange) + LocalizedTexts.Binary_Size(Item.Title) + 8
   --  																	+ ListOfDouble.Binary_Size(Item.Axis_Steps) );
   
   --  -- XVType
   --  type XVType is new UA_Builtin with record
   --  	  X : Double;
   --  	  Value : Float;
   --  end record;
   --  function NodeId_Nr(Item : in XVType) return UInt16 is (SID.XVType_Id);
   --  function Binary_Size(Item : XVType) return Int32 is ( 8 + 4 );
   
   --  -- ProgramDiagnosticDataType
   --  type ProgramDiagnosticDataType is new UA_Builtin with record
   --  	  Create_Session_Id : NodeIds.Pointer;
   --  	  Create_Client_Name : String;
   --  	  Invocation_Creation_Time : DateTime;
   --  	  Last_Transition_Time : DateTime;
   --  	  Last_Method_Call : String;
   --  	  Last_Method_Session_Id : NodeIds.Pointer;
   --  	  Last_Method_Input_Arguments : ListOfArgument.Pointer;
   --  	  Last_Method_Output_Arguments : ListOfArgument.Pointer;
   --  	  Last_Method_Call_Time : DateTime;
   --  	  Last_Method_Return_Status : StatusResult;
   --  end record;
   --  function NodeId_Nr(Item : in ProgramDiagnosticDataType) return UInt16 is (SID.ProgramDiagnosticDataType_Id);
   --  function Binary_Size(Item : ProgramDiagnosticDataType) return Int32 is ( NodeIds.Binary_Size(Item.Create_Session_Id) + Binary_Size(Item.Create_Client_Name) + 8 + 8 + Binary_Size(Item.Last_Method_Call) + NodeIds.Binary_Size(Item.Last_Method_Session_Id) + ListOfArgument.Binary_Size(Item.Last_Method_Input_Arguments) + ListOfArgument.Binary_Size(Item.Last_Method_Output_Arguments) + 8 + Binary_Size(Item.Last_Method_Return_Status) );
   
   --  -- Annotation
   --  type Annotation is new UA_Builtin with record
   --  	  Message : String;
   --  	  User_Name : String;
   --  	  Annotation_Time : DateTime;
   --  end record;
   --  function NodeId_Nr(Item : in Annotation) return UInt16 is (SID.Annotation_Id);
   --  function Binary_Size(Item : Annotation) return Int32 is ( Binary_Size(Item.Message) + Binary_Size(Item.User_Name) + 8 );
   
   --  -- ExceptionDeviationFormat
   --  type ExceptionDeviationFormat is (ExceptionDeviationFormat_AbsoluteValue,
   --  									 ExceptionDeviationFormat_PercentOfRange,
   --  									 ExceptionDeviationFormat_PercentOfValue,
   --  									 ExceptionDeviationFormat_PercentOfEURange,
   --  									 ExceptionDeviationFormat_Unknown);
   --  for ExceptionDeviationFormat'Size use 32;
   --  for ExceptionDeviationFormat use (ExceptionDeviationFormat_AbsoluteValue => 0,
   --  									 ExceptionDeviationFormat_PercentOfRange => 1,
   --  									 ExceptionDeviationFormat_PercentOfValue => 2,
   --  									 ExceptionDeviationFormat_PercentOfEURange => 3,
   --  									 ExceptionDeviationFormat_Unknown => 4);
   
   --  -- Node
   --  -- Specifies the attributes which belong to all nodes.
   --  type Node is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in Node) return UInt16 is (SID.Node_Id);
   --  function Binary_Size(Item : Node) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  														 + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) );
   
   --  -- InstanceNode
   --  type InstanceNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in InstanceNode) return UInt16 is (SID.InstanceNode_Id);
   --  function Binary_Size(Item : InstanceNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																 + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) );
   
   --  -- TypeNode
   --  type TypeNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in TypeNode) return UInt16 is (SID.TypeNode_Id);
   --  function Binary_Size(Item : TypeNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  															 + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) );
   
   --  -- ObjectNode
   --  -- Specifies the attributes which belong to object nodes.
   --  type ObjectNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Event_Notifier : Byte;
   --  end record;
   --  function NodeId_Nr(Item : in ObjectNode) return UInt16 is (SID.ObjectNode_Id);
   --  function Binary_Size(Item : ObjectNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  															   + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + 1 );
   
   --  -- ObjectTypeNode
   --  -- Specifies the attributes which belong to object type nodes.
   --  type ObjectTypeNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Is_Abstract : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in ObjectTypeNode) return UInt16 is (SID.ObjectTypeNode_Id);
   --  function Binary_Size(Item : ObjectTypeNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																   + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + 1 );
   
   --  -- VariableNode
   --  -- Specifies the attributes which belong to variable nodes.
   --  type VariableNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Value : Variants.Pointer;
   --  	  Data_Type : NodeIds.Pointer;
   --  	  Value_Rank : Int32;
   --  	  Array_Dimensions : ListOfUInt32.Pointer;
   --  	  Access_Level : Byte;
   --  	  User_Access_Level : Byte;
   --  	  Minimum_Sampling_Interval : Double;
   --  	  Historizing : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in VariableNode) return UInt16 is (SID.VariableNode_Id);
   --  function Binary_Size(Item : VariableNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																 + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + Variants.Binary_Size(Item.Value) + NodeIds.Binary_Size(Item.Data_Type) + 4 + ListOfUInt32.Binary_Size(Item.Array_Dimensions) + 1 + 1 + 8 + 1 );
   
   --  -- VariableTypeNode
   --  -- Specifies the attributes which belong to variable type nodes.
   --  type VariableTypeNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Value : Variants.Pointer;
   --  	  Data_Type : NodeIds.Pointer;
   --  	  Value_Rank : Int32;
   --  	  Array_Dimensions : ListOfUInt32.Pointer;
   --  	  Is_Abstract : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in VariableTypeNode) return UInt16 is (SID.VariableTypeNode_Id);
   --  function Binary_Size(Item : VariableTypeNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																	 + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + Variants.Binary_Size(Item.Value) + NodeIds.Binary_Size(Item.Data_Type) + 4 + ListOfUInt32.Binary_Size(Item.Array_Dimensions) + 1 );
   
   --  -- ReferenceTypeNode
   --  -- Specifies the attributes which belong to reference type nodes.
   --  type ReferenceTypeNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Is_Abstract : Boolean;
   --  	  Symmetric : Boolean;
   --  	  Inverse_Name : LocalizedTexts.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in ReferenceTypeNode) return UInt16 is (SID.ReferenceTypeNode_Id);
   --  function Binary_Size(Item : ReferenceTypeNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																	  + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + 1 + 1 + LocalizedTexts.Binary_Size(Item.Inverse_Name) );
   
   --  -- MethodNode
   --  -- Specifies the attributes which belong to method nodes.
   --  type MethodNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Executable : Boolean;
   --  	  User_Executable : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in MethodNode) return UInt16 is (SID.MethodNode_Id);
   --  function Binary_Size(Item : MethodNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  															   + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + 1 + 1 );
   
   --  -- ViewNode
   --  type ViewNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Contains_No_Loops : Boolean;
   --  	  Event_Notifier : Byte;
   --  end record;
   --  function NodeId_Nr(Item : in ViewNode) return UInt16 is (SID.ViewNode_Id);
   --  function Binary_Size(Item : ViewNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  															 + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + 1 + 1 );
   
   --  -- DataTypeNode
   --  type DataTypeNode is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Node_Class : NodeClass;
   --  	  Browse_Name : QualifiedNames.Pointer;
   --  	  Display_Name : LocalizedTexts.Pointer;
   --  	  Description : LocalizedTexts.Pointer;
   --  	  Write_Mask : UInt32;
   --  	  User_Write_Mask : UInt32;
   --  	  References : ListOfReferenceNode.Pointer;
   --  	  Is_Abstract : Boolean;
   --  end record;
   --  function NodeId_Nr(Item : in DataTypeNode) return UInt16 is (SID.DataTypeNode_Id);
   --  function Binary_Size(Item : DataTypeNode) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																 + QualifiedNames.Binary_Size(Item.Browse_Name) + LocalizedTexts.Binary_Size(Item.Display_Name) + LocalizedTexts.Binary_Size(Item.Description) + 4 + 4 + ListOfReferenceNode.Binary_Size(Item.References) + 1 );
   
   --  -- ReadEventDetails
   --  type ReadEventDetails is new UA_Builtin with record
   --  	  Num_Values_Per_Node : UInt32;
   --  	  Start_Time : DateTime;
   --  	  End_Time : DateTime;
   --  	  Filter : EventFilter;
   --  end record;
   --  function NodeId_Nr(Item : in ReadEventDetails) return UInt16 is (SID.ReadEventDetails_Id);
   --  function Binary_Size(Item : ReadEventDetails) return Int32 is ( 4 + 8 + 8 + Binary_Size(Item.Filter) );
   
   --  -- ReadProcessedDetails
   --  type ReadProcessedDetails is new UA_Builtin with record
   --  	  Start_Time : DateTime;
   --  	  End_Time : DateTime;
   --  	  Processing_Interval : Double;
   --  	  Aggregate_Type : NodeIds.Pointer;
   --  	  Aggregate_Configuration : AggregateConfiguration;
   --  end record;
   --  function NodeId_Nr(Item : in ReadProcessedDetails) return UInt16 is (SID.ReadProcessedDetails_Id);
   --  function Binary_Size(Item : ReadProcessedDetails) return Int32 is ( 8 + 8 + 8 + NodeIds.Binary_Size(Item.Aggregate_Type) + Binary_Size(Item.Aggregate_Configuration) );
   
   --  -- ModificationInfo
   --  type ModificationInfo is new UA_Builtin with record
   --  	  Modification_Time : DateTime;
   --  	  Update_Type : HistoryUpdateType;
   --  	  User_Name : String;
   --  end record;
   --  function NodeId_Nr(Item : in ModificationInfo) return UInt16 is (SID.ModificationInfo_Id);
   --  function Binary_Size(Item : ModificationInfo) return Int32 is ( 8 + 8
   --  																	 + Binary_Size(Item.User_Name) );
   
   --  package ListOfModificationInfo is new Types.Arrays.UA_Builtin_Arrays(ModificationInfo);
   
   --  -- HistoryModifiedData
   --  type HistoryModifiedData is new UA_Builtin with record
   --  	  Data_Values : DataValues.Pointer;
   --  	  Modification_Infos : ListOfModificationInfo.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryModifiedData) return UInt16 is (SID.HistoryModifiedData_Id);
   --  function Binary_Size(Item : HistoryModifiedData) return Int32 is ( DataValues.Binary_Size(Item.Data_Values) + ListOfModificationInfo.Binary_Size(Item.Modification_Infos) );
   
   --  -- HistoryEvent
   --  type HistoryEvent is new UA_Builtin with record
   --  	  Events : ListOfHistoryEventFieldList.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryEvent) return UInt16 is (SID.HistoryEvent_Id);
   --  function Binary_Size(Item : HistoryEvent) return Int32 is ( ListOfHistoryEventFieldList.Binary_Size(Item.Events) );
   
   --  -- UpdateEventDetails
   --  type UpdateEventDetails is new UA_Builtin with record
   --  	  Node_Id : NodeIds.Pointer;
   --  	  Perform_Insert_Replace : PerformUpdateType;
   --  	  Filter : EventFilter;
   --  	  Event_Data : ListOfHistoryEventFieldList.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in UpdateEventDetails) return UInt16 is (SID.UpdateEventDetails_Id);
   --  function Binary_Size(Item : UpdateEventDetails) return Int32 is ( NodeIds.Binary_Size(Item.Node_Id) + 8
   --  																	   + Binary_Size(Item.Filter) + ListOfHistoryEventFieldList.Binary_Size(Item.Event_Data) );
   
   --  -- HistoryUpdateEventResult
   --  type HistoryUpdateEventResult is new UA_Builtin with record
   --  	  Status_Code : StatusCode;
   --  	  Event_Filter_Result : EventFilterResult;
   --  end record;
   --  function NodeId_Nr(Item : in HistoryUpdateEventResult) return UInt16 is (SID.HistoryUpdateEventResult_Id);
   --  function Binary_Size(Item : HistoryUpdateEventResult) return Int32 is ( 4 + Binary_Size(Item.Event_Filter_Result) );
   
   --  -- DataChangeNotification
   --  type DataChangeNotification is new UA_Builtin with record
   --  	  Monitored_Items : ListOfMonitoredItemNotification.Pointer;
   --  	  Diagnostic_Infos : DiagnosticInfos.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in DataChangeNotification) return UInt16 is (SID.DataChangeNotification_Id);
   --  function Binary_Size(Item : DataChangeNotification) return Int32 is ( ListOfMonitoredItemNotification.Binary_Size(Item.Monitored_Items) + DiagnosticInfos.Binary_Size(Item.Diagnostic_Infos) );
   
   --  -- EventNotificationList
   --  type EventNotificationList is new UA_Builtin with record
   --  	  Events : ListOfEventFieldList.Pointer;
   --  end record;
   --  function NodeId_Nr(Item : in EventNotificationList) return UInt16 is (SID.EventNotificationList_Id);
   --  function Binary_Size(Item : EventNotificationList) return Int32 is ( ListOfEventFieldList.Binary_Size(Item.Events) );
   
   --  -- SessionDiagnosticsDataType
   --  type SessionDiagnosticsDataType is new UA_Builtin with record
   --  	  Session_Id : NodeIds.Pointer;
   --  	  Session_Name : String;
   --  	  Client_Description : ApplicationDescription;
   --  	  Server_Uri : String;
   --  	  Endpoint_Url : String;
   --  	  Locale_Ids : ListOfString.Pointer;
   --  	  Actual_Session_Timeout : Double;
   --  	  Max_Response_Message_Size : UInt32;
   --  	  Client_Connection_Time : DateTime;
   --  	  Client_Last_Contact_Time : DateTime;
   --  	  Current_Subscriptions_Count : UInt32;
   --  	  Current_Monitored_Items_Count : UInt32;
   --  	  Current_Publish_Requests_In_Queue : UInt32;
   --  	  Total_Request_Count : ServiceCounterDataType;
   --  	  Unauthorized_Request_Count : UInt32;
   --  	  Read_Count : ServiceCounterDataType;
   --  	  History_Read_Count : ServiceCounterDataType;
   --  	  Write_Count : ServiceCounterDataType;
   --  	  History_Update_Count : ServiceCounterDataType;
   --  	  Call_Count : ServiceCounterDataType;
   --  	  Create_Monitored_Items_Count : ServiceCounterDataType;
   --  	  Modify_Monitored_Items_Count : ServiceCounterDataType;
   --  	  Set_Monitoring_Mode_Count : ServiceCounterDataType;
   --  	  Set_Triggering_Count : ServiceCounterDataType;
   --  	  Delete_Monitored_Items_Count : ServiceCounterDataType;
   --  	  Create_Subscription_Count : ServiceCounterDataType;
   --  	  Modify_Subscription_Count : ServiceCounterDataType;
   --  	  Set_Publishing_Mode_Count : ServiceCounterDataType;
   --  	  Publish_Count : ServiceCounterDataType;
   --  	  Republish_Count : ServiceCounterDataType;
   --  	  Transfer_Subscriptions_Count : ServiceCounterDataType;
   --  	  Delete_Subscriptions_Count : ServiceCounterDataType;
   --  	  Add_Nodes_Count : ServiceCounterDataType;
   --  	  Add_References_Count : ServiceCounterDataType;
   --  	  Delete_Nodes_Count : ServiceCounterDataType;
   --  	  Delete_References_Count : ServiceCounterDataType;
   --  	  Browse_Count : ServiceCounterDataType;
   --  	  Browse_Next_Count : ServiceCounterDataType;
   --  	  Translate_Browse_Paths_To_Node_Ids_Count : ServiceCounterDataType;
   --  	  Query_First_Count : ServiceCounterDataType;
   --  	  Query_Next_Count : ServiceCounterDataType;
   --  	  Register_Nodes_Count : ServiceCounterDataType;
   --  	  Unregister_Nodes_Count : ServiceCounterDataType;
   --  end record;
   --  function NodeId_Nr(Item : in SessionDiagnosticsDataType) return UInt16 is (SID.SessionDiagnosticsDataType_Id);
   --  function Binary_Size(Item : SessionDiagnosticsDataType) return Int32 is ( NodeIds.Binary_Size(Item.Session_Id) + Binary_Size(Item.Session_Name) + Binary_Size(Item.Client_Description) + Binary_Size(Item.Server_Uri) + Binary_Size(Item.Endpoint_Url) + ListOfString.Binary_Size(Item.Locale_Ids) + 8 + 4 + 8 + 8 + 4 + 4 + 4 + Binary_Size(Item.Total_Request_Count) + 4 + Binary_Size(Item.Read_Count) + Binary_Size(Item.History_Read_Count) + Binary_Size(Item.Write_Count) + Binary_Size(Item.History_Update_Count) + Binary_Size(Item.Call_Count) + Binary_Size(Item.Create_Monitored_Items_Count) + Binary_Size(Item.Modify_Monitored_Items_Count) + Binary_Size(Item.Set_Monitoring_Mode_Count) + Binary_Size(Item.Set_Triggering_Count) + Binary_Size(Item.Delete_Monitored_Items_Count) + Binary_Size(Item.Create_Subscription_Count) + Binary_Size(Item.Modify_Subscription_Count) + Binary_Size(Item.Set_Publishing_Mode_Count) + Binary_Size(Item.Publish_Count) + Binary_Size(Item.Republish_Count) + Binary_Size(Item.Transfer_Subscriptions_Count) + Binary_Size(Item.Delete_Subscriptions_Count) + Binary_Size(Item.Add_Nodes_Count) + Binary_Size(Item.Add_References_Count) + Binary_Size(Item.Delete_Nodes_Count) + Binary_Size(Item.Delete_References_Count) + Binary_Size(Item.Browse_Count) + Binary_Size(Item.Browse_Next_Count) + Binary_Size(Item.Translate_Browse_Paths_To_Node_Ids_Count) + Binary_Size(Item.Query_First_Count) + Binary_Size(Item.Query_Next_Count) + Binary_Size(Item.Register_Nodes_Count) + Binary_Size(Item.Unregister_Nodes_Count) );
   
end Types.Builtin;
