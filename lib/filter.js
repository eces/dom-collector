module.exports.strip_filesize = function(value) {
  if ((value != null ? value.trim().length : void 0) === 0) {
    value = 0;
  } else if ((value != null ? value.indexOf('M') : void 0) !== -1) {
    value = value.replace('M', '') * 1000;
  } else if (!isFinite(+value)) {
    value = 0;
  }
  return value;
};

module.exports.strip_comma = function(value) {
  return value = value.replace(/,/g, '');
};

module.exports.string = function(value, def) {
  if (def == null) {
    def = '';
  }
  return String(value) || def;
};

module.exports.number = function(value, def) {
  if (def == null) {
    def = 0;
  }
  return Number(value) || def;
};

module.exports.boolean = function(value, def) {
  if (def == null) {
    def = false;
  }
  return Boolean(value) || def;
};

module.exports.trim = function(value) {
  return (value != null ? value.trim() : void 0) || '';
};
