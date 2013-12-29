with Ada.Unchecked_Deallocation;

package body Types.Smart_Pointers is
   
   ---------------------------------
   --  Elementary_Smart_Pointers  --
   ---------------------------------
   package body Elementary_Smart_Pointers is

	  function Create (Value : not null access T) return Pointer is (Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Value.all'Unchecked_Access)));
	  function Get (Ptr : Pointer'Class) return Accessor is (Accessor'(Ada.Finalization.Controlled with Data => Ptr.Rep.Value, Rep => Ptr.Rep));

	  function Create (Value : access T) return Nullable_Pointer is
	  begin
		 if Value /= null then
		   return Nullable_Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Value.all'Unchecked_Access));
		 else
			return Null_Pointer;
		 end if;
	  end Create;

	  function Get (Ptr : Nullable_Pointer'Class) return Nullable_Accessor is
	  begin
		 if Ptr.Rep /= null then
			return Nullable_Accessor'(Ada.Finalization.Controlled with Data => Ptr.Rep.Value, Rep => Ptr.Rep);
		 else
			return Nullable_Accessor'(Ada.Finalization.Controlled with Data => null, Rep => null);
		 end if;
	  end Get;
	  
	  procedure Adjust (Obj : in out Refcounted_Pointer) is
	  begin
		 if Obj.Rep /= null then
			Obj.Rep.Count := Obj.Rep.Count + 1;
		 end if;
	  end Adjust;

	  procedure Finalize (Obj : in out Refcounted_Pointer) is
		 type P is access all T;
		 procedure Delete is new Ada.Unchecked_Deallocation (T, P);
		 procedure Delete is new Ada.Unchecked_Deallocation (Node, Ref);
		 Tmp : Ref := Obj.Rep;
	  begin
		 Obj.Rep := null;
		 if Tmp /= null then
			-- lock
			Tmp.Count := Tmp.Count - 1;
			-- unlock
			if Tmp.Count = 0 then
			   declare
				  N : P := Tmp.Value.all'Access;
			   begin
				  Delete (N);
			   end;
			   Delete (Tmp);
			end if;
		 end if;
	  end Finalize;

   end Elementary_Smart_Pointers;

   ---------------------------------
   --  UA_Builtin_Smart_Pointers  --
   ---------------------------------
   package body UA_Builtin_Smart_Pointers is
	  function Create (Value : not null access T) return Pointer is (Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Value.all'Unchecked_Access)));
	  function Get (Ptr : Pointer'Class) return Accessor is (Accessor'(Ada.Finalization.Controlled with Data => Ptr.Rep.Value, Rep => Ptr.Rep));

	  function Create (Value : access T) return Nullable_Pointer is
	  begin
		 if Value /= null then
		   return Nullable_Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Value.all'Unchecked_Access));
		 else
			return Null_Pointer;
		 end if;
	  end Create;

	  function Get (Ptr : Nullable_Pointer'Class) return Nullable_Accessor is
	  begin
		 if Ptr.Rep /= null then
			return Nullable_Accessor'(Ada.Finalization.Controlled with Data => Ptr.Rep.Value, Rep => Ptr.Rep);
		 else
			return Nullable_Accessor'(Ada.Finalization.Controlled with Data => null, Rep => null);
		 end if;
	  end Get;
	  
	  procedure Adjust (Obj : in out Refcounted_Pointer) is
	  begin
		 if Obj.Rep /= null then
			Obj.Rep.Count := Obj.Rep.Count + 1;
		 end if;
	  end Adjust;

	  procedure Finalize (Obj : in out Refcounted_Pointer) is
		 type P is access all T;
		 procedure Delete is new Ada.Unchecked_Deallocation (T, P);
		 procedure Delete is new Ada.Unchecked_Deallocation (Node, Ref);
		 Tmp : Ref := Obj.Rep;
	  begin
		 Obj.Rep := null;
		 if Tmp /= null then
			-- lock
			Tmp.Count := Tmp.Count - 1;
			-- unlock
			if Tmp.Count = 0 then
			   declare
				  N : P := Tmp.Value.all'Access;
			   begin
				  Delete (N);
			   end;
			   Delete (Tmp);
			end if;
		 end if;
	  end Finalize;
	  
	  function Binary_Size(Item : in Pointer) return Int32 is (Binary_Size(Item.Rep.Value.all));

	  procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Pointer) is
	  begin
		 Binary_Write(Stream, Item.Rep.Value.all);
	  end Binary_Write;

	  procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Pointer) is
	  begin
		 Item := Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => new T'(T'Input(Stream))));
	  end Binary_Read;
	  
   end UA_Builtin_Smart_Pointers;

end Types.Smart_Pointers;
