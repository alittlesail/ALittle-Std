-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___pairs = pairs
local ___ipairs = ipairs

ALittle.RegStruct(839664979, "ALittle.PathAttribute", {
name = "ALittle.PathAttribute", ns_name = "ALittle", rl_name = "PathAttribute", hash_code = 839664979,
name_list = {"directory","size"},
type_list = {"bool","int"},
option_map = {}
})

ALittle.IFileLoader = Lua.Class(nil, "ALittle.IFileLoader")

function ALittle.IFileLoader:Load(file_path)
	return nil
end

assert(ALittle.IFileLoader, " extends class:ALittle.IFileLoader is nil")
ALittle.LuaFileLoader = Lua.Class(ALittle.IFileLoader, "ALittle.LuaFileLoader")

function ALittle.LuaFileLoader:Load(file_path)
	local file = io.open(file_path, "r")
	if file == nil then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

ALittle.IFileSaver = Lua.Class(nil, "ALittle.IFileSaver")

function ALittle.IFileSaver:Save(file_path, content)
	return false
end

assert(ALittle.IFileSaver, " extends class:ALittle.IFileSaver is nil")
ALittle.LuaFileSaver = Lua.Class(ALittle.IFileSaver, "ALittle.LuaFileSaver")

function ALittle.LuaFileSaver:Save(file_path, content)
	local file = io.open(file_path, "w")
	if file == nil then
		return false
	end
	file:write(content)
	file:close()
	return true
end

function ALittle.File_GetCurrentPath()
	return carp.GetCurrentPath()
end

function ALittle.File_GetAllDriver()
	return carp.GetDriveStrings()
end

function ALittle.File_SetCurrentPath(path)
	return carp.SetCurrentPath(path)
end

function ALittle.File_RenameFile(path, new_path)
	return os.rename(path, new_path)
end

function ALittle.File_DeleteFile(path)
	return os.remove(path)
end

function ALittle.File_GetFileAttr(path)
	return carp.GetPathAttribute(path)
end

function ALittle.File_GetFileAttrByDir(path, file_map)
	do
		if file_map == nil then
			file_map = {}
		end
		local file_list = carp.GetFileNameListInFolder(path)
		for index, file in ___ipairs(file_list) do
			local file_path = path .. "/" .. file
			file_map[file_path] = carp.GetPathAttribute(file_path)
		end
		local folder_list = carp.GetFolderNameListInFolder(path)
		for index, file in ___ipairs(folder_list) do
			local file_path = path .. "/" .. file
			ALittle.File_GetFileAttrByDir(file_path, file_map)
		end
		return file_map
	end
end

function ALittle.File_GetFileListByDir(path, out_list)
	do
		if out_list == nil then
			out_list = {}
		end
		local file_list = carp.GetFileNameListInFolder(path)
		for index, file in ___ipairs(file_list) do
			local file_path = path .. "/" .. file
			ALittle.List_Push(out_list, file_path)
		end
		local folder_list = carp.GetFolderNameListInFolder(path)
		for index, file in ___ipairs(folder_list) do
			local file_path = path .. "/" .. file
			ALittle.File_GetFileListByDir(file_path, out_list)
		end
		return out_list
	end
end

function ALittle.File_GetNameListByDir(path, file_map)
	do
		if file_map == nil then
			file_map = {}
		end
		local file_list = carp.GetFileNameListInFolder(path)
		for index, file in ___ipairs(file_list) do
			local file_path = path .. "/" .. file
			file_map[file] = carp.GetPathAttribute(file_path)
		end
		local folder_list = carp.GetFolderNameListInFolder(path)
		for index, file in ___ipairs(folder_list) do
			local file_path = path .. "/" .. file
			file_map[file] = carp.GetPathAttribute(file_path)
		end
		return file_map
	end
end

function ALittle.File_DeleteDir(path)
	carp.DeleteFolder(path)
end

function ALittle.File_DeleteDeepDir(path, log_path)
	do
		if path == nil or path == "" then
			return
		end
		if ALittle.File_GetFileAttr(path) == nil then
			return
		end
		local file_list = carp.GetFileNameListInFolder(path)
		for index, file in ___ipairs(file_list) do
			local file_path = path .. "/" .. file
			ALittle.File_DeleteFile(file_path)
			if log_path then
				ALittle.Log("delete file:", file_path)
			end
		end
		local folder_list = carp.GetFolderNameListInFolder(path)
		for index, file in ___ipairs(folder_list) do
			local file_path = path .. "/" .. file
			ALittle.File_DeleteDeepDir(file_path, log_path)
		end
		ALittle.File_DeleteDir(path)
	end
end

