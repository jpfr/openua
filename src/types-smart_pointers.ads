private with Ada.Finalization;
with Ada.Streams;

package Types.Smart_Pointers with Pure is

   generic
	  type T is private;
   package Elementary_Smart_Pointers is
	  type Pointer is tagged private; -- Not Binary_Stremable. Use 'Write/'Read on Elementary Type.
	  type Accessor (Data: not null access T) is limited private with Implicit_Dereference => Data;
	  function Create (Value : not null access T) return Pointer with Inline;
	  function Get (Ptr : Pointer'Class) return Accessor with Inline;
	  
	  type Nullable_Pointer is tagged private; -- Not Binary_Streamable.
	  type Nullable_Accessor (Data: access T) is limited private with Implicit_Dereference => Data;
	  function Create (Value : access T) return Nullable_Pointer;
	  function Get (Ptr : Nullable_Pointer'Class) return Nullable_Accessor with Inline;
	  function Is_Null(Ptr: Nullable_Pointer) return Boolean is (Ptr.Get.Data = null) with Inline;
	  
	  Null_Pointer : constant Nullable_Pointer;
   private
	  type Node is record
		 Count : Natural;
		 Value : not null access T;
	  end record;
	  type Ref is access all Node;

	  type Refcounted_Pointer is new Ada.Finalization.Controlled with record
		 Rep : Ref;
	  end record;
	  
	  procedure Adjust (Obj : in out Refcounted_Pointer) with Inline;
	  procedure Finalize (Obj : in out Refcounted_Pointer);
	  
	  type Pointer is new Refcounted_Pointer with null record;
	  type Accessor(Data: not null access T) is new Refcounted_Pointer with null record;
	  type Nullable_Pointer is new Refcounted_Pointer with null record;
	  type Nullable_Accessor(Data: access T) is new Refcounted_Pointer with null record;

	  Null_Pointer : constant Nullable_Pointer := (Ada.Finalization.Controlled with Rep => null);
   end Elementary_Smart_Pointers;

   generic
	  type T (<>) is new UA_Builtin with private;
   package UA_Builtin_Smart_Pointers is
	  
	  type Pointer is new Binary_Streamable with private;
	  type Accessor (Data: not null access T) is limited private with Implicit_Dereference => Data;
	  function Create (Value : not null access T) return Pointer with Inline;
	  function Get (Ptr : Pointer'Class) return Accessor with Inline;
	  
	  type Nullable_Pointer is tagged private; -- Not Binary_Streamable. There is no standard way to serialized a null object into a stream.
	  type Nullable_Accessor (Data: access T) is limited private with Implicit_Dereference => Data;
	  function Create (Value : access T) return Nullable_Pointer;
	  function Get (Ptr : Nullable_Pointer'Class) return Nullable_Accessor with Inline;
	  function Is_Null(Ptr: Nullable_Pointer) return Boolean is (Ptr.Get.Data = null) with Inline;

	  Null_Pointer : constant Nullable_Pointer;
   private

	  type Node is record
		 Count : Natural;
		 Value : not null access T;
	  end record;
	  type Ref is access all Node;

	  type Refcounted_Pointer is new Ada.Finalization.Controlled with record
		 Rep : Ref;
	  end record;
	  
	  procedure Adjust (Obj : in out Refcounted_Pointer) with Inline;
	  procedure Finalize (Obj : in out Refcounted_Pointer);
	  
	  type Pointer is new Refcounted_Pointer and Binary_Streamable with null record;
	  function Binary_Size(Item : in Pointer) return Int32;
	  procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Pointer);
	  procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Pointer);
	  type Accessor(Data: not null access T) is new Refcounted_Pointer with null record;

	  type Nullable_Pointer is new Refcounted_Pointer with null record;
	  type Nullable_Accessor(Data: access T) is new Refcounted_Pointer with null record;

	  Null_Pointer : constant Nullable_Pointer := (Ada.Finalization.Controlled with Rep => null);

   end UA_Builtin_Smart_Pointers;

end Types.Smart_Pointers;
