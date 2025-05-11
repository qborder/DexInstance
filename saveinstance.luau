--!native
--!optimize 2
--!divine-intellect
-- https://discord.gg/wx4ThpAsmw

local function string_find(s, pattern)
	return string.find(s, pattern, nil, true)
end

local function ArrayToDict(t, hydridMode, valueOverride, typeStrict)
	local tmp = {}

	if hydridMode then
		for any1, any2 in t do
			if type(any1) == "number" then
				tmp[any2] = valueOverride or true
			elseif type(any2) == "table" then
				tmp[any1] = ArrayToDict(any2, hydridMode) -- any1 is Class, any2 is Name
			else
				tmp[any1] = any2
			end
		end
	else
		for _, key in t do
			if not typeStrict or typeStrict and type(key) == typeStrict then
				tmp[key] = true
			end
		end
	end

	return tmp
end

local global_container
do
	local filename = "UniversalMethodFinder"

	local finder
	finder, global_container = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
		filename
	)()

	finder({
		base64encode = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"encode")and(c(b,"base64")or c(string.lower(tostring(a[2])),"base64"))',
		gethiddenproperty = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"prop",nil,true) and string.sub(...,#...) ~= "s"',
		gethui = 'string.find(...,"get",nil,true) and string.find(...,"h",nil,true) and string.find(...,"ui",nil,true)',
		getcon = 'string.find(...,"get",nil,true) and (string.find(...,"conn",nil,true) or string.find(...,"sig",nil,true)) and string.sub(...,#(...))=="s"',
		getnilinstances = 'string.find(...,"nil",nil,true) and string.find(...,"get",nil,true) and string.sub(...,#...) == "s"',
		getscriptbytecode = 'string.find(...,"get",nil,true) and string.find(...,"bytecode",nil,true)',
		hash = 'local a={...}local b=a[1]local function c(a,b)return string.find(a,b,nil,true)end;return c(b,"hash")and c(string.lower(tostring(a[2])),"crypt")',
		protectgui = 'string.find(...,"protect",nil,true) and string.find(...,"ui",nil,true) and not string.find(...,"un",nil,true)',
		setthreadidentity = 'string.find(...,"identity",nil,true) and string.find(...,"set",nil,true)',
	}, true, 10)
end

local identify_executor = identifyexecutor or getexecutorname or whatexecutor

local EXECUTOR_NAME = identify_executor and identify_executor() or ""

local gethiddenproperty = global_container.gethiddenproperty

local appendfile = appendfile
local readfile = readfile
local writefile = writefile

local getscriptbytecode = global_container.getscriptbytecode
local base64encode = global_container.base64encode
local sha384

local service = setmetatable({}, {
	__index = function(self, serviceName)
		local o, s = pcall(Instance.new, serviceName)
		local Service = o and s
			or game:GetService(serviceName)
			or settings():GetService(serviceName)
			or UserSettings():GetService(serviceName)

		if Service then
			self[serviceName] = Service
		end
		return Service
	end,
})

local gethiddenproperty_fallback
do
	local UGCValidationService

	gethiddenproperty_fallback = function(instance, propertyName)
		if not UGCValidationService then
			UGCValidationService = service.UGCValidationService
		end
		return UGCValidationService:GetPropertyValue(instance, propertyName)
	end

	if gethiddenproperty then
		local o, r = pcall(gethiddenproperty, workspace, "StreamOutBehavior")
		if not o or r ~= nil and typeof(r) ~= "EnumItem" then
			gethiddenproperty = nil
		else
			o, r = pcall(gethiddenproperty, Instance.new("AnimationRigData", Instance.new("Folder")), "parent")
			if o and r ~= nil and type(r) ~= "string" then
				gethiddenproperty = nil
			end
		end
	end

	local function benchmark(f1, f2, ...)
		local ranking = table.create(2)
		for i, f in { f1, f2 } do
			local start = os.clock()
			for _ = 1, 50 do
				f(...)
			end
			ranking[i] = { t = os.clock() - start, f = f }
		end
		table.sort(ranking, function(a, b)
			return a.t < b.t
		end)
		return ranking[1].f
	end

	local test_str = string.rep("\1\0\0\0\1\2\3\4\5\6\7", 50)

	do
		if not bit32.byteswap or not pcall(bit32.byteswap, 1) then
			bit32 = table.clone(bit32)
            local MODULO_32_BIT = 2^32
			local function tobit_internal(num) -- Renamed to avoid conflict if 'tobit' is global
				num = num % MODULO_32_BIT
				if num >= 0x80000000 then -- Check if it's in the negative range for a signed 32-bit int
					num = num - MODULO_32_BIT
				end
				return num
			end

			bit32.byteswap = function(num)
                num = num % MODULO_32_BIT -- Ensure num is within 32-bit unsigned range for byte extraction

				local b0 = bit32.band(num, 0xFF) -- LSB
				local b1 = bit32.band(bit32.rshift(num, 8), 0xFF)
				local b2 = bit32.band(bit32.rshift(num, 16), 0xFF)
				local b3 = bit32.band(bit32.rshift(num, 24), 0xFF) -- MSB

                -- Reconstruct with b0 as MSB and b3 as LSB
				local swapped = bit32.bor(
					bit32.lshift(b0, 24),
					bit32.lshift(b1, 16),
					bit32.lshift(b2, 8),
					b3
				)
				return tobit_internal(swapped) -- Convert to signed representation if necessary for consistency
			end
			table.freeze(bit32)
		end

		if EXECUTOR_NAME == "Delta" then
			base64encode = nil
		end

		local reselim_base64encode
		pcall(function()
			local b64_enc_buf = loadstring(
				game:HttpGet("https://raw.githubusercontent.com/Reselim/Base64/master/Base64.lua", true),
				"Base64"
			)().encode
			reselim_base64encode = function(raw)
				return buffer.tostring(b64_enc_buf(buffer.fromstring(raw)))
			end
		end)

		if base64encode and base64encode("\1\0\0\0\1") == "AQAAAAE=" then
			if reselim_base64encode then
				base64encode = benchmark(base64encode, reselim_base64encode, test_str)
			end
		else
			base64encode = reselim_base64encode
		end
		assert(base64encode, "base64encode not found")
	end

	do
		local hash_fn = global_container.hash -- Renamed to avoid conflict
		if hash_fn then
			sha384 = function(data)
				return hash_fn(data, "sha384")
			end
		end

		local filename = "RequireOnlineModule"
		local hashlib_sha384
		pcall(function()
			hashlib_sha384 = loadstring(
				game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
				filename
			)()(4544052033).sha384
		end)

		if hashlib_sha384 then
			if sha384 then
				sha384 = benchmark(sha384, hashlib_sha384, test_str)
			else
				sha384 = hashlib_sha384
			end
		end
		assert(sha384, "sha384 hash function not found")
	end
end

local SharedStrings = {}
local SharedString_identifiers = setmetatable({
	identifier = 1e15,
}, {
	__index = function(self, str_val) -- Renamed 'str' to 'str_val'
		local Identifier = base64encode(tostring(self.identifier))
		self.identifier += 1
		self[str_val] = Identifier
		return Identifier
	end,
})

local inherited_properties = {}
local default_instances = {}
local referents, ref_size = {}, 0

local function __BIT(...)
	local Value = 0
	for i, bit_val in ipairs({...}) do -- Use ipairs for sequential arrays
		if bit_val then
			Value += 2 ^ (i - 1)
		end
	end
	return Value
end

local function GetRef(instance)
	local ref = referents[instance]
	if not ref then
		ref = "RBX" .. string.upper(string.gsub(service.HttpService:GenerateGUID(false), "-", "")) .. tostring(ref_size) -- More compliant referent format
		referents[instance] = ref
		ref_size += 1 -- Keep original ref_size for uniqueness if GUIDs collide (highly unlikely)
	end
	return ref
end

local function index(self, index_name)
	return self[index_name]
end

local CLIENT_VERSION_STR = version()
local CLIENT_VERSION = tonumber(string.split(CLIENT_VERSION_STR, ".")[2])


