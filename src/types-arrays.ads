private with Ada.Finalization;
with Ada.Streams;
with Types.Smart_Pointers;

package Types.Arrays with Preelaborate is 

   generic
   	  type T is private; -- use elementary_types for which the 'Size attribute gives the storage size
   package Elementary_Arrays is
	  type A is array (Array_Index range <>) of aliased T;

	  type Pointer is new Binary_Streamable with private;
	  type Accessor (Data: not null access A) is limited private with Implicit_Dereference => Data;
	  function Create (Value : not null access A) return Pointer with Inline;
	  function Get (Ptr : Pointer'Class) return Accessor with Inline;
   
	  type Nullable_Pointer is new Binary_Streamable with private;
	  type Nullable_Accessor (Data: access A) is limited private with Implicit_Dereference => Data;
	  function Create (Value : access A) return Nullable_Pointer;
	  function Get (Ptr : Nullable_Pointer'Class) return Nullable_Accessor with Inline;
	  function Is_Null(Ptr: Nullable_Pointer) return Boolean is (Ptr.Get.Data = null);
	  Null_Pointer : constant Nullable_Pointer;
   private
	  type Node is record
		 Count : Natural;
		 Value : not null access A;
	  end record;
	  type Ref is access all Node;
	  
	  type Refcounted_Pointer is new Ada.Finalization.Controlled and Binary_Streamable with record
		 Rep : Ref;
	  end record;

	  function Binary_Size(Item : in Refcounted_Pointer) return Int32;
	  procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Refcounted_Pointer);
	  procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Refcounted_Pointer);
	  
	  procedure Adjust (Obj : in out Refcounted_Pointer) with Inline;
	  procedure Finalize (Obj : in out Refcounted_Pointer);
	  
	  type Pointer is new Refcounted_Pointer with null record;
	  for Pointer'Write use Binary_Write;
	  for Pointer'Read use Binary_Read;
	  type Accessor(Data: not null access A) is new Refcounted_Pointer with null record;
	  
	  -- Nullable_Pointer for arrays has a special handling. Read/Write -1 if it is null.
	  type Nullable_Pointer is new Refcounted_Pointer with null record;
	  for Nullable_Pointer'Write use Binary_Write;
	  for Nullable_Pointer'Read use Binary_Read;
	  type Nullable_Accessor(Data: access A) is new Refcounted_Pointer with null record;
	  Null_Pointer : constant Nullable_Pointer := (Ada.Finalization.Controlled with Rep => null);
   end Elementary_Arrays;

   generic
   	  type T (<>) is new UA_Builtin with private;
   package UA_Builtin_Arrays is
	  package T_SP is new Types.Smart_Pointers.UA_Builtin_Smart_Pointers(T);
   	  type A is array (Array_Index range <>) of T_SP.Pointer;
	  
	  type Pointer is new Binary_Streamable with private;
	  type Accessor(Data: not null access A) is limited private with Implicit_Dereference => Data;
	  function Create (Value : not null access A) return Pointer with Inline;
	  function Get (Ptr : Pointer'Class) return Accessor with Inline;
	  
	  -- Nullable_Pointer for arrays has a special handling. Read/Write -1 if it is null.
	  type Nullable_Pointer is new Binary_Streamable with private;
	  type Nullable_Accessor (Data: access A) is limited private with Implicit_Dereference => Data;
	  function Create (Value : access A) return Nullable_Pointer;
	  function Get (Ptr : Nullable_Pointer'Class) return Nullable_Accessor with Inline;
	  function Is_Null(Ptr: Nullable_Pointer) return Boolean is (Ptr.Get.Data = null);
	  Null_Pointer : constant Nullable_Pointer;
   private
	  use T_SP;
	  
	  type Node is record
		 Count : Natural;
		 Value : not null access A;
	  end record;
	  type Ref is access all Node;

	  type Refcounted_Pointer is new Ada.Finalization.Controlled and Binary_Streamable with record
		 Rep : Ref;
	  end record;
   
	  procedure Adjust (Obj : in out Refcounted_Pointer) with Inline;
	  procedure Finalize (Obj : in out Refcounted_Pointer);
   
	  function Binary_Size(Item : in Refcounted_Pointer) return Int32;
	  procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Refcounted_Pointer);
	  procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Refcounted_Pointer);
	  
	  type Pointer is new Refcounted_Pointer with null record;
	  for Pointer'Write use Binary_Write;
	  for Pointer'Read use Binary_Read;
	  type Accessor(Data: not null access A) is new Refcounted_Pointer with null record;
	  
	  type Nullable_Pointer is new Refcounted_Pointer with null record;
	  for Nullable_Pointer'Write use Binary_Write;
	  for Nullable_Pointer'Read use Binary_Read;
	  type Nullable_Accessor(Data: access A) is new Refcounted_Pointer with null record;

	  Null_Pointer : constant Nullable_Pointer := (Ada.Finalization.Controlled with Rep => null);

   end UA_Builtin_Arrays;

end Types.Arrays;
