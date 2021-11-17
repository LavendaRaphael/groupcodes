import os
import local_module

list1d_key=[]
#list1d_key.append('111.x4y4z4_O4')
#list1d_key.append('110.x2y12z4.5_O22')
#list1d_key.append('110.x2y12z4.5_O22_aimd')
#list1d_key.append('110.x2y3z4.5_O1')
#list1d_key.append('110.x2y3z4.5_O2.12')
#list1d_key.append('110.x2y3z4.5_O2.13')
#list1d_key.append('110.x2y3z4.5_O2.14')
#list1d_key.append('110.x2y3z4.5_O3.123')
#list1d_key.append('110.x2y3z4.5_O3.135')
#list1d_key.append('110.x2y3z4.5_O3.136')
#list1d_key.append('110.x2y3z4.5_O4.v56')
list1d_key.append('110.x2y3z4.5_O5')
#list1d_key.append('110.x2y3z4.5_O6')
#list1d_key.append('110.x2y4z4.5_O2.15')
#list1d_key.append('110.x2y4z4.5_O2.16')
#list1d_key.append('110.x2y4z4.5_O4.1237')
#list1d_key.append('110.x2y6z4.5_O2.17_ym')
#list1d_key.append('110.x4y3z4.5_O2.12')
#list1d_key.append('110.x4y3z4.5_O6')

dict_structure = local_module.def_dict_structure()

for str_key in list1d_key:
    class_structure = dict_structure[ str_key ]
    str_chdir = class_structure.str_chdir + 'template/'
    os.chdir( str_chdir )
    print( os.getcwd() )

    local_module.def_render(
        list1d_bbox = class_structure.list1d_bbox,
    )

