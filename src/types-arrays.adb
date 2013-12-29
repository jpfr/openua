with Ada.Unchecked_Deallocation;

package body Types.Arrays is

   ------------------------
   --  Elementary_Array  --
   ------------------------
   package body Elementary_Arrays is

	  function Create (Value : not null access A) return Pointer is (Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Value.all'Unchecked_Access)));
	  function Get (Ptr : Pointer'Class) return Accessor is (Accessor'(Ada.Finalization.Controlled with Data => Ptr.Rep.Value, Rep => Ptr.Rep));

	  function Create (Value : access A) return Nullable_Pointer is
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
		 type P is access all A;
		 procedure Delete is new Ada.Unchecked_Deallocation (A, P);
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
				  N : P := P(Tmp.Value);
			   begin
				  Delete (N);
			   end;
			   Delete (Tmp);
			end if;
		 end if;
	  end Finalize;
	  
	  function Binary_Size(Item : in Refcounted_Pointer) return Int32 is
	  begin
		 if Item.Rep /= null then
			return 4;
		 else
			return (4 + (T'Size/8)*Item.Rep.Value.all'Length);
		 end if;
	  end Binary_Size;

	  procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Refcounted_Pointer) is
	  begin
		 if Item.Rep /= null then
			Integer'Write(Stream, Item.Rep.Value.all'Length);
			A'Write(Stream, Item.Rep.Value.all);
		 else
			Integer'Write(Stream, -1);
		 end if;
	  end Binary_Write;

	  procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Refcounted_Pointer) is
		 Size : constant Integer := Integer'Input(Stream); -- must be > 0
	  begin
		 if Size >= 0 then
			declare
			   subtype AST is A (Array_Index'First .. Array_Index'Val(Size-1));
			   Obj : constant access A := new AST;
			begin
			   AST'Read(Stream, Obj.all);
			   Item := Refcounted_Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Obj));
			end;
		 else
			Item := Refcounted_Pointer'(Ada.Finalization.Controlled with Rep => null);
		 end if;
	  end Binary_Read;
	  
   end Elementary_Arrays;
   
   ------------------------
   --  UA_Builtin_Arrays  --
   ------------------------
   package body UA_Builtin_Arrays is

	  function Create (Value : not null access A) return Pointer is (Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Value.all'Unchecked_Access)));
	  function Get (Ptr : Pointer'Class) return Accessor is (Accessor'(Ada.Finalization.Controlled with Data => Ptr.Rep.Value, Rep => Ptr.Rep));

	  function Create (Value : access A) return Nullable_Pointer is
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
		 type P is access all A;
		 procedure Delete is new Ada.Unchecked_Deallocation (A, P);
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
	  
	  function Binary_Size(Item : in Refcounted_Pointer) return Int32 is
		 Size : Int32 := 4;
	  begin
		 if Item.Rep /= null then
			return Size;
		 else
			for Elem of Item.Rep.Value.all loop
			   Size := Size + Binary_Size(Elem);
			end loop;
			return Size;
		 end if;
	  end Binary_Size;

	  procedure Binary_Write(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : in Refcounted_Pointer) is
	  begin
		 if Item.Rep /= null then
			Integer'Write(Stream, Item.Rep.Value.all'Length);
			for Elem of Item.Rep.Value.all loop
			   Binary_Write(Stream, Elem);
			end loop;
		 else
			Integer'Write(Stream, -1);
		 end if;
	  end Binary_Write;
	  
	  procedure Binary_Read(Stream : not null access Ada.Streams.Root_Stream_Type'Class; Item : out Refcounted_Pointer) is
		 Size : constant Integer := Integer'Input(Stream); -- must be > 0
	  begin
		 if Size > 0 then
			declare
			   subtype AST is A (Array_Index'First .. Array_Index'Val(Size-1));
			   Obj : constant access A := new AST;
			begin
			   for Elem of Obj.all loop
				  Binary_Read(Stream, Elem);
			   end loop;
			   Item := Refcounted_Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => Obj));
			end;
		 elsif Size = 0 then
			declare
			   Empty_A : A (Array_Index'Val(1) .. Array_Index'Val(0));
			begin
			   Item := Refcounted_Pointer'(Ada.Finalization.Controlled with Rep => new Node'(Count => 1, Value => new A'(Empty_A)));
			end;
		 else
			Item := Refcounted_Pointer'(Ada.Finalization.Controlled with Rep => null);
		 end if;
	  end Binary_Read;

   end UA_Builtin_Arrays;
   
end Types.Arrays;