-- Binary Serialization Data Type IDs (subset, for attribute serialization and future expansion)
local attr_Type_IDs = {
	string = 0x02, boolean = 0x03, number = 0x06, UDim = 0x09, UDim2 = 0x0A, Ray = 0x0B,
	Faces = 0x0C, Axes = 0x0D, BrickColor = 0x0E, Color3 = 0x0F, Vector2 = 0x10, Vector3 = 0x11,
	Vector2int16 = 0x12, Vector3int16 = 0x13, CFrame = 0x14, EnumItem = 0x15, NumberSequence = 0x17,
	ColorSequence = 0x19, NumberRange = 0x1B, Rect = 0x1C, PhysicalProperties = 0x1D,
	Region3 = 0x1F, Region3int16 = 0x20, Font = 0x21,
    -- float (0x05), int32 (0x04) might be needed for full binary
}
-- CFrame specific rotation matrix IDs for binary compression
local CFrame_Rotation_IDs = {
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x02,
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x03,
	["\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x05,
	["\0\0\128\63\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x06,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x07,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x09,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x0a,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x0c,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x0d,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x0e,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\63\0\0\0\0\0\0\0\0"] = 0x10,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\128"] = 0x11,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x14,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\128"] = 0x15,
	["\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x17,
	["\0\0\128\191\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\191\0\0\0\128"] = 0x18,
	["\0\0\0\0\0\0\128\63\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63"] = 0x19,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0"] = 0x1b,
	["\0\0\0\0\0\0\128\191\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\128\0\0\0\0\0\0\0\0\0\0\128\191"] = 0x1c,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0"] = 0x1e,
	["\0\0\0\0\0\0\128\63\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\191\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x1f,
	["\0\0\0\0\0\0\0\0\0\0\128\63\0\0\0\0\0\0\128\63\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x20,
	["\0\0\0\0\0\0\128\191\0\0\0\0\0\0\0\0\0\0\0\0\0\0\128\63\0\0\128\191\0\0\0\0\0\0\0\0"] = 0x22,
	["\0\0\0\0\0\0\0\0\0\0\128\191\0\0\0\0\0\0\128\191\0\0\0\128\0\0\128\191\0\0\0\0\0\0\0\128"] = 0x23,
}

local Binary_Descriptors
Binary_Descriptors = {
	__SEQUENCE = function(raw, valueFormatter, keypointSize, Envelope)
		local Keypoints = raw.Keypoints
		local Keypoints_n = #Keypoints
		local len = 4 + (keypointSize or 12) * Keypoints_n
		local b = buffer.create(len)
		local offset = 0
		buffer.writeu32(b, offset, Keypoints_n)
		offset += 4
		for _, keypoint in ipairs(Keypoints) do
			buffer.writef32(b, offset, Envelope or keypoint.Envelope)
			offset += 4
			buffer.writef32(b, offset, keypoint.Time)
			offset += 4
			local Value = keypoint.Value
			if valueFormatter then
				offset += valueFormatter(Value, b, offset)
			else
				buffer.writef32(b, offset, Value)
				offset += 4
			end
		end
		return b, len
	end,
	["string"] = function(raw_str) -- Renamed
		local raw_len = #raw_str
		local len = 4 + raw_len
		local b = buffer.create(len)
		buffer.writeu32(b, 0, raw_len)
		buffer.writestring(b, 4, raw_str)
		return b, len
	end,
	["boolean"] = function(raw_bool) -- Renamed
		local b = buffer.create(1)
		buffer.writeu8(b, 0, raw_bool and 1 or 0)
		return b, 1
	end,
	["number"] = function(raw_num) -- Renamed (double)
		local b = buffer.create(8)
		buffer.writef64(b, 0, raw_num)
		return b, 8
	end,
    ["float"] = function(raw_float) -- Added for explicit float (Float32)
        local b = buffer.create(4)
        buffer.writef32(b, 0, raw_float)
        return b, 4
    end,
    ["int"] = function(raw_int) -- Added for explicit int (Int32)
        local b = buffer.create(4)
        buffer.writei32(b, 0, raw_int)
        return b, 4
    end,
     ["int64"] = function(raw_int64) -- Added for explicit int64 (Int64)
        local b = buffer.create(8)
        -- Luau buffers don't have writei64 directly, often requires splitting or careful handling
        -- For simplicity, if it's within f64 range, can write as f64, or handle as two i32s
        -- This is a placeholder, true int64 binary serialization is more complex
        buffer.writef64(b, 0, raw_int64) -- May lose precision for very large int64
        return b, 8
    end,
	["UDim"] = function(raw)
		local b = buffer.create(8)
		buffer.writef32(b, 0, raw.Scale)
		buffer.writei32(b, 4, raw.Offset)
		return b, 8
	end,
	["UDim2"] = function(raw)
		local b = buffer.create(16)
		local X_buf, _ = Binary_Descriptors.UDim(raw.X) -- Use comma blank idiom
		buffer.copy(b, 0, X_buf)
		local Y_buf, _ = Binary_Descriptors.UDim(raw.Y)
		buffer.copy(b, 8, Y_buf)
		return b, 16
	end,
	["Ray"] = function(raw)
		local b = buffer.create(24)
		local Origin_buf, _ = Binary_Descriptors.Vector3(raw.Origin)
		buffer.copy(b, 0, Origin_buf)
		local Direction_buf, _ = Binary_Descriptors.Vector3(raw.Direction)
		buffer.copy(b, 12, Direction_buf)
		return b, 24
	end,
	["Faces"] = function(raw)
		local b = buffer.create(1) -- Faces are typically 1 byte in binary
		buffer.writeu8(b, 0, __BIT(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front))
		return b, 1
	end,
	["Axes"] = function(raw)
		local b = buffer.create(1) -- Axes are typically 1 byte
		buffer.writeu8(b, 0, __BIT(raw.X, raw.Y, raw.Z))
		return b, 1
	end,
	["BrickColor"] = function(raw)
		local b = buffer.create(4) -- BrickColor.Number is u32
		buffer.writeu32(b, 0, raw.Number)
		return b, 4
	end,
	["Color3"] = function(raw) -- Usually stored as 3 floats
		local b = buffer.create(12)
		buffer.writef32(b, 0, raw.R)
		buffer.writef32(b, 4, raw.G)
		buffer.writef32(b, 8, raw.B)
		return b, 12
	end,
    ["Color3uint8"] = function(raw) -- Stored as 4 bytes (R, G, B, A - A often 255)
		local b = buffer.create(4)
		buffer.writeu8(b, 0, math.floor(raw.R * 255))
		buffer.writeu8(b, 1, math.floor(raw.G * 255))
		buffer.writeu8(b, 2, math.floor(raw.B * 255))
        buffer.writeu8(b, 3, 255) -- Alpha, usually 255 for Color3
		return b, 4
	end,
	["Vector2"] = function(raw)
		local b = buffer.create(8)
		buffer.writef32(b, 0, raw.X)
		buffer.writef32(b, 4, raw.Y)
		return b, 8
	end,
	["Vector3"] = function(raw)
		local b = buffer.create(12)
		buffer.writef32(b, 0, raw.X)
		buffer.writef32(b, 4, raw.Y)
		buffer.writef32(b, 8, raw.Z)
		return b, 12
	end,
	["Vector2int16"] = function(raw)
		local b = buffer.create(4)
		buffer.writei16(b, 0, raw.X)
		buffer.writei16(b, 2, raw.Y)
		return b, 4
	end,
	["Vector3int16"] = function(raw)
		local b = buffer.create(6)
		buffer.writei16(b, 0, raw.X)
		buffer.writei16(b, 2, raw.Y)
		buffer.writei16(b, 4, raw.Z)
		return b, 6
	end,
	["CFrame"] = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
		local packed_rotation = string.pack("<fffffffff", R00, R01, R02, R10, R11, R12, R20, R21, R22)
		local rotation_ID = CFrame_Rotation_IDs[packed_rotation]
		local len = rotation_ID and (12 + 1) or (12 + 1 + 36) -- Pos(12) + ID(1) [+ RotationMatrix(36)]
		local b = buffer.create(len)
		buffer.writef32(b, 0, X)
		buffer.writef32(b, 4, Y)
		buffer.writef32(b, 8, Z)
		if rotation_ID then
			buffer.writeu8(b, 12, rotation_ID)
		else
			buffer.writeu8(b, 12, 0x00) -- ID for full matrix
			buffer.writef32(b, 13, R00); buffer.writef32(b, 17, R01); buffer.writef32(b, 21, R02)
			buffer.writef32(b, 25, R10); buffer.writef32(b, 29, R11); buffer.writef32(b, 33, R12)
			buffer.writef32(b, 37, R20); buffer.writef32(b, 41, R21); buffer.writef32(b, 45, R22)
		end
		return b, len
	end,
	["EnumItem"] = function(raw_enum) -- Renamed
		local b = buffer.create(4) -- Enum values are u32
		buffer.writeu32(b, 0, raw_enum.Value)
		return b, 4
	end,
	["NumberSequence"] = nil, -- To be assigned Binary_Descriptors.__SEQUENCE
	["ColorSequence"] = function(raw)
		return Binary_Descriptors.__SEQUENCE(raw, function(color3, b_arg, offset_arg)
			local c3_buf, _ = Binary_Descriptors.Color3(color3)
            buffer.copy(b_arg, offset_arg, c3_buf, 0, 12)
			return 12
		end, 20, 0)
	end,
	["NumberRange"] = function(raw)
		local b = buffer.create(8)
		buffer.writef32(b, 0, raw.Min)
		buffer.writef32(b, 4, raw.Max)
		return b, 8
	end,
	["Rect"] = function(raw)
		local b = buffer.create(16)
		local Min_buf, _ = Binary_Descriptors.Vector2(raw.Min)
		buffer.copy(b, 0, Min_buf)
		local Max_buf, _ = Binary_Descriptors.Vector2(raw.Max)
		buffer.copy(b, 8, Max_buf)
		return b, 16
	end,
	["PhysicalProperties"] = function(raw)
		local len = 1
		if raw then len += 20 end
		local b = buffer.create(len)
		buffer.writeu8(b, 0, raw and 1 or 0)
		if raw then
			buffer.writef32(b, 1, raw.Density)
			buffer.writef32(b, 5, raw.Friction)
			buffer.writef32(b, 9, raw.Elasticity)
			buffer.writef32(b, 13, raw.FrictionWeight)
			buffer.writef32(b, 17, raw.ElasticityWeight)
		end
		return b, len
	end,
	["Region3"] = function(raw) -- In binary, often stored as CFrame + Size
        -- This is a simplification; true binary Region3 might differ
		local b = buffer.create(24) 
        local Min_buf, _ = Binary_Descriptors.Vector3(raw.Min)
		buffer.copy(b, 0, Min_buf)
		local Max_buf, _ = Binary_Descriptors.Vector3(raw.Max)
		buffer.copy(b, 12, Max_buf)
		return b, 24
	end,
	["Region3int16"] = function(raw)
		local b = buffer.create(12)
		local Min_buf, _ = Binary_Descriptors.Vector3int16(raw.Min)
		buffer.copy(b, 0, Min_buf)
		local Max_buf, _ = Binary_Descriptors.Vector3int16(raw.Max)
		buffer.copy(b, 6, Max_buf)
		return b, 12
	end,
	["Font"] = (636 < CLIENT_VERSION) and function(raw)
		local family_str = raw.Family
        if string.sub(family_str, 1, 10) == "rbxassetid" then family_str = "" end -- Normalize for binary like Studio often does
		local b_Family, Family_size = Binary_Descriptors.string(family_str)
		-- CachedFaceId is often empty string in binary for non-custom fonts
		local b_CachedFaceId, CachedFaceId_size = Binary_Descriptors.string("")
		local len = 2 + 1 + Family_size + CachedFaceId_size -- Weight(u16) + Style(u8) + Family + CachedFaceId
		local b = buffer.create(len)
		local ok_w, weight = pcall(index, raw, "Weight")
		local ok_s, style = pcall(index, raw, "Style")
		buffer.writeu16(b, 0, ok_w and weight.Value or 0)
		buffer.writeu8(b, 2, ok_s and style.Value or 0)
		buffer.copy(b, 3, b_Family)
		buffer.copy(b, 3 + Family_size, b_CachedFaceId)
		return b, len
	end or function(raw) -- older client
		local family_str = raw.Family
        if string.sub(family_str, 1, 10) == "rbxassetid" then family_str = "" end
		local b_Family, Family_size = Binary_Descriptors.string(family_str)
		local b_CachedFaceId, CachedFaceId_size = Binary_Descriptors.string("")
		local len = 2 + 1 + Family_size + CachedFaceId_size
		local b = buffer.create(len)
		local FontString = tostring(raw)
		local EmptyWeight = string_find(FontString, "Weight = ,")
		local EmptyStyle = string_find(FontString, "Style =  }")
		buffer.writeu16(b, 0, EmptyWeight and 0 or raw.Weight.Value)
		buffer.writeu8(b, 2, EmptyStyle and 0 or raw.Style.Value)
		buffer.copy(b, 3, b_Family)
		buffer.copy(b, 3 + Family_size, b_CachedFaceId)
		return b, len
	end,
    ["SharedString"] = function(raw_sstr) -- Binary SharedString is just index into SSTR chunk
        -- This descriptor is for the *value* if it were stored directly,
        -- but actual SSTR usage means this won't be directly called for prop values often.
        -- It's more for constructing the SSTR chunk.
        return Binary_Descriptors.string(base64.decode(raw_sstr)) -- Assuming raw_sstr is base64 encoded md5 key in XML context
    end,
    ["BinaryString"] = function(raw_bstr)
        -- In binary, this is often just a length-prefixed byte array.
        -- The input `raw_bstr` here is assumed to be the actual binary data.
        local raw_len = #raw_bstr
		local len = 4 + raw_len
		local b = buffer.create(len)
		buffer.writeu32(b, 0, raw_len)
		buffer.writestring(b, 4, raw_bstr) -- assumes raw_bstr is a string of bytes
		return b, len
    end,
    ["ProtectedString"] = function(raw_pstr)
        -- Same as string for binary value encoding
        return Binary_Descriptors.string(raw_pstr)
    end,
    ["Content"] = function(raw_content)
        -- Content like <url>rbxassetid://123</url>
        return Binary_Descriptors.string(raw_content)
    end,
    ["Object"] = function(ref_id) -- For Object-referencing properties (Ref type)
        local b = buffer.create(4) -- Referents are usually 32-bit integers in binary PROP chunks
        buffer.writei32(b, 0, ref_id or -1) -- -1 for NULL ref
        return b, 4
    end,
}
Binary_Descriptors.NumberSequence = Binary_Descriptors.__SEQUENCE -- Assign after __SEQUENCE is defined


local ESCAPES_PATTERN = "[&<>\"'\0\1-\9\11-\12\14-\31\127-\255]"
local ESCAPES = {
	["&"] = "&", ["<"] = "<", [">"] = ">", ['"'] = """, ["'"] = "'", ["\0"] = "",
}
for rangeStart, rangeEnd in string.gmatch(ESCAPES_PATTERN, "(.)%-(.)") do
	for charCode = string.byte(rangeStart), string.byte(rangeEnd) do
		ESCAPES[string.char(charCode)] = "&#" .. charCode .. ";"
	end
end

local XML_Descriptors
XML_Descriptors = {
	__CDATA = function(raw) return "<![CDATA[" .. raw .. "]]>" end,
	__ENUM = function(raw) return raw.Value, "token" end,
	__NORMALIZE_NUMBER = function(raw)
		if raw ~= raw then return "NAN"
		elseif raw == math.huge then return "INF"
		elseif raw == -math.huge then return "-INF" end
		return raw
	end,
	__NORMALIZE_RANGE = function(raw) return raw ~= raw and "0" or raw end,
	__MINMAX = function(min_val, max_val, descriptor)
		return "<min>" .. descriptor(min_val) .. "</min><max>" .. descriptor(max_val) .. "</max>"
	end,
	__PROTECTEDSTRING = function(raw)
		return string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES) or XML_Descriptors.__CDATA(raw)
	end,
	__SEQUENCE = function(raw, valueFormatter)
		local __NORMALIZE_RANGE_fn = XML_Descriptors.__NORMALIZE_RANGE -- Renamed
		local sequence_str = "" -- Renamed
		for _, keypoint in ipairs(raw.Keypoints) do
			local Value = keypoint.Value
			sequence_str ..= keypoint.Time .. " " .. (valueFormatter and valueFormatter(Value) or __NORMALIZE_RANGE_fn(Value) .. " " .. __NORMALIZE_RANGE_fn(
				keypoint.Envelope
			) .. " ")
		end
		return sequence_str
	end,
	__VECTOR = function(X, Y, Z)
		local Value = "<X>" .. X .. "</X><Y>" .. Y .. "</Y>"
		if Z then Value ..= "<Z>" .. Z .. "</Z>" end
		return Value
	end,
	Axes = function(raw) return "<axes>" .. __BIT(raw.X, raw.Y, raw.Z) .. "</axes>" end,
	BinaryString = function(raw) return raw == "" and "" or base64encode(raw) end,
	BrickColor = function(raw) return raw.Number end,
	CFrame = function(raw)
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = raw:GetComponents()
		return XML_Descriptors.__VECTOR(X, Y, Z) .. "<R00>" .. R00 .. "</R00><R01>" .. R01 .. "</R01><R02>" .. R02 .. "</R02><R10>" .. R10 .. "</R10><R11>" .. R11 .. "</R11><R12>" .. R12 .. "</R12><R20>" .. R20 .. "</R20><R21>" .. R21 .. "</R21><R22>" .. R22 .. "</R22>", "CoordinateFrame"
	end,
	Color3 = function(raw) return "<R>" .. raw.R .. "</R><G>" .. raw.G .. "</G><B>" .. raw.B .. "</B>" end,
	Color3uint8 = function(raw)
		return 0xFF000000 + (math.floor(raw.R * 255) * 0x10000) + (math.floor(raw.G * 255) * 0x100) + math.floor(raw.B * 255)
	end,
	ColorSequence = function(raw)
		return XML_Descriptors.__SEQUENCE(raw, function(color3)
			local __NORMALIZE_RANGE_fn = XML_Descriptors.__NORMALIZE_RANGE
			return __NORMALIZE_RANGE_fn(color3.R) .. " " .. __NORMALIZE_RANGE_fn(color3.G) .. " " .. __NORMALIZE_RANGE_fn(color3.B) .. " 0 "
		end)
	end,
	Content = function(raw)
		local SourceType = raw.SourceType
		return SourceType == Enum.ContentSourceType.None and "<null></null>"
			or SourceType == Enum.ContentSourceType.Uri and "<uri>" .. XML_Descriptors.string(raw.Uri) .. "</uri>"
			or SourceType == Enum.ContentSourceType.Object and "<Ref name=\"Object\">" .. GetRef(raw.Object) .. "</Ref>" -- Added name attribute for clarity
	end,
	ContentId = function(raw) return raw == "" and "<null></null>" or "<url>" .. XML_Descriptors.string(raw) .. "</url>", "Content" end,
	CoordinateFrame = function(raw) return "<CFrame>" .. XML_Descriptors.CFrame(raw) .. "</CFrame>" end,
	Faces = function(raw) return "<faces>" .. __BIT(raw.Right, raw.Top, raw.Back, raw.Left, raw.Bottom, raw.Front) .. "</faces>" end,
	Font = (636 < CLIENT_VERSION) and function(raw)
		local ok_w, weight = pcall(index, raw, "Weight"); local ok_s, style = pcall(index, raw, "Style")
		return "<Family>" .. XML_Descriptors.ContentId(raw.Family) .. "</Family><Weight>" .. (ok_w and XML_Descriptors.__ENUM(weight) or "") .. "</Weight><Style>" .. (ok_s and style.Name or "") .. "</Style>"
	end or function(raw)
		local FontString = tostring(raw); local EmptyWeight = string_find(FontString, "Weight = ,"); local EmptyStyle = string_find(FontString, "Style =  }")
		return "<Family>" .. XML_Descriptors.ContentId(raw.Family) .. "</Family><Weight>" .. (EmptyWeight and "" or XML_Descriptors.__ENUM(raw.Weight)) .. "</Weight><Style>" .. (EmptyStyle and "" or raw.Style.Name) .. "</Style>"
	end,
	NumberRange = function(raw) local __NORMALIZE_RANGE_fn = XML_Descriptors.__NORMALIZE_RANGE; return __NORMALIZE_RANGE_fn(raw.Min) .. " " .. __NORMALIZE_RANGE_fn(raw.Max) end,
	NumberSequence = nil,
	PhysicalProperties = function(raw)
		local CustomPhysics = "<CustomPhysics>" .. XML_Descriptors.bool(raw and true or false) .. "</CustomPhysics>"
		return raw and CustomPhysics .. "<Density>" .. raw.Density .. "</Density><Friction>" .. raw.Friction .. "</Friction><Elasticity>" .. raw.Elasticity .. "</Elasticity><FrictionWeight>" .. raw.FrictionWeight .. "</FrictionWeight><ElasticityWeight>" .. raw.ElasticityWeight .. "</ElasticityWeight>" or CustomPhysics
	end,
	Ray = function(raw) local vec3_desc = XML_Descriptors.Vector3; return "<origin>" .. vec3_desc(raw.Origin) .. "</origin><direction>" .. vec3_desc(raw.Direction) .. "</direction>" end,
	Rect = function(raw) return XML_Descriptors.__MINMAX(raw.Min, raw.Max, XML_Descriptors.Vector2), "Rect2D" end,
	Region3 = function(raw) local Translation = raw.CFrame.Position; local HalfSize = raw.Size * 0.5; return XML_Descriptors.__MINMAX(Translation - HalfSize, Translation + HalfSize, XML_Descriptors.Vector3) end,
	Region3int16 = function(raw) return XML_Descriptors.__MINMAX(raw.Min, raw.Max, XML_Descriptors.Vector3int16) end,
	SharedString = function(raw_sstr) -- Renamed
		raw_sstr = raw_sstr == "" and "" or base64encode(raw_sstr)
		local Identifier = SharedString_identifiers[raw_sstr]
		if SharedStrings[Identifier] == nil then SharedStrings[Identifier] = raw_sstr end
		return Identifier
	end,
	SecurityCapabilities = nil,
	UDim = function(raw) return "<S>" .. raw.Scale .. "</S><O>" .. raw.Offset .. "</O>" end,
	UDim2 = function(raw) local X, Y = raw.X, raw.Y; return "<XS>" .. X.Scale .. "</XS><XO>" .. X.Offset .. "</XO><YS>" .. Y.Scale .. "</YS><YO>" .. Y.Offset .. "</YO>" end,
	Vector2 = function(raw) return XML_Descriptors.__VECTOR(raw.X, raw.Y) end,
	Vector2int16 = nil,
	Vector3 = function(raw) return XML_Descriptors.__VECTOR(raw.X, raw.Y, raw.Z) end,
	Vector3int16 = nil,
	bool = function(raw) return raw and "true" or "false" end,
	double = nil, float = nil, int = nil, int64 = nil,
	string = function(raw) return (raw == nil or raw == "") and "" or string_find(raw, "]]>") and string.gsub(raw, ESCAPES_PATTERN, ESCAPES) or XML_Descriptors.__CDATA(string.gsub(raw, "\0", "")) end,
}
do
	local BASE_CAPABILITIES; pcall(function() BASE_CAPABILITIES = SecurityCapabilities.new() end)
	if BASE_CAPABILITIES then
		local CAPABILITY_BITS = { Plugin = 1, LocalUser = 2, WritePlayer = 4, RobloxScript = 8, RobloxEngine = 16, NotAccessible = 32, RunClientScript = 256, RunServerScript = 512, AccessOutsideWrite = 2048, Unassigned = 32768, AssetRequire = 65536, LoadString = 131072, ScriptGlobals = 262144, CreateInstances = 524288, Basic = 1048576, Audio = 2097152, DataStore = 4194304, Network = 8388608, Physics = 16777216, UI = 33554432, CSG = 67108864, Chat = 134217728, Animation = 268435456, Avatar = 536870912, Input = 1073741824, Environment = 2147483648, RemoteEvent = 4294967296, LegacySound = 8589934592, Players = 17179869184, CapabilityControl = 34359738368, InternalTest = 1152921504606846976, PluginOrOpenCloud = 2305843009213693952, Assistant = 4611686018427387904 }
		XML_Descriptors.SecurityCapabilities = function(raw)
			if raw == BASE_CAPABILITIES then return 0 end; local result = 0
			for _, flag_name in string.split(tostring(raw), " | ") do local bit = CAPABILITY_BITS[flag_name]; if bit then result += bit end end
			return result
		end
	end
end
for descriptorName, redirectName in pairs({ NumberSequence = "__SEQUENCE", Vector2int16 = "Vector2", Vector3int16 = "Vector3", double = "__NORMALIZE_NUMBER", float = "__NORMALIZE_NUMBER", int = "__NORMALIZE_NUMBER", int64 = "__NORMALIZE_NUMBER" }) do
	XML_Descriptors[descriptorName] = XML_Descriptors[redirectName]
end
if CLIENT_VERSION < 700 then -- Arbitrary high version for future-proofing; adjust if Roblox changes Content serialization.
	XML_Descriptors.Content = XML_Descriptors.ContentId
end

local ClassList
do
	local ClassPropertyExceptions = { Whitelist = { TriangleMeshPart = ArrayToDict({ "CollisionFidelity" }) }, Blacklist = { LuaSourceContainer = ArrayToDict({ "ScriptGuid" }), Instance = ArrayToDict({ "UniqueId", "HistoryId" }) } }
	local NotScriptableFixes = {
		Instance = {
			AttributesSerialize = function(instance)
				local attrs = instance:GetAttributes(); if not next(attrs) then return "" end
				local attrs_n = 0; local buffer_size = 4; local attrs_sorted = {}; local attrs_formatted = table.clone(attrs)
				for attr, val in attrs do
					attrs_n += 1; attrs_sorted[attrs_n] = attr
					local Type = typeof(val); local Descriptor = Binary_Descriptors[Type]; local attr_size
					attrs_formatted[attr], attr_size = Descriptor(val)
					buffer_size += 5 + #attr + attr_size
				end
				table.sort(attrs_sorted); local b = buffer.create(buffer_size); local offset = 0
				buffer.writeu32(b, offset, attrs_n); offset += 4
				local string__descriptor = Binary_Descriptors.string
				for _, attr in ipairs(attrs_sorted) do
					local b_Name, Name_size = string__descriptor(attr); buffer.copy(b, offset, b_Name); offset += Name_size
					buffer.writeu8(b, offset, attr_Type_IDs[typeof(attrs[attr])]); offset += 1
					local bb = attrs_formatted[attr]; buffer.copy(b, offset, bb); offset += buffer.len(bb)
				end
				return buffer.tostring(b)
			end,
			DefinesCapabilities = "Sandboxed", Tags = function(instance) local tags = instance:GetTags(); return #tags == 0 and "" or table.concat(tags, "\0") end,
		},
		BallSocketConstraint = { MaxFrictionTorqueXml = "MaxFrictionTorque" },
		BasePart = { Color3uint8 = "Color", MaterialVariantSerialized = "MaterialVariant", size = "Size" },
		DoubleConstrainedValue = { value = "Value" }, IntConstrainedValue = { value = "Value" },
		Terrain = {
			AcquisitionMethod = "LastUsedModificationMethod", MaterialColors = function(instance)
				local TERRAIN_MATERIALS = { Enum.Material.Grass, Enum.Material.Slate, Enum.Material.Concrete, Enum.Material.Brick, Enum.Material.Sand, Enum.Material.WoodPlanks, Enum.Material.Rock, Enum.Material.Glacier, Enum.Material.Snow, Enum.Material.Sandstone, Enum.Material.Mud, Enum.Material.Basalt, Enum.Material.Ground, Enum.Material.CrackedLava, Enum.Material.Asphalt, Enum.Material.Cobblestone, Enum.Material.Ice, Enum.Material.LeafyGrass, Enum.Material.Salt, Enum.Material.Limestone, Enum.Material.Pavement }
				local b = buffer.create(6 + #TERRAIN_MATERIALS * 3); local offset = 6; local RGB = { "R", "G", "B" }
				for _, material in ipairs(TERRAIN_MATERIALS) do local color = instance:GetMaterialColor(material); for _, comp in ipairs(RGB) do buffer.writeu8(b, offset, math.floor(color[comp] * 255)); offset += 1 end end
				return buffer.tostring(b)
			end,
		},
		TriangleMeshPart = { FluidFidelityInternal = "FluidFidelity" }, MeshPart = { InitialSize = "MeshSize" }, PartOperation = { InitialSize = "MeshSize" },
		Part = { shape = "Shape" }, TrussPart = { style = "Style" }, FormFactorPart = { formFactorRaw = "FormFactor" },
		Fire = { heat_xml = "Heat", size_xml = "Size" }, Humanoid = { Health_XML = "Health" },
		HumanoidDescription = {
			EmotesDataInternal = function(instance) local d = ""; for n, ids in instance:GetEmotes() do d ..= n .. "^" .. table.concat(ids, "^") .. "^\\" end return d end,
			EquippedEmotesDataInternal = function(instance) local d = ""; for _, e in instance:GetEquippedEmotes() do d ..= e.Slot .. "^" .. e.Name .. "\\" end return d end,
		},
		LocalizationTable = { Contents = function(instance) return instance:GetContents() end }, MaterialService = { Use2022MaterialsXml = "Use2022Materials" },
		Model = { ScaleFactor = function(instance) return instance:GetScale() end, WorldPivotData = "WorldPivot" },
		PackageLink = { PackageIdSerialize = "PackageId", VersionIdSerialize = "VersionNumber" }, Players = { MaxPlayersInternal = "MaxPlayers", PreferredPlayersInternal = "PreferredPlayers" },
		StarterPlayer = { AvatarJointUpgrade_Serialized = "AvatarJointUpgrade" }, Smoke = { size_xml = "Size", opacity_xml = "Opacity", riseVelocity_xml = "RiseVelocity" },
		Sound = { xmlRead_MaxDistance_3 = "RollOffMaxDistance" }, WeldConstraint = { Part0Internal = "Part0", Part1Internal = "Part1" },
		Workspace = {
			CollisionGroupData = function()
				local groups = service.PhysicsService:GetRegisteredCollisionGroups(); local n = #groups; if n == 0 then return "\1\0" end
				local size = 2; for _, g in ipairs(groups) do size += 7 + #g.name end; local b = buffer.create(size); local offset = 0
				buffer.writeu8(b, offset, 1); offset += 1; buffer.writeu8(b, offset, n); offset += 1
				for i, g in ipairs(groups) do local name, id, mask = g.name, i - 1, g.mask; local name_len = #name
					buffer.writeu8(b, offset, id); offset += 1; buffer.writeu8(b, offset, 4); offset += 1
					buffer.writei32(b, offset, mask); offset += 4; buffer.writeu8(b, offset, name_len); offset += 1
					buffer.writestring(b, offset, name); offset += name_len
				end
				return buffer.tostring(b)
			end,
		},
	}

	local function FetchAPI()
		local API_Classes_Table; local API_Dump_for_file
		local ok, err = pcall(function()
			local client_ver_str_file = CLIENT_VERSION_STR .. "_API.json"
			local read_ok, result_str = pcall(readfile, client_ver_str_file)
			if read_ok and result_str and result_str ~= "" then
				local decode_ok, decoded_data = pcall(service.HttpService.JSONDecode, service.HttpService, result_str)
				if decode_ok and decoded_data.Classes then -- Check if it's the full dump structure
                    API_Classes_Table = decoded_data.Classes
                    API_Dump_for_file = result_str -- Already minified if it was saved that way
                    return
                elseif decode_ok and type(decoded_data) == "table" and decoded_data[1] and decoded_data[1].ClassName then -- Likely already a list of classes
                    API_Classes_Table = decoded_data
                    API_Dump_for_file = result_str
                    return
                end
			end

			local matching_versions, is_matched = {}; local DeployHistory = string.split(game:HttpGet("https://setup.rbxcdn.com/DeployHistory.txt", true), "\n")
			for i = #DeployHistory, 1, -1 do local line = DeployHistory[i]; local file_version = string.match(line, "file version: ([%d, ]+)")
				if file_version then if string.split(file_version, ", ")[2] == tostring(CLIENT_VERSION) then is_matched = true; local version_hash = string.match(line, "(version%-[^%s]+)"); if version_hash then matching_versions[version_hash] = true end elseif is_matched then break end end
			end
			for version_hash in pairs(matching_versions) do -- Use pairs for dictionary
				local http_ok, http_result = pcall(game.HttpGet, game, "https://setup.rbxcdn.com/" .. version_hash .. "-Full-API-Dump.json", true)
				if http_ok then local dec_ok, dec_res = pcall(service.HttpService.JSONDecode, service.HttpService, http_result); if dec_ok and dec_res.Classes then API_Classes_Table = dec_res.Classes; API_Dump_for_file = service.HttpService:JSONEncode({Classes = API_Classes_Table}); break end end -- Store full structure for consistency
			end
			if API_Dump_for_file then writefile(client_ver_str_file, API_Dump_for_file) end
		end)

		if not ok or not API_Classes_Table then
			warn("[DEBUG] Failed to get " .. CLIENT_VERSION_STR .. " API Dump, trying latest fallback. Error: " .. tostring(err))
            local fallback_result = game:HttpGet("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json", true)
            local decoded_fallback = service.HttpService:JSONDecode(fallback_result)
			API_Classes_Table = decoded_fallback.Classes
            API_Dump_for_file = service.HttpService:JSONEncode({Classes = API_Classes_Table}) -- For potential future save
		end

		local classList_tmp = {}; local ClassesWhitelist, ClassesBlacklist = ClassPropertyExceptions.Whitelist, ClassPropertyExceptions.Blacklist
		for _, API_Class in ipairs(API_Classes_Table) do -- Use ipairs for sequential arrays
			local ClassProperties, ClassProperties_size = {}, 1; local Class = { Properties = ClassProperties, Superclass = API_Class.Superclass }
			local ClassTags_tbl = API_Class.Tags; local ClassName = API_Class.Name
			if ClassTags_tbl then Class.Tags = ArrayToDict(ClassTags_tbl, nil, nil, "string") end
			local NotScriptableFixClass = NotScriptableFixes[ClassName]; local ClassWhitelist, ClassBlacklist = ClassesWhitelist[ClassName], ClassesBlacklist[ClassName]

			for _, Member in ipairs(API_Class.Members) do
				if Member.MemberType == "Property" then local Serialization = Member.Serialization
					if Serialization.CanLoad then local PropertyName = Member.Name
						if (Serialization.CanSave or ClassWhitelist and ClassWhitelist[PropertyName]) and not (ClassBlacklist and ClassBlacklist[PropertyName]) then
							local MemberTags = Member.Tags; local ValueType = Member.ValueType; local ValueType_Name = ValueType.Name
							if CLIENT_VERSION >= 645 and ValueType_Name == "Content" and CLIENT_VERSION < 700 then -- Adjusted Content type handling
								-- Allow Content for newer clients if it's not ContentId, but ContentId is preferred for XML.
                                -- For binary, this might need specific handling. For now, skip if it's the new "Content" object type.
                                if Member.ValueType.Category == "Class" then -- Heuristic for new Content object
                                     -- warn("Skipping new Content object property for now:", ClassName, PropertyName)
                                     continue
                                end
							end
							local Special, PreferredDescriptorName; if MemberTags then for _, tag_val in ipairs(MemberTags) do if type(tag_val) == "table" then PreferredDescriptorName = tag_val.PreferredDescriptorName; if PreferredDescriptorName and Special then break end elseif tag_val == "NotScriptable" then Special = true; if PreferredDescriptorName then break end end end end
							local Property = { Name = PropertyName, Category = ValueType.Category, ValueType = ValueType_Name, Special = Special, CanRead = nil }
							if string.sub(ValueType_Name, 1, 8) == "Optional" then Property.Optional = string.sub(ValueType_Name, 9) end
							if NotScriptableFixClass then local Fix = NotScriptableFixClass[PropertyName]; if Fix then Property.Fallback = type(Fix) == "function" and Fix or PreferredDescriptorName and function(inst) local o, r = pcall(index, inst, PreferredDescriptorName); return o and r or inst[Fix] end or function(inst) return inst[Fix] end end
							elseif PreferredDescriptorName then Property.Fallback = function(inst) return inst[PreferredDescriptorName] end end
							ClassProperties[ClassProperties_size] = Property; ClassProperties_size += 1
						end
					end
				end
			end
			classList_tmp[ClassName] = Class
		end
		return classList_tmp
	end
	local ok_api, result_api = pcall(FetchAPI)
	if ok_api then ClassList = result_api else warn("Failed to load the API Dump: ", tostring(result_api)); return end
end

local GLOBAL_ENV = getgenv and getgenv() or _G or shared

local function synsaveinstance(CustomOptions, CustomOptions2)
	if GLOBAL_ENV.USSI_RUNNING then warn("SaveInstance is already running."); return end
	GLOBAL_ENV.USSI_RUNNING = true
	
	task.defer(function() GLOBAL_ENV.USSI_RUNNING = nil end) -- Ensure flag is cleared

	do local sti = global_container.setthreadidentity; if sti then pcall(sti, 8) end end

	local currentXmlStr, currentXmlSize, totalXmlSize, xmlChunks_tbl = "", 0, 0, table.create(1) -- Renamed
    local currentBinaryBuffer, totalBinarySize = buffer.create(1024*1024), 0 -- For binary output, start with 1MB buffer
    local binaryOutputBuffers = {} -- table of buffers for binary
    local binaryCurrentOffset = 0

	local savebufferXml, savebufferXml_size = {}, 1 -- Renamed
	local xml_header = '<!-- Saved by DexInstance (Enhanced by 2aney_x & AI) --><roblox version="4">' -- XML specific header

	local StatusText_label -- Renamed

	local OPTIONS = {
		mode = "optimized", noscripts = false, scriptcache = true, timeout = 10, __DEBUG_MODE = false,
		BinaryOutput = false, -- NEW: Option for binary output
		Callback = false, DecompileJobless = false, DecompileIgnore = { "TextChatService" },
		IgnoreDefaultPlayerScripts = EXECUTOR_NAME ~= "Wave" and true, SaveBytecode = false,
		IgnoreProperties = {}, IgnoreList = { "CoreGui", "CorePackages" }, ExtraInstances = {},
		NilInstances = false, NilInstancesFixes = {}, SaveCacheInterval = 0x1600 * 10,
		ShowStatus = true, SafeMode = false, ShutdownWhenDone = false, AntiIdle = true,
		Anonymous = false, ReadMe = true, FilePath = false, Object = false, IsModel = false,
		IgnoreDefaultProperties = true, IgnoreNotArchivable = true, IgnorePropertiesOfNotScriptsOnScriptsMode = false,
		IgnoreSpecialProperties = ArrayToDict({ "Fluxus", "Delta", "Solara" })[EXECUTOR_NAME] or false,
		IsolateLocalPlayer = false, IsolateLocalPlayerCharacter = false, IsolatePlayers = false, IsolateStarterPlayer = false,
		RemovePlayerCharacters = true, SaveNotCreatable = false,
		NotCreatableFixes = { "", "AnimationTrack", "Player", "PlayerGui", "PlayerScripts", "PlayerMouse", "ScreenshotHud", "StudioData", "TextSource", "TouchTransmitter" },
		IgnoreSharedStrings = EXECUTOR_NAME ~= "Wave" and true, SharedStringOverwrite = false,
		TreatUnionsAsParts = EXECUTOR_NAME == "Solara", AlternativeWritefile = not ArrayToDict({ "WRD", "Xeno", "Zorara" })[EXECUTOR_NAME],
		OptionsAliases = { DecompileTimeout = "timeout", FileName = "FilePath", IgnoreArchivable = "IgnoreNotArchivable", IgnoreDefaultProps = "IgnoreDefaultProperties", SaveNonCreatable = "SaveNotCreatable", SavePlayers = "IsolatePlayers" },
	}

	local OPTIONS_lowercase, CustomOptions_valid = {}, {}; for opt_name in pairs(OPTIONS) do local lc_name = string.lower(opt_name); OPTIONS_lowercase[lc_name] = opt_name end
	for alias, opt_name in pairs(OPTIONS.OptionsAliases) do local lc_alias = string.lower(alias); OPTIONS_lowercase[lc_alias] = opt_name end

	do -- Load Settings
		local function construct_NilinstanceFix(Name, ClassName, Separate)
			return function(instance, instancePropertyOverrides)
				local Exists; if not Separate then Exists = OPTIONS.NilInstancesFixes[Name] end; local Fix
				local DoesntExist = not Exists
				if DoesntExist then Fix = Instance.new(ClassName); if not Separate then OPTIONS.NilInstancesFixes[Name] = Fix end; instancePropertyOverrides[Fix] = { __SaveSpecific = true, __Children = { instance }, Properties = { Name = Name } }
				else Fix = Exists; table.insert(instancePropertyOverrides[Fix].__Children, instance) end
				if DoesntExist then return Fix end
			end
		end
		OPTIONS.NilInstancesFixes.Animator = construct_NilinstanceFix("AnimatorFixContainer", "AnimationController")
		OPTIONS.NilInstancesFixes.AdPortal = construct_NilinstanceFix("AdPortalFixContainer", "Part")
		OPTIONS.NilInstancesFixes.Attachment = construct_NilinstanceFix("AttachmentFixContainer", "Part")
		OPTIONS.NilInstancesFixes.BaseWrap = construct_NilinstanceFix("BaseWrapFixContainer", "MeshPart")
		OPTIONS.NilInstancesFixes.PackageLink = construct_NilinstanceFix("PackageLinkFixContainer", "Folder", true)

		if CustomOptions2 and type(CustomOptions2) == "table" then local tmp = CustomOptions; local Type = typeof(tmp); CustomOptions = CustomOptions2
			if Type == "Instance" then CustomOptions.Object = tmp elseif Type == "table" and typeof(tmp[1]) == "Instance" then CustomOptions.ExtraInstances = tmp; OPTIONS.IsModel = true end
		end
		local Type = typeof(CustomOptions)
		if Type == "table" then if typeof(CustomOptions[1]) == "Instance" then OPTIONS.mode = "invalidmode"; OPTIONS.ExtraInstances = CustomOptions; OPTIONS.IsModel = true; CustomOptions = {} else for key, value in pairs(CustomOptions) do local option = OPTIONS_lowercase[string.lower(key)]; if option then OPTIONS[option] = value; CustomOptions_valid[option] = true end end
			local Decompile = CustomOptions.Decompile; if Decompile ~= nil then OPTIONS.noscripts = not Decompile end
			local SavePlayerChars = CustomOptions.SavePlayerCharacters; if SavePlayerChars ~= nil then OPTIONS.RemovePlayerCharacters = not SavePlayerChars end -- Renamed
			local RemovePlayers = CustomOptions.RemovePlayers; if RemovePlayers ~= nil then OPTIONS.IsolatePlayers = not RemovePlayers end
		end elseif Type == "Instance" then OPTIONS.mode = "invalidmode"; OPTIONS.Object = CustomOptions; CustomOptions = {} else CustomOptions = {} end
	end

	if OPTIONS.IgnoreDefaultPlayerScripts then local DecompileIgnore = OPTIONS.DecompileIgnore; local Path = service.StarterPlayer:FindFirstChild("StarterPlayerScripts"); local Exclude = { ModuleScript = { "PlayerModule" }, LocalScript = { "RbxCharacterSounds" } }
		if Path then for _, className_tbl in pairs(Exclude) do for _, name_val in ipairs(className_tbl) do local Found = Path:FindFirstChild(name_val); if Found then table.insert(DecompileIgnore, Found) end end end end
	end

	local InstancesOverrides = {}
	local DecompileIgnore_dict, IgnoreList_dict, IgnoreProperties_dict, NotCreatableFixes_dict = ArrayToDict(OPTIONS.DecompileIgnore, true), ArrayToDict(OPTIONS.IgnoreList, true), ArrayToDict(OPTIONS.IgnoreProperties), ArrayToDict(OPTIONS.NotCreatableFixes, true, "Folder") -- Renamed

	local __DEBUG_MODE_fn = OPTIONS.__DEBUG_MODE; if __DEBUG_MODE_fn and type(__DEBUG_MODE_fn) ~= "function" then __DEBUG_MODE_fn = warn end -- Renamed

	local FilePath = OPTIONS.FilePath; local SaveCacheInterval = OPTIONS.SaveCacheInterval
	local ToSaveInstance = OPTIONS.Object; local IsModel = OPTIONS.IsModel
	if ToSaveInstance and CustomOptions.IsModel == nil then IsModel = true end

	-- Use Instance:IsPropertyModified if available (Roblox version 645+)
    local IPM_VERSION_THRESHOLD = 645 -- Version when IsPropertyModified became generally reliable
	local USE_IS_PROPERTY_MODIFIED = (CLIENT_VERSION >= IPM_VERSION_THRESHOLD) and OPTIONS.IgnoreDefaultProperties

	local IgnoreNotArchivable = not OPTIONS.IgnoreNotArchivable; local IgnorePropertiesOfNotScriptsOnScriptsMode = OPTIONS.IgnorePropertiesOfNotScriptsOnScriptsMode
	local old_gethiddenproperty; if OPTIONS.IgnoreSpecialProperties and gethiddenproperty then old_gethiddenproperty = gethiddenproperty; gethiddenproperty = nil end
	local SaveNotCreatable = OPTIONS.SaveNotCreatable; local TreatUnionsAsParts = OPTIONS.TreatUnionsAsParts
	local DecompileJobless = OPTIONS.DecompileJobless; if DecompileJobless then OPTIONS.scriptcache = true end
	local ScriptCache = OPTIONS.scriptcache and getscriptbytecode; local Timeout = OPTIONS.timeout
	local IgnoreSharedStrings = OPTIONS.IgnoreSharedStrings; local SharedStringOverwrite = OPTIONS.SharedStringOverwrite
	local ldeccache = GLOBAL_ENV.scriptcache
	local DecompileIgnoring_flag, ToSaveList_tbl, ldecompile_fn, placename_str, elapse_t_start, SaveNotCreatableWillBeEnabled_flag, RecoveredScripts_tbl -- Renamed

	if OPTIONS.ReadMe then RecoveredScripts_tbl = {} end
	if ScriptCache and not ldeccache then ldeccache = {}; GLOBAL_ENV.scriptcache = ldeccache end
	if ToSaveInstance == game then OPTIONS.mode = "full"; ToSaveInstance = nil; IsModel = nil end
	local function isLuaSourceContainer(instance) return instance:IsA("LuaSourceContainer") end

	do local mode = string.lower(OPTIONS.mode); local tmp_list = table.clone(OPTIONS.ExtraInstances); local PlaceName_base = game.PlaceId -- Renamed
		pcall(function() PlaceName_base ..= " " .. service.MarketplaceService:GetProductInfo(PlaceName_base).Name end)
		local function sanitizeFileName(str_val) return string.sub(string.gsub(string.gsub(string.gsub(str_val, "[^%w _]", ""), " +", " "), " +$", ""), 1, 240) end
		
        local file_ext = OPTIONS.BinaryOutput and (IsModel and ".rbxm" or ".rbxl") or (IsModel and ".rbxmx" or ".rbxlx")
        placename_str = (FilePath or sanitizeFileName((IsModel and "model " or "place ") .. PlaceName_base .. " " .. (ToSaveInstance or tmp_list[1] or game):GetFullName())) .. file_ext

		if ToSaveInstance then if mode == "optimized" then mode = "full" end; for _, key_str in ipairs({ "IsolateLocalPlayer", "IsolateLocalPlayerCharacter", "IsolatePlayers", "IsolateStarterPlayer", "NilInstances" }) do if CustomOptions_valid[key_str] == nil then OPTIONS[key_str] = false end end end
		
		if GLOBAL_ENV[placename_str] then warn("SaveInstance is already saving to this file: ", placename_str); GLOBAL_ENV.USSI_RUNNING = nil; return end
		GLOBAL_ENV[placename_str] = true; GLOBAL_ENV.USSI_RUNNING = nil -- USSI_RUNNING flag is for the overall function, placename_str is for file lock
		
		if mode ~= "scripts" then IgnorePropertiesOfNotScriptsOnScriptsMode = nil end
		local TempRoot = ToSaveInstance or game
		if mode == "full" then if not ToSaveInstance then local Children = TempRoot:GetChildren(); if #Children > 0 then local tmp_dict = ArrayToDict(tmp_list); for _, child in ipairs(Children) do if not tmp_dict[child] then table.insert(tmp_list, child) end end end end
		elseif mode == "optimized" then local tmp_dict = ArrayToDict(tmp_list)
			for _, serviceName in ipairs({ "Workspace", "Players", "Lighting", "MaterialService", "ReplicatedFirst", "ReplicatedStorage", "ServerScriptService", "ServerStorage", "StarterGui", "StarterPack", "StarterPlayer", "Teams", "SoundService", "Chat", "TextChatService", "LocalizationService", "JointsService" }) do
				local _service = game:FindService(serviceName); if _service and not tmp_dict[_service] then table.insert(tmp_list, _service) end
			end
		elseif mode == "scripts" then local unique = {}; for _, instance in TempRoot:GetDescendants() do if isLuaSourceContainer(instance) then local Parent = instance.Parent; while Parent and Parent ~= TempRoot do instance = instance.Parent; Parent = instance.Parent end; if Parent then unique[instance] = true end end end; for instance in pairs(unique) do table.insert(tmp_list, instance) end end
		ToSaveList_tbl = tmp_list; if ToSaveInstance then table.insert(ToSaveList_tbl, 1, ToSaveInstance) end
	end

	local IsolateLocalPlayer = OPTIONS.IsolateLocalPlayer; local IsolateLocalPlayerCharacter = OPTIONS.IsolateLocalPlayerCharacter
	local IsolatePlayers = OPTIONS.IsolatePlayers; local IsolateStarterPlayer = OPTIONS.IsolateStarterPlayer
	local NilInstances = OPTIONS.NilInstances; if NilInstances and global_container.enablenilinstances then global_container.enablenilinstances() end -- Solara specific
	
    local function get_size_format_xml() local Size; for i, unit in ipairs({ "B", "KB", "MB", "GB", "TB" }) do if totalXmlSize < 0x400 ^ i then Size = math.floor(totalXmlSize / (0x400 ^ (i - 1)) * 10) / 10 .. " " .. unit; break end end; return Size end
    local function get_size_format_binary() local Size; for i, unit in ipairs({ "B", "KB", "MB", "GB", "TB" }) do if totalBinarySize < 0x400 ^ i then Size = math.floor(totalBinarySize / (0x400 ^ (i - 1)) * 10) / 10 .. " " .. unit; break end end; return Size end

	local RunService = service.RunService; local function wait_for_render() RunService.RenderStepped:Wait() end
	local Loading_task; local decompile_yield_counter = 0 -- Renamed
	local function run_with_loading(text, keepStatus, waitForRender_flag, taskFunction, ...)
		local previousStatus; if StatusText_label then if keepStatus then previousStatus = StatusText_label.Text end
			Loading_task = task.spawn(function() local spinner_count = 0; local chars = { "|", "/", "—", "\\" }; local chars_size = #chars
				local function getLoadingText() spinner_count = (spinner_count % chars_size) + 1; return chars[spinner_count] end
				text ..= " "; while true do StatusText_label.Text = text .. getLoadingText(); task.wait(0.25) end
			end); if waitForRender_flag then wait_for_render() end
		end
		local result = { taskFunction(...) }; if Loading_task then task.cancel(Loading_task); Loading_task = nil; if previousStatus then StatusText_label.Text = previousStatus end end
		return unpack(result)
	end

	local function construct_TimeoutHandler(timeout_val, f, timeout_ret)
		return timeout_val < 0 and function(...) return pcall(f, ...) end or function(...)
            local args = {...}
			local thread = coroutine.running(); local timeoutThread, isCancelled
			timeoutThread = task.delay(timeout_val, function() isCancelled = true; task.spawn(coroutine.resume, thread, nil, timeout_ret) end) -- Use task.spawn for resume to avoid yielding issues
			task.spawn(function() local ok, result_or_err = pcall(f, unpack(args)); if isCancelled then return end; task.cancel(timeoutThread)
				while coroutine.status(thread) ~= "suspended" do task.wait() end; coroutine.resume(thread, ok, result_or_err)
			end); return coroutine.yield()
		end
	end

	local getbytecode_fn; if getscriptbytecode then getbytecode_fn = construct_TimeoutHandler(3, getscriptbytecode) end -- Renamed
	local SaveBytecode_fn; if OPTIONS.SaveBytecode and getscriptbytecode then SaveBytecode_fn = function(script) local s, bytecode = getbytecode_fn(script); if s and bytecode and bytecode ~= "" then return "-- Bytecode (Base64):\n-- " .. base64encode(bytecode) .. "\n\n" end end end -- Renamed

	do local Decompiler = decompile
		if OPTIONS.noscripts then ldecompile_fn = function() return "-- Decompiling is disabled" end
		elseif Decompiler then local decomp_fn = construct_TimeoutHandler(Timeout, Decompiler, "Decompiler timed out") -- Renamed
			ldecompile_fn = function(script) local hashed_bytecode; if ScriptCache then local s, bytecode = getbytecode_fn(script); local cached
					if s then if not bytecode or bytecode == "" then return "-- The Script is Empty" end; hashed_bytecode = sha384(bytecode); cached = ldeccache[hashed_bytecode] end
					if cached then if __DEBUG_MODE_fn then __DEBUG_MODE_fn("Found in Cache", script:GetFullName()) end; return cached end
				else if DecompileJobless then return "-- Not found in already decompiled ScriptCache" end
                    decompile_yield_counter += 1; if decompile_yield_counter % 5 == 0 then task.wait() end -- Yield every 5 non-cached decompiles
				end
				local ok, result_str = run_with_loading("Decompiling " .. script.Name, true, nil, decomp_fn, script); if not result_str then ok, result_str = false, "Empty Output" end
				local output_str; if ok then result_str = string.gsub(result_str, "\0", "\\0"); output_str = result_str else output_str = "--[[ Failed to decompile. Reason:\n" .. (result_str or "") .. "\n]]" end
				if ScriptCache and hashed_bytecode then ldeccache[hashed_bytecode] = output_str; if __DEBUG_MODE_fn then __DEBUG_MODE_fn("Cached", script:GetFullName()) end end
				return output_str
			end
		else ldecompile_fn = function() return "-- Your Executor does NOT have a Decompiler" end end
	end

	local function GetLocalPlayer() return service.Players.LocalPlayer or service.Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or service.Players.LocalPlayer end
	local function filterLinkedSource(str_val) local o, r = pcall(service.HttpService.JSONDecode, service.HttpService, str_val); return not (o and r.errors) end
	local function replaceClassName(instance, InstanceName, ClassName) local InstanceOverride; if InstanceName ~= ClassName then InstanceOverride = InstancesOverrides[instance]; if not InstanceOverride then InstanceOverride = { Properties = { Name = "[" .. ClassName .. "] " .. InstanceName } }; InstancesOverrides[instance] = InstanceOverride end end; return InstanceOverride end
	local function filterPropVal(result_val, propertyName, category) return result_val == nil or result_val == "can't get value" or type(result_val) == "string" and (category == "Enum" or string_find(result_val, "Unable to get property " .. propertyName)) end
	
	local __BREAK_STR = "__BREAK" .. service.HttpService:GenerateGUID(false) -- Renamed

	local function ReadProperty(instance, property_meta, propertyName, special_flag, category, optional_flag) -- Renamed
		local raw_val = __BREAK_STR; local InstanceOverride = InstancesOverrides[instance]
		if InstanceOverride then local PropsOverride = InstanceOverride.Properties; if PropsOverride then local PropOverride = PropsOverride[propertyName]; if PropOverride ~= nil then return PropOverride end end end
		local CanRead = property_meta.CanRead; if CanRead == false then return __BREAK_STR end
		if special_flag then if gethiddenproperty then local ok, result_val = pcall(gethiddenproperty, instance, propertyName); if ok then raw_val = result_val end
				if filterPropVal(raw_val, propertyName, category) then if result_val ~= nil or not optional_flag then if __DEBUG_MODE_fn then __DEBUG_MODE_fn("Filtered hidden prop", propertyName, raw_val) end; property_meta.CanRead = false end; return __BREAK_STR end
			end
		else if CanRead then raw_val = instance[propertyName] else local ok, result_val = pcall(index, instance, propertyName)
				if ok then raw_val = result_val elseif gethiddenproperty then ok, result_val = pcall(gethiddenproperty, instance, propertyName); if ok then raw_val = result_val; property_meta.Special = true end end
				property_meta.CanRead = ok; if not ok or filterPropVal(raw_val, propertyName, category) then return __BREAK_STR end
			end
		end
		return raw_val
	end

	local function ReturnItemXml(className, instance) return '<Item class="' .. className .. '" referent="' .. GetRef(instance) .. '"><Properties>' end
	local function ReturnPropertyXml(tag_name, propertyName, value_str) return "<" .. tag_name .. ' name="' .. propertyName .. '">' .. value_str .. "</" .. tag_name .. ">" end -- Renamed
	local function ReturnValueAndTagXml(raw_val, valueType, descriptor) local value_str, tag_name = (descriptor or XML_Descriptors[valueType])(raw_val); return value_str, tag_name or valueType end -- Renamed
	local function InheritsFix(fixes_tbl, className, instance) local Fix = fixes_tbl[className]; if Fix then return Fix elseif Fix == nil then for class_name, fix_fn in pairs(fixes_tbl) do if instance:IsA(class_name) then return fix_fn end end end end -- Renamed
	local function GetInheritedProps(className) local prop_list = {}; local layer = ClassList[className]; while layer do local layer_props = layer.Properties; table.move(layer_props, 1, #layer_props, #prop_list + 1, prop_list); layer = ClassList[layer.Superclass] end; inherited_properties[className] = prop_list; return prop_list end
	
    local CHUNK_LIMIT_XML = 200 * 1024 * 1024 -- Renamed
	local function save_cache_xml(final_flag) -- Renamed
		local savestr = table.concat(savebufferXml); currentXmlStr ..= savestr
		local savestr_len = #savestr; totalXmlSize += savestr_len; currentXmlSize += savestr_len
		table.clear(savebufferXml); savebufferXml_size = 1
		if CHUNK_LIMIT_XML < currentXmlSize or final_flag then table.insert(xmlChunks_tbl, { size = currentXmlSize, str = currentXmlStr }); currentXmlStr, currentXmlSize = "", 0 end
		if StatusText_label then StatusText_label.Text = "Saving (XML).. Size: " .. get_size_format_xml() end; wait_for_render()
	end

    -- Rudimentary Binary saving functions
    local shared_strings_binary_map = {}
    local shared_strings_binary_list = {}
    local next_sstr_id = 0

    local function get_sstr_id(str_val)
        if not shared_strings_binary_map[str_val] then
            shared_strings_binary_map[str_val] = next_sstr_id
            table.insert(shared_strings_binary_list, str_val)
            next_sstr_id += 1
        end
        return shared_strings_binary_map[str_val]
    end
    
    local function write_buffer_to_main(buf_to_write)
        local len = buffer.len(buf_to_write)
        if binaryCurrentOffset + len > buffer.len(currentBinaryBuffer) then
            -- Grow buffer or flush to table
            table.insert(binaryOutputBuffers, currentBinaryBuffer) -- Store current buffer
            local new_size = math.max(len, 1024*1024) -- New buffer at least 1MB or required size
            currentBinaryBuffer = buffer.create(new_size)
            binaryCurrentOffset = 0
            if StatusText_label then StatusText_label.Text = "Saving (Binary).. Size: " .. get_size_format_binary() end
        end
        buffer.copy(currentBinaryBuffer, binaryCurrentOffset, buf_to_write, 0, len)
        binaryCurrentOffset += len
        totalBinarySize += len
    end

    local function write_chunk_header_binary(name, uncompressed_len, compressed_len, reserved)
        local header_buf = buffer.create(16)
        buffer.writestring(header_buf, 0, name, 4)
        buffer.writeu32(header_buf, 4, compressed_len)
        buffer.writeu32(header_buf, 8, uncompressed_len)
        buffer.writeu32(header_buf, 12, reserved or 0)
        write_buffer_to_main(header_buf)
    end


	local function save_specific_xml(className, properties) -- Renamed
		local Ref = Instance.new(className); local Item = ReturnItemXml(Ref.ClassName, Ref)
		for propertyName, val in pairs(properties) do local whitelisted, value_str, tag_name
			if "Source" == propertyName then tag_name = "ProtectedString"; value_str = XML_Descriptors.__PROTECTEDSTRING(val); whitelisted = true
			elseif "Name" == propertyName then whitelisted = true; value_str, tag_name = ReturnValueAndTagXml(val, "string") end
			if whitelisted then Item ..= ReturnPropertyXml(tag_name, propertyName, value_str) end
		end; Item ..= "</Properties>"; return Item
	end

    local referent_to_binary_id = {}
    local next_binary_id = 0
    local function GetBinaryRefId(instance)
        if not referent_to_binary_id[instance] then
            next_binary_id +=1
            referent_to_binary_id[instance] = next_binary_id
        end
        return referent_to_binary_id[instance]
    end
    
    local class_name_to_id = {}
    local class_id_counter = 0
    local inst_chunk_data = {} -- { class_id, count, {ref_ids} }
    local prop_chunk_data = {} -- { class_id, prop_name_sstr_id, prop_type_id, count, {instance_id, value_buffer} }
    local prnt_chunk_data = {} -- { child_id, parent_id }
    local attr_chunk_data = {} -- { instance_id, attr_buffer }


	local function save_hierarchy(hierarchy)
		for _, instance in ipairs(hierarchy) do
			if IgnoreNotArchivable and not instance.Archivable then continue end
			local SkipEntirely = IgnoreList_dict[instance]; if SkipEntirely then continue end
			local ClassName = instance.ClassName; local InstanceName = instance.Name
			do local OnIgnoredList = IgnoreList_dict[ClassName]; if OnIgnoredList and (OnIgnoredList == true or OnIgnoredList[InstanceName]) then continue end end
			if not DecompileIgnoring_flag then DecompileIgnoring_flag = DecompileIgnore_dict[instance]; if DecompileIgnoring_flag == nil then local DecompileIgnored = DecompileIgnore_dict[ClassName]; if DecompileIgnored then DecompileIgnoring_flag = DecompileIgnored == true or DecompileIgnored[InstanceName] end end
				if DecompileIgnoring_flag then DecompileIgnoring_flag = instance elseif DecompileIgnoring_flag == false then DecompileIgnoring_flag = 1 end
			end
			local InstanceOverride, ClassNameOverride, ClassTagOverride
			do local Fix = NotCreatableFixes_dict[ClassName]
				if Fix then if SaveNotCreatable then ClassName, InstanceOverride = Fix, replaceClassName(instance, InstanceName, ClassName) else continue end
				else if TreatUnionsAsParts and instance:IsA("PartOperation") then ClassName, InstanceOverride = "Part", replaceClassName(instance, InstanceName, ClassName); ClassNameOverride = "BasePart"
					elseif not ClassList[ClassName] then if __DEBUG_MODE_fn then __DEBUG_MODE_fn("Class not Found in API Dump", ClassName) end; ClassTagOverride = ClassName; ClassName = "Folder" end
				end
			end
			if not InstanceOverride then InstanceOverride = InstancesOverrides[instance] end

            if OPTIONS.BinaryOutput then
                -- Binary saving logic
                local current_instance_binary_id = GetBinaryRefId(instance)
                if not class_name_to_id[ClassName] then
                    class_id_counter += 1
                    class_name_to_id[ClassName] = class_id_counter
                    inst_chunk_data[class_id_counter] = { class_name_sstr_id = get_sstr_id(ClassName), count = 0, ref_ids = buffer.create(1024), current_ref_offset = 0 } -- Preallocate ref_ids buffer
                end
                local class_data = inst_chunk_data[class_name_to_id[ClassName]]
                class_data.count += 1
                -- Append ref_id to class_data.ref_ids buffer
                if class_data.current_ref_offset + 4 > buffer.len(class_data.ref_ids) then
                    local new_ref_buf = buffer.create(buffer.len(class_data.ref_ids) * 2)
                    buffer.copy(new_ref_buf, 0, class_data.ref_ids, 0, class_data.current_ref_offset)
                    class_data.ref_ids = new_ref_buf
                end
                buffer.writei32(class_data.ref_ids, class_data.current_ref_offset, current_instance_binary_id)
                class_data.current_ref_offset += 4
                
                -- Placeholder for actual parenting logic in binary
                if instance.Parent and referent_to_binary_id[instance.Parent] then
                    table.insert(prnt_chunk_data, { child_id = current_instance_binary_id, parent_id = GetBinaryRefId(instance.Parent)})
                end

            else -- XML Saving
                if InstanceOverride and InstanceOverride.__SaveSpecific then savebufferXml[savebufferXml_size] = save_specific_xml(ClassName, InstanceOverride.Properties); savebufferXml_size += 1
                else savebufferXml[savebufferXml_size] = ReturnItemXml(ClassTagOverride or ClassName, instance); savebufferXml_size += 1
                    if not (IgnorePropertiesOfNotScriptsOnScriptsMode and not isLuaSourceContainer(instance)) then
                        local default_prop_instance; local new_def_inst_created = false -- Renamed
                        if not USE_IS_PROPERTY_MODIFIED and OPTIONS.IgnoreDefaultProperties then default_prop_instance = default_instances[ClassName]
                            if not default_prop_instance then local ClassTags = ClassList[ClassName].Tags; if not (ClassTags and ClassTags.NotCreatable) then new_def_inst_created = Instance.new(ClassName); default_prop_instance = {}; default_instances[ClassName] = default_prop_instance elseif __DEBUG_MODE_fn then __DEBUG_MODE_fn("Unable to create default Instance for property check", ClassName) end end
                        end
                        local proplist = inherited_properties[ClassNameOverride or ClassName] or GetInheritedProps(ClassNameOverride or ClassName)
                        for _, Property_meta in ipairs(proplist) do local PropertyName = Property_meta.Name; if IgnoreProperties_dict[PropertyName] then continue end; local ValueType = Property_meta.ValueType; if IgnoreSharedStrings and ValueType == "SharedString" then continue end
                            local Special_flag, Category, Optional_flag = Property_meta.Special, Property_meta.Category, Property_meta.Optional -- Renamed

                            if USE_IS_PROPERTY_MODIFIED then
                                if not Special_flag and not (PropertyName == "Source" and isLuaSourceContainer(instance)) and not instance:IsPropertyModified(PropertyName) then
                                    if not (ValueType == "OptionalCoordinateFrame" and instance[PropertyName] ~= nil) then -- Special case for OptionalCFrames that might be non-default but IsPropertyModified is false
                                        continue
                                    end
                                end
                            end
                            
                            local raw_val = ReadProperty(instance, Property_meta, PropertyName, Special_flag, Category, Optional_flag)
                            if raw_val == __BREAK_STR then local ok, result_val = pcall(gethiddenproperty_fallback, instance, PropertyName); if result_val == nil and not Optional_flag then ok = nil end
                                if ok then raw_val = result_val else local Fallback = Property_meta.Fallback; if Fallback then ok, result_val = pcall(Fallback, instance); if ok then raw_val = result_val else if __DEBUG_MODE_fn then __DEBUG_MODE_fn("NotScriptableFix Failed", PropertyName, tostring(result_val)) end; continue end else continue end end
                            end
                            if SharedStringOverwrite and ValueType == "BinaryString" then ValueType = "SharedString" end
                            if not USE_IS_PROPERTY_MODIFIED and default_prop_instance and not Property_meta.Special and not (PropertyName == "Source" and isLuaSourceContainer(instance)) then
                                if new_def_inst_created then default_prop_instance[PropertyName] = index(new_def_inst_created, PropertyName) end
                                if default_prop_instance[PropertyName] == raw_val then continue end
                            end
                            local tag_name, value_str; if Category == "Class" then tag_name = "Ref"; if raw_val then if SaveNotCreatableWillBeEnabled_flag then local Fix = NotCreatableFixes_dict[raw_val.ClassName]; if Fix and (PropertyName == "PlayerToHideFrom" or ValueType ~= "Instance" and ValueType ~= Fix) then continue end end; value_str = GetRef(raw_val) else value_str = "null" end
                            elseif Category == "Enum" then value_str, tag_name = XML_Descriptors.__ENUM(raw_val)
                            else local Descriptor = XML_Descriptors[ValueType]; if Descriptor then value_str, tag_name = ReturnValueAndTagXml(raw_val, ValueType, Descriptor)
                                elseif "ProtectedString" == ValueType then tag_name = ValueType; if PropertyName == "Source" then
                                    if DecompileIgnoring_flag then if DecompileIgnoring_flag == 1 then DecompileIgnoring_flag = nil end; value_str = "-- Ignored"
                                    else local should_decompile = true; local LinkedSource_Url = instance.LinkedSource; local hasLinkedSource = LinkedSource_Url ~= ""
                                        if hasLinkedSource then local Path = instance:GetFullName(); if RecoveredScripts_tbl then table.insert(RecoveredScripts_tbl, Path) end; local LinkedSource_AssetId = string.match(LinkedSource_Url, "%d+$"); local LinkedSource_Hash = string.match(LinkedSource_Url, "hash=([%w%d]+)"); local LinkedSource_ref = LinkedSource_Hash or LinkedSource_AssetId
                                            if LinkedSource_ref then if ScriptCache then local cached = ldeccache[LinkedSource_ref]; if cached then value_str = cached; should_decompile = nil end end
                                                if should_decompile then if DecompileJobless then value_str = "-- Not found in LinkedSource ScriptCache"; should_decompile = nil end
                                                    local asset_param = (LinkedSource_Hash and "hash=" or "id=") .. LinkedSource_ref
                                                    local http_ok, source_code = pcall(game.HttpGet, game, "https://assetdelivery.roproxy.com/v1/asset/?" .. asset_param); if http_ok and filterLinkedSource(source_code) then if ScriptCache then ldeccache[LinkedSource_ref] = source_code end; value_str = source_code; should_decompile = nil end
                                                end
                                            else warn("FAILED TO EXTRACT ORIGINAL SCRIPT SOURCE (OPEN A GITHUB ISSUE): ", instance:GetFullName(), LinkedSource_Url) end
                                        end
                                        if should_decompile then local isLocal = instance:IsA("LocalScript"); if (isLocal and instance.RunContext == Enum.RunContext.Server) or (not isLocal and instance:IsA("Script") and instance.RunContext ~= Enum.RunContext.Client) then value_str = "-- [FilteringEnabled] Server Scripts are IMPOSSIBLE to save" else value_str = ldecompile_fn(instance); if SaveBytecode_fn then local bc_output = SaveBytecode_fn(instance); if bc_output then value_str = bc_output .. value_str end end end end
                                        value_str = "-- Saved by DexInstance\n\n" .. (hasLinkedSource and "-- Original Source: " .. LinkedSource_Url .. "\n\n" or "") .. value_str
                                    end; value_str = XML_Descriptors.__PROTECTEDSTRING(value_str)
                                end
                                elseif Optional_flag then Descriptor = XML_Descriptors[Optional_flag]; if Descriptor then if raw_val == nil then continue else value_str, tag_name = ReturnValueAndTagXml(raw_val, ValueType, Descriptor) end end end
                            end
                            if tag_name then savebufferXml[savebufferXml_size] = ReturnPropertyXml(tag_name, PropertyName, value_str); savebufferXml_size += 1 else warn("UNSUPPORTED XML TYPE (REPORT ISSUE): ", ValueType, ClassName, PropertyName) end
                        end
                    end; savebufferXml[savebufferXml_size] = "</Properties>"; savebufferXml_size += 1
                    if SaveCacheInterval < savebufferXml_size then save_cache_xml() end
                end
            end -- End XML specific property saving

			if SkipEntirely ~= false then local Children = InstanceOverride and InstanceOverride.__Children or instance:GetChildren(); if #Children ~= 0 then save_hierarchy(Children) end end
			if DecompileIgnoring_flag and DecompileIgnoring_flag == instance then DecompileIgnoring_flag = nil end
			if not OPTIONS.BinaryOutput then savebufferXml[savebufferXml_size] = "</Item>"; savebufferXml_size += 1 end
		end
	end

	local function save_extra_xml(name_str, hierarchy, customClassName, source_code) -- Renamed
		savebufferXml[savebufferXml_size] = save_specific_xml((customClassName or "Folder"), { Name = name_str, Source = source_code }); savebufferXml_size += 1
		if hierarchy then save_hierarchy(hierarchy) end
		savebufferXml[savebufferXml_size] = "</Item>"; savebufferXml_size += 1
	end

	local function save_game()
        if OPTIONS.BinaryOutput then
            -- Binary Header (placeholder)
            local header_buf = buffer.create(16)
            buffer.writestring(header_buf, 0, "<roblox!", 8) -- Magic
            buffer.writeu16(header_buf, 8, 0) -- Version (dummy)
            buffer.writeu32(header_buf, 10, 0) -- Num Class Types (dummy)
            buffer.writeu32(header_buf, 14, 0) -- Num Instances (dummy)
            write_buffer_to_main(header_buf)
            
            -- META chunk (dummy for now)
            local meta_content = buffer.create(4) -- Placeholder for num unique classes
            buffer.writeu32(meta_content, 0, class_id_counter)
            write_chunk_header_binary("META", buffer.len(meta_content), buffer.len(meta_content),0)
            write_buffer_to_main(meta_content)

        else -- XML Header
			if IsModel then xml_header ..= '<Meta name="ExplicitAutoJoints">true</Meta>' end
			writefile(placename_str, xml_header) 
		end

		SaveNotCreatableWillBeEnabled_flag = SaveNotCreatable or (IsolateLocalPlayer or IsolateLocalPlayerCharacter) and IsolateLocalPlayer or IsolatePlayers or NilInstances and global_container.getnilinstances
		save_hierarchy(ToSaveList_tbl)

        if OPTIONS.BinaryOutput then
             -- Finalize SSTR chunk
            local sstr_full_buffer = buffer.create(4096) -- Start with 4KB, will expand
            local sstr_offset = 0
            local sstr_count = #shared_strings_binary_list
            
            local function append_to_sstr_buf(data_buf)
                local data_len = buffer.len(data_buf)
                if sstr_offset + data_len > buffer.len(sstr_full_buffer) then
                    local new_sstr_buf = buffer.create(buffer.len(sstr_full_buffer) * 2 + data_len)
                    buffer.copy(new_sstr_buf, 0, sstr_full_buffer, 0, sstr_offset)
                    sstr_full_buffer = new_sstr_buf
                end
                buffer.copy(sstr_full_buffer, sstr_offset, data_buf, 0, data_len)
                sstr_offset += data_len
            end

            local count_buf = buffer.create(4)
            buffer.writeu32(count_buf, 0, sstr_count)
            append_to_sstr_buf(count_buf)

            for _, str_val in ipairs(shared_strings_binary_list) do
                local str_len_buf = buffer.create(4)
                buffer.writeu32(str_len_buf, 0, #str_val)
                append_to_sstr_buf(str_len_buf)
                
                local str_data_buf = buffer.fromstring(str_val)
                append_to_sstr_buf(str_data_buf)
            end
            local final_sstr_chunk_content = buffer.create(sstr_offset)
            buffer.copy(final_sstr_chunk_content, 0, sstr_full_buffer, 0, sstr_offset)
            write_chunk_header_binary("SSTR", buffer.len(final_sstr_chunk_content), buffer.len(final_sstr_chunk_content), 0)
            write_buffer_to_main(final_sstr_chunk_content)

            -- Finalize INST chunk
            for class_id, data in pairs(inst_chunk_data) do
                local inst_content_buf = buffer.create(4 + 4 + data.current_ref_offset) -- class_name_sstr_id + count + ref_ids_len
                buffer.writeu32(inst_content_buf, 0, data.class_name_sstr_id)
                buffer.writeu32(inst_content_buf, 4, data.count)
                buffer.copy(inst_content_buf, 8, data.ref_ids, 0, data.current_ref_offset)
                
                write_chunk_header_binary("INST", buffer.len(inst_content_buf), buffer.len(inst_content_buf), 0)
                write_buffer_to_main(inst_content_buf)
            end
            
            -- Finalize PRNT chunk (very basic)
            local prnt_content_len = #prnt_chunk_data * (4+4) + 4 -- count + N * (child_id + parent_id)
            if prnt_content_len > 4 then
                local prnt_content_buf = buffer.create(prnt_content_len)
                local prnt_offset = 0
                buffer.writeu32(prnt_content_buf, prnt_offset, #prnt_chunk_data); prnt_offset += 4
                for _, pair in ipairs(prnt_chunk_data) do
                    buffer.writei32(prnt_content_buf, prnt_offset, pair.child_id); prnt_offset += 4
                    buffer.writei32(prnt_content_buf, prnt_offset, pair.parent_id); prnt_offset += 4
                end
                write_chunk_header_binary("PRNT", buffer.len(prnt_content_buf), buffer.len(prnt_content_buf), 0)
                write_buffer_to_main(prnt_content_buf)
            end

            -- ENDT chunk
            write_chunk_header_binary("ENDT", 0, 0, 0)

            -- Append the last partially filled buffer
            if binaryCurrentOffset > 0 then
                local final_partial_buf = buffer.create(binaryCurrentOffset)
                buffer.copy(final_partial_buf, 0, currentBinaryBuffer, 0, binaryCurrentOffset)
                table.insert(binaryOutputBuffers, final_partial_buf)
            end

        else -- XML Specific post-hierarchy processing
            if IsolateLocalPlayer or IsolateLocalPlayerCharacter then local LP = service.Players.LocalPlayer; if LP then if IsolateLocalPlayer then SaveNotCreatable = true; save_extra_xml("LocalPlayer", LP:GetChildren()) end; if IsolateLocalPlayerCharacter then local LPC = LP.Character; if LPC then save_extra_xml("LocalPlayer Character", LPC:GetChildren()) end end end end
            if IsolateStarterPlayer then save_extra_xml("StarterPlayer", service.StarterPlayer:GetChildren()) end
            if IsolatePlayers then SaveNotCreatable = true; save_extra_xml("Players", service.Players:GetChildren()) end
            if NilInstances and global_container.getnilinstances then local nil_inst_list, nil_inst_size = {}, 1; local NilFixes = OPTIONS.NilInstancesFixes
                for _, instance in ipairs(global_container.getnilinstances()) do if instance == game then instance = nil else local CN = instance.ClassName; local Fix = InheritsFix(NilFixes, CN, instance); if Fix then instance = Fix(instance, InstancesOverrides) end; local Cls = ClassList[CN]; if Cls then local CTags = Cls.Tags; if CTags and CTags.Service then instance = nil end end end
                    if instance then nil_inst_list[nil_inst_size] = instance; nil_inst_size += 1 end
                end; SaveNotCreatable = true; save_extra_xml("Nil Instances", nil_inst_list)
            end
            if OPTIONS.ReadMe then local elapsed = os.clock() - elapse_t_start; local rec_scripts_info = #RecoveredScripts_tbl ~= 0 and "\t\tIMPORTANT: Original Source of these Scripts was Recovered: " .. service.HttpService:JSONEncode(RecoveredScripts_tbl) .. "\n" or ""
                local readme = "--[[\n" .. rec_scripts_info .. "Thank you for using DexInstance.\n\nSAVING RECOMMENDATIONS:\n- If you didn't save in Binary (rbxl), save the game immediately to preserve property values (FILE -> Save to File As -> .rbxl).\n\nKNOWN LIMITATIONS:\n- ServerStorage, ServerScriptService and Server Scripts CANNOT be saved due to FilteringEnabled.\n\nEXPORT SETTINGS:\n" .. service.HttpService:JSONEncode(OPTIONS) .. "\n\n\t\tExport Information:\n\t\t- Elapsed time: " .. elapsed .. "\n\t\t- PlaceId: " .. game.PlaceId .. "\n\t\t- PlaceVersion: " .. game.PlaceVersion .. "\n\t\t- Client Version: " .. CLIENT_VERSION_STR .. "\n\t\t- Executor: " .. (identify_executor and table.concat({identify_executor()}, " ") or "Unknown") .. "\n]]"
                save_extra_xml("README", nil, "Script", readme)
            end
            do local tmp_sstr_tbl = { "<SharedStrings>" }; for identifier, value_str in pairs(SharedStrings) do table.insert(tmp_sstr_tbl, '<SharedString md5="' .. identifier .. '">' .. value_str .. "</SharedString>") end -- Renamed
                if #tmp_sstr_tbl > 1 then savebufferXml[savebufferXml_size] = table.concat(tmp_sstr_tbl); savebufferXml_size += 1; savebufferXml[savebufferXml_size] = "</SharedStrings>"; savebufferXml_size += 1 end
            end
            savebufferXml[savebufferXml_size] = "</roblox><!-- DexInstance -->"; savebufferXml_size += 1
            save_cache_xml(true) -- Final XML cache flush
        end

		do -- File Writing / Callback
            if OPTIONS.BinaryOutput then
                local Callback = OPTIONS.Callback
                if Callback then
                    -- For binary, callback receives a table of buffers and total size
                    Callback(binaryOutputBuffers, totalBinarySize, placename_str)
                else
                    if OPTIONS.AlternativeWritefile and appendfile then
                        local total_segments = 0
                        for _, buf_segment in ipairs(binaryOutputBuffers) do total_segments += math.ceil(buffer.len(buf_segment) / (4*1024*1024)) end
                        local current_segment_count = 0
                        -- Clear file first if it exists
                        writefile(placename_str, "") 
                        for _, buf_segment in ipairs(binaryOutputBuffers) do
                            local segment_len = buffer.len(buf_segment)
                            local num_sub_segments = math.ceil(segment_len / (4*1024*1024)) -- Celery limit
                            for i = 1, num_sub_segments do
                                local offset = (i-1) * (4*1024*1024)
                                local sub_len = math.min((4*1024*1024), segment_len - offset)
                                local sub_segment_str = buffer.tostring(buffer.sub(buf_segment, offset, sub_len))
                                
                                current_segment_count +=1
                                run_with_loading("Writing Binary File " .. math.round(current_segment_count/total_segments * 100) .. "%", nil, true, appendfile, placename_str, sub_segment_str)
                                if i ~= num_sub_segments then task.wait() end
                            end
                        end
                    else
                        -- Concatenate all buffers and write once (might hit memory limits for large files)
                        local final_binary_str_len = 0
                        for _, buf_segment in ipairs(binaryOutputBuffers) do final_binary_str_len += buffer.len(buf_segment) end
                        
                        local final_binary_buf = buffer.create(final_binary_str_len)
                        local current_final_offset = 0
                        for _, buf_segment in ipairs(binaryOutputBuffers) do
                            local len = buffer.len(buf_segment)
                            buffer.copy(final_binary_buf, current_final_offset, buf_segment, 0, len)
                            current_final_offset += len
                        end
                        run_with_loading("Writing " .. get_size_format_binary() .. " Binary File", nil, true, writefile, placename_str, buffer.tostring(final_binary_buf))
                    end
                end

            else -- XML Writing
                if OPTIONS.Anonymous then local LP = service.Players.LocalPlayer; if LP then local Anon = type(OPTIONS.Anonymous) == "table" and OPTIONS.Anonymous or { UserId = "1", Name = "Roblox" }
                        local function gsub_ins(input, search, replacement) local iL = string.lower(input); search = string.lower(search); local lF=0; local sS={}; local sL=#search; local iLn=#input; while sL <= iLn-lF do local S,F=string.find(iL,search,lF+1,true); if S==nil then break end; table.insert(sS,string.sub(input,lF+1,S-1));lF=F end; if lF==0 then return input end; table.insert(sS,string.sub(input,lF+1)); return table.concat(sS,replacement) end
                        for _, chunk in ipairs(xmlChunks_tbl) do chunk.str = gsub_ins(string.gsub(chunk.str, tostring(LP.UserId), Anon.UserId), LP.Name, Anon.Name) end -- Ensure UserId is string
                end end
                local Callback = OPTIONS.Callback
                if Callback then local totalstr_cb = xml_header; for _, chunk in ipairs(xmlChunks_tbl) do totalstr_cb ..= chunk.str end; Callback(totalstr_cb, xmlChunks_tbl, totalXmlSize, placename_str)
                elseif OPTIONS.AlternativeWritefile and appendfile then local SEGMENT_SIZE = 4145728; local totallen_alt, currentlen_alt = math.ceil(totalXmlSize / SEGMENT_SIZE), 1
                    for _, chunk in ipairs(xmlChunks_tbl) do local length_alt = math.ceil(chunk.size / SEGMENT_SIZE); for i = 1, length_alt do local savestr_alt = string.sub(chunk.str, (i - 1) * SEGMENT_SIZE + 1, i * SEGMENT_SIZE)
                            run_with_loading("Writing XML File " .. math.round(currentlen_alt / totallen_alt * 100) .. "%", nil, true, appendfile, placename_str, savestr_alt); currentlen_alt += 1; if i ~= length_alt then task.wait() end
                    end end
                else local totalstr_final = xml_header; for _, chunk in ipairs(xmlChunks_tbl) do totalstr_final ..= chunk.str end
                    run_with_loading("Writing " .. get_size_format_xml() .. " XML File", nil, true, writefile, placename_str, totalstr_final)
                end
            end
		end
		table.clear(SharedStrings); table.clear(referents); ref_size = 0; table.clear(default_instances); table.clear(inherited_properties) -- Clear caches
        table.clear(shared_strings_binary_map); table.clear(shared_strings_binary_list); next_sstr_id = 0; -- Clear binary specific caches
        table.clear(referent_to_binary_id); next_binary_id = 0; table.clear(class_name_to_id); class_id_counter = 0;
        table.clear(inst_chunk_data); table.clear(prop_chunk_data); table.clear(prnt_chunk_data); table.clear(attr_chunk_data);
	end

	local Connections_list; do local Players_svc = service.Players -- Renamed
		if IgnoreList_dict.Model ~= true then Connections_list = {}; local function ignoreCharacter(player) table.insert(Connections_list, player.CharacterAdded:Connect(function(character) IgnoreList_dict[character] = true end)); local Char = player.Character; if Char then IgnoreList_dict[Char] = true end end
			if OPTIONS.RemovePlayerCharacters then table.insert(Connections_list, Players_svc.PlayerAdded:Connect(function(player) ignoreCharacter(player) end)); for _, player in ipairs(Players_svc:GetPlayers()) do ignoreCharacter(player) end
			else IgnoreNotArchivable = false; if IsolateLocalPlayerCharacter then task.spawn(function() ignoreCharacter(GetLocalPlayer()) end) end end
		end
		if IsolateLocalPlayer and IgnoreList_dict.Player ~= true then task.spawn(function() IgnoreList_dict[GetLocalPlayer()] = true end) end
	end; if IsolateStarterPlayer then IgnoreList_dict.StarterPlayer = false end; if IsolatePlayers then IgnoreList_dict.Players = false end

	if OPTIONS.ShowStatus then do local Exists = GLOBAL_ENV._statustext_uss; if Exists then Exists:Destroy() end end; local StatusGui = Instance.new("ScreenGui"); GLOBAL_ENV._statustext_uss = StatusGui; StatusGui.DisplayOrder = 2e9; pcall(function() StatusGui.OnTopOfCoreBlur = true end)
		StatusText_label = Instance.new("TextLabel"); StatusText_label.Text = "Saving..."; StatusText_label.BackgroundTransparency = 1; StatusText_label.Font = Enum.Font.Code; StatusText_label.AnchorPoint = Vector2.new(1); StatusText_label.Position = UDim2.new(1); StatusText_label.Size = UDim2.new(0.3, 0, 0, 20); StatusText_label.TextColor3 = Color3.new(1, 1, 1); StatusText_label.TextScaled = true; StatusText_label.TextStrokeTransparency = 0.7; StatusText_label.TextXAlignment = Enum.TextXAlignment.Right; StatusText_label.TextYAlignment = Enum.TextYAlignment.Top; StatusText_label.Parent = StatusGui
		local function randomString() local len = math.random(10,20); local arr = table.create(len); for i=1,len do arr[i]=string.char(math.random(32,126)) end return table.concat(arr) end
		if global_container.gethui then StatusGui.Name = randomString(); StatusGui.Parent = global_container.gethui()
		else if global_container.protectgui then StatusGui.Name = randomString(); global_container.protectgui(StatusGui); StatusGui.Parent = service.CoreGui else local RobloxGui = service.CoreGui:FindFirstChild("RobloxGui"); if RobloxGui then StatusGui.Parent = RobloxGui else StatusGui.Name = randomString(); StatusGui.Parent = service.CoreGui end end end
	end

	do local SafeMode = OPTIONS.SafeMode; if SafeMode then task.spawn(function() local LP = GetLocalPlayer(); local PS = LP:FindFirstChild("PlayerScripts")
			if PS then local function construct_Override(inst) local children = inst:GetChildren(); InstancesOverrides[inst] = { __Children = children }; for _, child_inst in ipairs(children) do construct_Override(child_inst) end end; construct_Override(PS); InstancesOverrides[LP] = { __Children = LP:GetChildren(), Properties = { Name = "[" .. LP.ClassName .. "] " .. LP.Name } } end
			LP:Kick("\n[SAFEMODE] Saving in Progress..\nPlease do NOT leave"); wait_for_render(); task.delay(10, service.GuiService.ClearError, service.GuiService)
		end); RunService:Set3dRenderingEnabled(false) end
		local anti_idle_conn; if OPTIONS.AntiIdle then task.spawn(function() local getcon = global_container.getcon; local Idled = GetLocalPlayer().Idled; if getcon then for _, c in ipairs(getcon(Idled)) do if not pcall(c.Disable, c) then pcall(c.Disconnect, c) end end end; anti_idle_conn = Idled:Connect(function() service.VirtualInputManager:SendMouseWheelEvent(service.UserInputService:GetMouseLocation().X, service.UserInputService:GetMouseLocation().Y, true, game) end) end) end
		elapse_t_start = os.clock(); local ok, err_msg = xpcall(save_game, function(err_obj) return debug.traceback(tostring(err_obj)) end) -- Ensure err_obj is string
		if SafeMode then service.GuiService:ClearError(); RunService:Set3dRenderingEnabled(true) end
		if old_gethiddenproperty then gethiddenproperty = old_gethiddenproperty end
		if anti_idle_conn then anti_idle_conn:Disconnect() end; if Connections_list then for _, conn in ipairs(Connections_list) do conn:Disconnect() end end
		GLOBAL_ENV[placename_str] = nil
		if StatusText_label then task.spawn(function() elapse_t_start = os.clock() - elapse_t_start; local Log10 = math.log10(elapse_t_start); local ExtraTime = 10
				if ok then StatusText_label.Text = string.format("Saved! Time %.3f s; Size %s", elapse_t_start, OPTIONS.BinaryOutput and get_size_format_binary() or get_size_format_xml()); StatusText_label.TextColor3 = Color3.new(0, 1); task.wait(Log10 * 2 + ExtraTime)
				else if Loading_task then task.cancel(Loading_task); Loading_task = nil end; StatusText_label.Text = "Failed! Check F9 console"; StatusText_label.TextColor3 = Color3.new(1); warn("Error found while saving:\n", err_msg); task.wait(Log10 + ExtraTime) end
				if StatusText_label and StatusText_label.Parent then StatusText_label:Destroy() end -- Check parent before destroy
			end)
		end
		if OPTIONS.ShutdownWhenDone and ok then game:Shutdown() end
	end
end

return synsaveinstance