function ALittle.File_CopyFile(src_path, dst_path)
	return carp.CopyFile(src_path, dst_path, false)
end

function ALittle.File_CopyDeepDir(src_path, dest_path, ext, log)
	do
		local upper_ext = nil
		if ext ~= nil then
			upper_ext = string.upper(ext)
		end
		local file_list = carp.GetFileNameListInFolder(src_path)
		for index, file in ___ipairs(file_list) do
			local src_file_path = src_path .. "/" .. file
			local dest_file_path = dest_path .. "/" .. file
			if upper_ext == nil or ALittle.File_GetFileExtByPathAndUpper(src_file_path) == upper_ext then
				ALittle.File_CopyFile(src_file_path, dest_file_path)
				if log then
					ALittle.Log("copy file:", src_file_path, dest_file_path)
				end
			end
		end
		local folder_list = carp.GetFolderNameListInFolder(src_path)
		for index, file in ___ipairs(folder_list) do
			local src_file_path = src_path .. "/" .. file
			local dest_file_path = dest_path .. "/" .. file
			carp.CreateFolder(dest_file_path)
			ALittle.File_CopyDeepDir(src_file_path, dest_file_path, upper_ext, log)
		end
	end
end

function ALittle.File_MakeDir(path)
	carp.CreateFolder(path)
end

function ALittle.File_MakeDeepDir(path)
	local path_list = ALittle.String_SplitSepList(path, {"/", "\\"})
	local cur_path = ""
	for index, sub_path in ___ipairs(path_list) do
		cur_path = cur_path .. sub_path
		ALittle.File_MakeDir(cur_path)
		cur_path = cur_path .. "/"
	end
end

function ALittle.File_PathEndWithSplit(file_path)
	local len = ALittle.String_Len(file_path)
	if len == 0 then
		return file_path
	end
	local byte = ALittle.String_Byte(file_path, len)
	if byte == 47 or byte == 92 then
		return file_path
	end
	if ALittle.String_Find(file_path, "\\") ~= nil then
		return file_path .. "\\"
	end
	return file_path .. "/"
end

function ALittle.File_GetFileNameByPath(file_path)
	local list = ALittle.String_SplitSepList(file_path, {"/", "\\"})
	local l = ALittle.List_Len(list)
	if l <= 0 then
		return file_path
	end
	return list[l]
end

function ALittle.File_GetFilePathByPath(file_path)
	local new_file_path = ALittle.File_GetFileNameByPath(file_path)
	return ALittle.String_Sub(file_path, 1, -ALittle.String_Len(new_file_path) - 2)
end

function ALittle.File_GetFileExtByPath(file_path)
	local list = ALittle.String_Split(file_path, ".")
	local l = ALittle.List_Len(list)
	if l <= 0 then
		return file_path
	end
	return list[l]
end

function ALittle.File_ChangeFileExtByPath(file_path, ext)
	local list = ALittle.String_Split(file_path, ".")
	local l = ALittle.List_Len(list)
	if l <= 0 then
		return file_path .. "." .. ext
	end
	list[l] = ext
	return ALittle.String_Join(list, ".")
end

function ALittle.File_GetFileExtByPathAndUpper(file_path)
	return ALittle.String_Upper(ALittle.File_GetFileExtByPath(file_path))
end

function ALittle.File_GetJustFileNameByPath(file_path)
	local new_file_path = ALittle.File_GetFileNameByPath(file_path)
	local list = ALittle.String_Split(new_file_path, ".")
	local l = ALittle.List_Len(list)
	if l <= 1 then
		return new_file_path
	end
	if l == 2 then
		return list[1]
	end
	ALittle.List_Remove(list, l)
	return ALittle.String_Join(list, ".")
end

function ALittle.File_ReadJsonFromStdFile(file_path)
	do
		local file = io.open(file_path, "rb")
		if file == nil then
			return nil, file_path .. " load failed"
		end
		local content = file:read("*a")
		file:close()
		local error, new_content = Lua.TCall(cjson.decode, content)
		if error == nil then
			return new_content, content
		end
		return nil, new_content
	end
end

function ALittle.File_WriteJsonFromStdFile(content, file_path)
	do
		local file = io.open(file_path, "wb")
		if file == nil then
			return false
		end
		file:write(cjson.encode(content))
		file:close()
		return true
	end
end

function ALittle.File_ReadTextFromStdFile(file_path)
	do
		local file = io.open(file_path, "rb")
		if file == nil then
			return nil
		end
		local content = file:read("*a")
		file:close()
		return content
	end
end

function ALittle.File_WriteTextToStdFile(content, file_path)
	do
		local file = io.open(file_path, "wb")
		if file == nil then
			return false
		end
		file:write(content)
		file:close()
		return true
	end
end

end