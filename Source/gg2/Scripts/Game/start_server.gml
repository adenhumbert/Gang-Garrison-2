//Load optional map rotation, calculate respawn time and start game. Used from Host menus
var customMapRotationFile;
ini_open("gg2.ini");
customMapRotationFile = ini_read_string("Server", "MapRotation", "");
global.mapRotationFile = customMapRotationFile;

var iniMapRotation, mapsInDefaultOrderStr, mapsInDefaultOrder, mapIndex, mapName, mapDefaultPriority, mapPriority;
mapsInDefaultOrderStr = "ctf_truefort,ctf_2dfort,ctf_conflict,ctf_classicwell,ctf_waterway,ctf_orange,cp_dirtbowl,cp_egypt,arena_montane,arena_lumberyard,gen_destroy,koth_valley,koth_corinth,koth_harvest,dkoth_atalia,dkoth_sixties,tdm_mantic,ctf_avanti,koth_gallery,ctf_eiger";
mapsInDefaultOrder = split(mapsInDefaultOrderStr, ",");
iniMapRotation = ds_priority_create();

for(mapIndex = 0; mapIndex < ds_list_size(mapsInDefaultOrder); mapIndex += 1)
{
    mapName = ds_list_find_value(mapsInDefaultOrder, mapIndex);
    mapDefaultPriority = mapIndex + 1;
    mapPriority = ini_read_real("Maps", mapName, mapDefaultPriority);
    ini_write_real("Maps", mapName, mapPriority);
    if(mapPriority != 0)
        ds_priority_add(iniMapRotation, mapName, mapPriority);
}

ds_list_destroy(mapsInDefaultOrder);
ini_close();

while(!ds_priority_empty(iniMapRotation))
    ds_list_add(global.map_rotation, ds_priority_delete_min(iniMapRotation));
    
ds_priority_destroy(iniMapRotation);

// if the user defined a valid map rotation file, then override the gg2.ini map rotation and load from there
if ((customMapRotationFile != "") and file_exists(customMapRotationFile))
{
    ds_list_clear(global.map_rotation);
    var fileHandle, i, mapname;
    fileHandle = file_text_open_read(customMapRotationFile);
    for(i = 1; !file_text_eof(fileHandle); i += 1) {
        mapname = trim(file_text_read_string(fileHandle));
        if(mapname != "" and string_char_at(mapname, 0) != "#") { // if it's not blank and it's not a comment (starting with #)
            ds_list_add(global.map_rotation, mapname);
        }
        file_text_readln(fileHandle);
    }
    file_text_close(fileHandle);
}

//Server respawn time calculator. Converts each second to a frame. (read: multiply by 30 :hehe:)
if (global.Server_RespawntimeSec == 0)
    global.Server_Respawntime = 1;
else
    global.Server_Respawntime = global.Server_RespawntimeSec * 30;

global.gameServer = instance_create(0,0,GameServer);