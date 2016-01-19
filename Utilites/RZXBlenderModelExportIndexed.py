bl_info = {
    "name": "Export Binary Raze Mesh Indexed (.mesh)",
    "author": "John Stricker",
    "location": "File > Export",
    "description": "Export Model Verts, Norms, & Texture Coords to Binary File with unique values and an indexed array",
    "category": "Import-Export"}

import bpy
from bpy.props import *
import mathutils, math, struct, time, sys
import bpy_extras
from bpy_extras.io_utils import ExportHelper

#model data object containing vertices[3], normals[3] and uniforms[2]
class mData(object):
    def __init__(self):
        self.v = [0.0, 0.0, 0.0]
        self.n = [0.0, 0.0, 0.0]
        self.u = [0.0, 0.0]

    def __hash__(self):
        return hash(str(self.v) + "-" + str(self.n) + "-" + str(self.u))

    def __eq__(self, other):
        return self.v == other.v and self.n == other.n and self.u == other.u

def do_export(context, props, filepath):
    scene = bpy.context.scene
    bpy.ops.object.mode_set(mode='OBJECT')
    obj = bpy.context.active_object
    
    #apply modifiers if requested
    if props.apply_modifiers:
        for i in range(0,len(obj.modifiers)):
            name = obj.modifiers[i].name
            bpy.ops.object.modifier_apply(modifier=name)

    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')

    #perform mesh modifications if requested
    if props.convert_to_tris:
        bpy.ops.mesh.quads_convert_to_tris()
    if props.world_space:
        obj.data.transform(ob.matrix_world)
    if props.rot_x90:
        mat_x90 = mathutils.Matrix.Rotation(-math.pi/2, 4, 'X')
        obj.data.transform(mat_x90)

    bpy.ops.object.mode_set(mode='OBJECT')

    obj.data.update(calc_tessface = True)

    # make sure that UV's have been applied
    if len(obj.data.tessface_uv_textures) < 1:
        print("UV coordinates were not found! Did you unwrap your mesh?")
        return False

    # build the raw vertex data
    dataList = []
    qDataSet = set()

    print("building list of vertex data...")
    
    start_time = time.time()
    if len(obj.data.tessface_uv_textures) > 0:
        #for face in uv: loop through the faces
        uv_layer = obj.data.tessface_uv_textures.active
        for face in obj.data.tessfaces:
            faceUV = uv_layer.data[face.index]
            i=0
            for index in face.vertices:
                if len(face.vertices) == 3:
                    vert = obj.data.vertices[index]

                    md = mData()
                    md.v[0] = vert.co.x
                    md.v[1] = vert.co.y
                    md.v[2] = vert.co.z
                    md.n[0] = vert.normal.x
                    md.n[1] = vert.normal.y
                    md.n[2] = vert.normal.z
                    md.u[0] = faceUV.uv[i][0]
                    md.u[1] = faceUV.uv[i][1] 
                    
                    dataList.append(md)
                    qDataSet.add(md)
                    i+=1

    qData = list(qDataSet)
    qDataDict = {}
    index = 0;
    indexes = []

    for dataObject in qData:
        qDataDict[dataObject] = index;
        index += 1;

    dataLength = len(dataList)
    i = 0
    print('finding and indexing unique vertices out of %i' %dataLength)

    for dataPoint in dataList:
        dataIndex = qDataDict[dataPoint]
        indexes.append(dataIndex)
        sys.stdout.write('\r%.2f%% complete              ' %(i / dataLength * 100))
        sys.stdout.flush()
        i+=1

    print('finished in %.2f seconds\n' %((time.time() - start_time)))
    print('%i unique verts found\n' %len(qData))

    file = open(filepath, "wb") 
    
    print('writing file...')

    # export the bounding box
    print("Exporting dimensions...")
    file.write(struct.pack('fff',bpy.context.active_object.dimensions.x, bpy.context.active_object.dimensions.y, bpy.context.active_object.dimensions.z))

    #number of indexes and then print them out
    file.write(struct.pack('i',len(indexes)))
    for index in indexes :
        file.write(struct.pack('H',index))
    #number of unique verts and then print them out
    file.write(struct.pack('i',len(qData)))
    for md in qData :
        data = struct.pack('ffffffff', md.v[0], md.v[1], md.v[2], md.n[0], md.n[1], md.n[2], md.u[0], md.u[1])
        file.write(data)     

    file.flush()
    file.close()

    bpy.ops.object.mode_set(mode='OBJECT')

    return True

    ###### EXPORT OPERATOR #######
class Export_objc(bpy.types.Operator, ExportHelper):
    '''Exports the active Object as a binary .mesh file with indexes.'''
    bl_idname = "export_object_indexed.objc"
    bl_label = "Export Binary Indexed (.mesh)"
    filename_ext = ".mesh"
    
    apply_modifiers = BoolProperty(name="Apply Modifiers",
                            description="Applies the Modifiers",
                            default=True)

    rot_x90 = BoolProperty(name="Convert to Y-up",
                            description="Rotate 90 degrees around X to convert to y-up",
                            default=False)
    
    world_space = BoolProperty(name="Export into Worldspace",
                            description="Transform the Vertexcoordinates into Worldspace",
                            default=False)

    convert_to_tris = BoolProperty(name="Convert quads to triangles",
                            description="Convert the mesh's quads to tris",
                            default =True)
    
    @classmethod
    def poll(cls, context):
        return context.active_object.type in ['MESH', 'CURVE', 'SURFACE', 'FONT']

    def execute(self, context):
        start_time = time.time()
        print('\n_____START_____')
        props = self.properties
        filepath = self.filepath
        filepath = bpy.path.ensure_ext(filepath, self.filename_ext)

        exported = do_export(context, props, filepath)
        
        if exported:
            print('finished export in %.2f seconds' %((time.time() - start_time)))
            print(filepath)
            
        return {'FINISHED'}

    def invoke(self, context, event):
        wm = context.window_manager

        if True:
            # File selector
            wm.fileselect_add(self) # will run self.execute()
            return {'RUNNING_MODAL'}
        elif True:
            # search the enum
            wm.invoke_search_popup(self)
            return {'RUNNING_MODAL'}
        elif False:
            # Redo popup
            return wm.invoke_props_popup(self, event) #
        elif False:
            return self.execute(context)


### REGISTER ###

def menu_func(self, context):
    self.layout.operator(Export_objc.bl_idname, text="Raze Mesh File (.mesh)")

def register():
    bpy.utils.register_module(__name__)

    bpy.types.INFO_MT_file_export.append(menu_func)

def unregister():
    bpy.utils.unregister_module(__name__)

    bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
    register()
