module OrigenSVF
  MAJOR = 0
  MINOR = 1
  BUGFIX = 0
  DEV = 1
  VERSION = [MAJOR, MINOR, BUGFIX].join(".") + (DEV ? ".pre#{DEV}" : '')
end
