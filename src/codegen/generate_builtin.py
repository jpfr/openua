import sys
from collections import OrderedDict
import re
from lxml import etree

if len(sys.argv) != 2:
    print "Usage: python generate_builtin.py <path/to/Opc.Ua.Types.bsd>"
    exit(0)

# types that are coded manually
exclude_types = set(["Boolean", "SByte", "Byte", "Int16", "UInt16", "Int32", "UInt32",
                    "Int64", "UInt64", "Float", "Double", "String", "DateTime", "Guid",
                    "ByteString", "XmlElement", "NodeId", "ExpandedNodeId", "StatusCode",
                    "QualifiedName", "LocalizedText", "ExtensionObject", "DataValue",
                     "Variant", "DiagnosticInfo", "RequestHeader", "ResponseHeader", "NodeIdType"])

elementary_size = dict()
elementary_size["Boolean"] = 1;
elementary_size["SByte"] = 1;
elementary_size["Byte"] = 1;
elementary_size["Int16"] = 2;
elementary_size["UInt16"] = 2;
elementary_size["Int32"] = 4;
elementary_size["UInt32"] = 4;
elementary_size["Int64"] = 8;
elementary_size["UInt64"] = 8;
elementary_size["Float"] = 4;
elementary_size["Double"] = 8;
elementary_size["DateTime"] = 8;
elementary_size["StatusCode"] = 4;

indefinite_types = ["NodeId", "ExpandedNodeId", "QualifiedName", "LocalizedText", "ExtensionObject", "DataValue", "Variant", "DiagnosticInfo"]
enum_types = []
                   
# indefinite types cannot be directly contained in a record as they don't have a definite size
printed_types = exclude_types # types that were already printed and which we can use in the structures to come

# types we do not want to autogenerate
def skipType(name):
    if name in exclude_types:
        return True
    if re.search("NodeId$", name) != None:
        return True
    return False

def stripTypename(tn):
    return tn[tn.find(":")+1:]

def camlCase2AdaCase(item):
    (newitem, n) = re.subn("(?<!^)(?<![A-Z])([A-Z])", "_\\1", item)
    return newitem

# are the prerequisites in place? if not, postpone.
def printableStructuredType(element):
    for child in element:
        if child.tag ==  "{http://opcfoundation.org/BinarySchema/}Field":
            typename = stripTypename(child.get("TypeName"))
            if typename not in printed_types:
                return False
    return True

# There three types of types in the bsd file:
# StructuredType, EnumeratedType OpaqueType

def createEnumerated(element):
    valuemap = OrderedDict()
    name = element.get("Name")
    enum_types.append(name)
    print "-- " + name
    for child in element:
        if child.tag == "{http://opcfoundation.org/BinarySchema/}Documentation":
            print "-- " + child.text
        if child.tag ==  "{http://opcfoundation.org/BinarySchema/}EnumeratedValue":
            valuemap[name + "_" + child.get("Name")] = child.get("Value")
    valuemap = OrderedDict(sorted(valuemap.iteritems(), key=lambda (k,v): int(v)))
    print "type " + name + " is (" + ",\n".join(valuemap.keys()) + ");"
    print "for " + name + "'Size use " + element.get("LengthInBits") + ";"
    print "for " + name + " use (" + ",\n".join(map(lambda (key, value) : key + " => " + value, valuemap.iteritems())) + ");\n"
    return
    
def createStructured(element):
    valuemap = OrderedDict()
    name = element.get("Name")
    print "-- " + name

    lengthfields = set()
    for child in element:
        if child.get("LengthField"):
            lengthfields.add(child.get("LengthField"))
    
    for child in element:
        if child.tag == "{http://opcfoundation.org/BinarySchema/}Documentation":
            print "-- " + child.text
        elif child.tag == "{http://opcfoundation.org/BinarySchema/}Field":
            if child.get("Name") in lengthfields:
                continue
            childname = camlCase2AdaCase(child.get("Name"))
            if childname in printed_types:
                childname = childname + "_Value" # attributes may not have the name of a type
            typename = stripTypename(child.get("TypeName"))
            if childname == "Response_Header" or childname == "Request_Header":
                continue
            if typename in indefinite_types:
                valuemap[childname] = typename + "s.Pointer"
            elif child.get("LengthField"):
                valuemap[childname] = "ListOf" + typename + ".Pointer"
            else:
                valuemap[childname] = typename

    if "Response" in name[len(name)-9:]:
        print("type " + name + " is new Response_Base with "),
    elif "Request" in name[len(name)-9:]:
        print ("type " + name + " is new Request_Base with "),
    else:
        print ("type " + name + " is new UA_Builtin with "),
    if len(valuemap) > 0:
        print "record"
        for n,t in valuemap.iteritems():
            print n + " : " + t + ";"
        print "end record;"
    else:
        print "null record;"
    print "function NodeId_Nr(Item : in " + name + ") return UInt16 is (SID." + name + "_Id);" # increase id by 2 to get the binary_encoding id
    if "Response" in name[len(name)-9:]:
        print("function Binary_Size(Item : " + name + ") return Int32 is ( Binary_Size(Item.Response_Header)"), 
    elif "Request" in name[len(name)-9:]:
        print("function Binary_Size(Item : " + name + ") return Int32 is ( Binary_Size(Item.Request_Header)"), 
    else:
        print("function Binary_Size(Item : " + name + ") return Int32 is ( 0"), # 0 for the null records
    for n,t in valuemap.iteritems():
        if t in elementary_size:
            print('+ ' + str(elementary_size[t])),
        else:
            if t in enum_types:
                print('+ 8') # enums are all 32 bit
            elif t.find(".Pointer") != -1 or t.find("ListOf") != -1:
                print('+ ' + t[0:t.find(".")+1] + 'Binary_Size(Item.' + n + ')'),
            else:
                print('+ Binary_Size(Item.' + n + ')'),
    print ");\n"
        
def createOpaque(element):
    name = element.get("Name")
    print "type " + name + " is new Bytes.Pointer with null record;"
    print "function NodeId_Nr(Item : in " + name + ") return UInt16 is (SID." + name + "_Id);\n"
    return

ns = {"opc": "http://opcfoundation.org/BinarySchema/"}
tree = etree.parse(sys.argv[1])
types = tree.xpath("/opc:TypeDictionary/*[not(self::opc:Import)]", namespaces=ns)

# types for which we create a vector type
arraytypes = set()
fields = tree.xpath("//opc:Field", namespaces=ns)
for field in fields:
    if field.get("LengthField"):
        arraytypes.add(stripTypename(field.get("TypeName")))

deferred_types = OrderedDict()

for element in types:
    name = element.get("Name")
    if skipType(name):
        continue
        
    if element.tag == "{http://opcfoundation.org/BinarySchema/}EnumeratedType":
        createEnumerated(element)
        printed_types.add(name)
    elif element.tag == "{http://opcfoundation.org/BinarySchema/}StructuredType":
        if printableStructuredType(element):
            createStructured(element)
            printed_types.add(name)
        else: # the record contains types that were not yet detailed
            deferred_types[name] = element
            continue
    elif element.tag == "{http://opcfoundation.org/BinarySchema/}OpaqueType":
        createOpaque(element)
        printed_types.add(name)

    if name in arraytypes:
        print "package ListOf" + name + " is new Types.Arrays.UA_Builtin_Arrays(" + name + ");\n"

for name, element in deferred_types.iteritems():
    createStructured(element)
    if name in arraytypes:
        print "package ListOf" + name + " is new Types.Arrays.UA_Builtin_Arrays(" + name + ");\n"
