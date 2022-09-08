const Enums = {
  ModuleType: {
    READONLY: 0,
    CLONE: 1
  },
  ParamType : {
    UINT: 0,
    INT: 1,
    BOOL: 2,
    STRING: 3,
    ADDRESS: 4
  }
}

const Param = {
  _uint: 0,
  _int: 0,
  _bool: false,
  _string: '',
  _address: '0x0000000000000000000000000000000000000000'
}

function parseParam(type, input){
  const param = {...Param};
  if(type == Enums.ParamType.UINT)
    param._uint = input;
  if(type == Enums.ParamType.INT)
    param._int = input;
  if(type == Enums.ParamType.BOOL)
    param._bool = input;
  if(type == Enums.ParamType.STRING)
    param._string = input;
  if(type == Enums.ParamType.ADDRESS)
    param._address = input;
  return param;
}

module.exports = {
  Enums, parseParam, Param
}
