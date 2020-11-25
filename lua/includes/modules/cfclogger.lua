local Read
Read = file.Read
local gsub
gsub = string.gsub
local insert, concat, ToString
do
  local _obj_0 = table
  insert, concat, ToString = _obj_0.insert, _obj_0.concat, _obj_0.ToString
end
local LOG_LEVEL_OVERRIDE = (function()
  local contents = Read("cfc/logger/forced_log_level.txt", "DATA")
  return contents and gsub(contents, "%s", "") or nil
end)()
do
  local _class_0
  local _base_0 = {
    addCallbackFor = function(self, severity, callback)
      return insert(self.callbacks[severity], callback)
    end,
    runCallbacksFor = function(self, severity, message)
      local _list_0 = self.callbacks[severity]
      for _index_0 = 1, #_list_0 do
        local callback = _list_0[_index_0]
        callback(message)
      end
    end,
    on = function(self, severity)
      local scope = self
      local addCallback
      addCallback = function(self, callback)
        return scope.addCallbackFor(scope, severity, callback)
      end
      return {
        call = addCallback
      }
    end,
    formatParams = function(self, ...)
      local values = {
        ...
      }
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #values do
          local v = values[_index_0]
          _accum_0[_len_0] = istable(v) and ToString(v) or tostring(v)
          _len_0 = _len_0 + 1
        end
        values = _accum_0
      end
      return concat(values, " ")
    end,
    _log = function(self, severity, ...)
      if self.__class.severities[severity] < self.__class.severities[self.logLevel] then
        return 
      end
      local message = self:formatParams(...)
      print("[" .. tostring(self.projectName) .. "] [" .. tostring(severity) .. "] " .. tostring(message))
      return self:runCallbacksFor(severity, message)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, projectName, logLevel)
      self.projectName = projectName
      self.logLevel = LOG_LEVEL_OVERRIDE or logLevel or "info"
      do
        local _tbl_0 = { }
        for severity in pairs(self.__class.severities) do
          _tbl_0[severity] = { }
        end
        self.callbacks = _tbl_0
      end
      for severity in pairs(self.__class.severities) do
        self[severity] = function(self, ...)
          return self:_log(severity, ...)
        end
      end
    end,
    __base = _base_0,
    __name = "CFCLogger"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.__class.severities = {
    ["trace"] = 0,
    ["debug"] = 1,
    ["info"] = 2,
    ["warn"] = 3,
    ["error"] = 4,
    ["fatal"] = 5
  }
  CFCLogger = _class_0
end
local cfcLogger = CFCLogger("CFC Logger")
return cfcLogger:info("Loaded!")
